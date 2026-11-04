//! Short-lived LAN page that lets another device on the same network submit a
//! profile subscription URL. The desktop UI polls and backfills that URL.
//!
//! The listener exists only while a session is open. A pairing code must match
//! before a URL is kept, and nothing is written to disk.

use anyhow::{Context as _, Result, bail};
use serde::Deserialize;
use std::net::Ipv4Addr;
use std::sync::{Arc, Mutex, OnceLock};
use tokio::sync::oneshot;
use warp::Filter as _;

const PAGE_EN: &str = include_str!("../../../lan-input-en.html");
const PAGE_ZH: &str = include_str!("../../../lan-input-zh.html");
const MAX_URL_LEN: usize = 2048;

struct Session {
    port: u16,
    code: String,
    submitted: Mutex<Option<String>>,
    shutdown: Mutex<Option<oneshot::Sender<()>>>,
}

static SESSION: OnceLock<Mutex<Option<Arc<Session>>>> = OnceLock::new();

fn session_slot() -> &'static Mutex<Option<Arc<Session>>> {
    SESSION.get_or_init(|| Mutex::new(None))
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LanProfileSession {
    pub port: u16,
    pub code: String,
    pub urls: Vec<String>,
}

/// Open a LAN listener, replacing any session that is already running.
pub async fn start() -> Result<LanProfileSession> {
    stop();

    let listener = tokio::net::TcpListener::bind((Ipv4Addr::UNSPECIFIED, 0))
        .await
        .context("failed to bind the LAN profile input listener")?;
    let port = listener
        .local_addr()
        .context("failed to read the LAN profile input port")?
        .port();
    let code = random_code().context("failed to generate a LAN pairing code")?;
    let (shutdown_tx, shutdown_rx) = oneshot::channel();
    let session = Arc::new(Session {
        port,
        code: code.clone(),
        submitted: Mutex::new(None),
        shutdown: Mutex::new(Some(shutdown_tx)),
    });

    let routes = routes(Arc::clone(&session));
    crate::process::AsyncHandler::spawn(move || async move {
        warp::serve(routes)
            .incoming(listener)
            .graceful(async {
                shutdown_rx.await.ok();
            })
            .run()
            .await;
    });

    let view = LanProfileSession {
        port,
        code,
        urls: page_urls(port),
    };
    *session_slot().lock().unwrap_or_else(|poisoned| poisoned.into_inner()) = Some(session);
    Ok(view)
}

pub fn current() -> Option<LanProfileSession> {
    let slot = session_slot().lock().unwrap_or_else(|poisoned| poisoned.into_inner());
    slot.as_ref().map(|session| LanProfileSession {
        port: session.port,
        code: session.code.clone(),
        urls: page_urls(session.port),
    })
}

/// Return the newest accepted URL and clear it so the UI backfills once.
pub fn take_submission() -> Option<String> {
    let slot = session_slot().lock().unwrap_or_else(|poisoned| poisoned.into_inner());
    let session = slot.as_ref()?;
    session
        .submitted
        .lock()
        .unwrap_or_else(|poisoned| poisoned.into_inner())
        .take()
}

pub fn stop() {
    let previous = session_slot()
        .lock()
        .unwrap_or_else(|poisoned| poisoned.into_inner())
        .take();
    if let Some(session) = previous
        && let Some(sender) = session
            .shutdown
            .lock()
            .unwrap_or_else(|poisoned| poisoned.into_inner())
            .take()
    {
        sender.send(()).ok();
    }
}

fn routes(
    session: Arc<Session>,
) -> impl warp::Filter<Extract = (warp::http::Response<String>,), Error = warp::Rejection> + Clone {
    let page = warp::get()
        .and(warp::path::param::<String>())
        .and(warp::path::end())
        .map(|lang: String| {
            if !lang_is_known(&lang) {
                return html_reply(PAGE_EN, warp::http::StatusCode::NOT_FOUND);
            }
            html_reply(page_for_lang(&lang), warp::http::StatusCode::OK)
        });

    let submit_session = Arc::clone(&session);
    let submit = warp::post()
        .and(warp::path("submit"))
        .and(warp::path::end())
        .and(warp::body::content_length_limit(
            u64::try_from(MAX_URL_LEN + 256).unwrap_or(4096),
        ))
        .and(warp::body::json())
        .map(move |body: SubmitBody| accept_submission(&submit_session, body));

    page.or(submit)
}

#[derive(Deserialize)]
struct SubmitBody {
    code: String,
    url: String,
}

fn html_reply(body: &str, status: warp::http::StatusCode) -> warp::http::Response<String> {
    warp::http::Response::builder()
        .status(status)
        .header("content-type", "text/html; charset=utf-8")
        .body(body.to_string())
        .unwrap_or_else(|_| warp::http::Response::new(String::new()))
}

fn json_reply(body: &str, status: warp::http::StatusCode) -> warp::http::Response<String> {
    warp::http::Response::builder()
        .status(status)
        .header("content-type", "application/json")
        .body(body.to_string())
        .unwrap_or_else(|_| warp::http::Response::new(String::new()))
}

fn accept_submission(session: &Session, body: SubmitBody) -> warp::http::Response<String> {
    if body.code != session.code {
        return json_reply(r#"{"ok":false,"error":"code"}"#, warp::http::StatusCode::FORBIDDEN);
    }
    let Some(url) = acceptable_profile_url(&body.url) else {
        return json_reply(r#"{"ok":false,"error":"url"}"#, warp::http::StatusCode::BAD_REQUEST);
    };
    *session
        .submitted
        .lock()
        .unwrap_or_else(|poisoned| poisoned.into_inner()) = Some(url);
    json_reply(r#"{"ok":true}"#, warp::http::StatusCode::OK)
}

fn lang_is_known(lang: &str) -> bool {
    matches!(lang, "en" | "zh")
}

fn page_for_lang(lang: &str) -> &'static str {
    if lang == "zh" { PAGE_ZH } else { PAGE_EN }
}

fn page_urls(port: u16) -> Vec<String> {
    super::network::lan_ipv4_addresses()
        .into_iter()
        .map(|host| format!("http://{host}:{port}/"))
        .collect()
}

fn random_code() -> Result<String> {
    const ALPHABET: &[u8] = b"ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    let mut bytes = [0u8; 6];
    getrandom::fill(&mut bytes).context("failed to read pairing-code entropy")?;
    Ok(bytes
        .iter()
        .map(|byte| ALPHABET[(*byte as usize) % ALPHABET.len()] as char)
        .collect())
}

pub fn acceptable_profile_url(raw: &str) -> Option<String> {
    let trimmed = raw.trim();
    if trimmed.is_empty() || trimmed.len() > MAX_URL_LEN || trimmed.chars().any(char::is_control) {
        return None;
    }
    let url = tauri::Url::parse(trimmed).ok()?;
    if url.scheme() != "http" && url.scheme() != "https" {
        return None;
    }
    if url.host_str().is_none() {
        return None;
    }
    Some(trimmed.to_string())
}

#[cfg(test)]
pub fn reject_bad_submission(code: &str, expected: &str, url: &str) -> Result<String> {
    if code != expected {
        bail!("pairing code does not match");
    }
    acceptable_profile_url(url).context("profile URL must be an http or https address")
}

#[cfg(test)]
mod tests {
    use super::{PAGE_EN, PAGE_ZH, acceptable_profile_url, reject_bad_submission};

    #[test]
    fn pages_expose_the_submission_form() {
        assert!(PAGE_EN.contains("id=\"profile-url\""));
        assert!(PAGE_ZH.contains("id=\"profile-url\""));
        assert!(PAGE_EN.contains("/submit"));
        assert!(PAGE_ZH.contains("/submit"));
    }

    #[test]
    fn only_http_urls_are_accepted() {
        assert_eq!(
            acceptable_profile_url("  https://example.com/sub?token=1  ").as_deref(),
            Some("https://example.com/sub?token=1")
        );
        assert!(acceptable_profile_url("javascript:alert(1)").is_none());
        assert!(acceptable_profile_url("file:///tmp/a.yaml").is_none());
        assert!(acceptable_profile_url("not a url").is_none());
    }

    #[test]
    fn a_wrong_code_is_rejected() {
        assert!(reject_bad_submission("AAAAAA", "BBBBBB", "https://example.com/a").is_err());
        assert_eq!(
            reject_bad_submission("BBBBBB", "BBBBBB", "https://example.com/a").unwrap_or_default(),
            "https://example.com/a"
        );
    }
}
