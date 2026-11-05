use crate::{ipc::LanProfileInputSession, process::AsyncHandler};
use network_interface::{Addr, NetworkInterface, NetworkInterfaceConfig as _};
use parking_lot::Mutex;
use serde::Deserialize;
use std::{
    convert::Infallible,
    sync::{
        Arc, LazyLock,
        atomic::{AtomicBool, Ordering},
    },
    time::{Duration, Instant},
};
use tauri::ipc::Channel;
use tokio::{net::TcpListener, sync::oneshot};
use warp::{Filter as _, http::StatusCode};

const TTL: Duration = Duration::from_secs(180);
static CURRENT: LazyLock<Mutex<Option<Arc<Session>>>> = LazyLock::new(|| Mutex::new(None));

struct Session {
    id: String,
    token: String,
    host: String,
    chinese: bool,
    deadline: Instant,
    active: AtomicBool,
    deliver: Arc<dyn Fn(String) -> bool + Send + Sync>,
    stop: Mutex<Option<oneshot::Sender<()>>>,
}
impl Session {
    fn close(&self) {
        self.active.store(false, Ordering::Release);
        if let Some(stop) = self.stop.lock().take() {
            let _ = stop.send(());
        }
    }
    fn valid(&self, token: &str, host: Option<&str>, origin: Option<&str>) -> bool {
        self.active.load(Ordering::Acquire)
            && Instant::now() < self.deadline
            && token == self.token
            && host == Some(self.host.as_str())
            && origin.is_none_or(|value| value == format!("http://{}", self.host))
    }
}
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct AddressInput {
    address: String,
}
#[derive(Debug)]
struct Denied;
impl warp::reject::Reject for Denied {}

fn response(text: &str, status: StatusCode) -> warp::http::Response<String> {
    warp::http::Response::builder()
        .status(status)
        .header("Content-Type", "text/html; charset=utf-8")
        .header("Cache-Control", "no-store")
        .header("Referrer-Policy", "same-origin")
        .header("X-Content-Type-Options", "nosniff")
        .header(
            "Content-Security-Policy",
            "default-src 'none'; style-src 'unsafe-inline'; form-action 'self'; frame-ancestors 'none'",
        )
        .body(text.to_owned())
        .unwrap_or_default()
}
fn routes(session: Arc<Session>) -> impl warp::Filter<Extract = (impl warp::Reply,), Error = Infallible> + Clone {
    let chinese = session.chinese;
    let admit = warp::path!("input" / String)
        .and(warp::header::optional::<String>("host"))
        .and(warp::header::optional::<String>("origin"))
        .and(warp::any().map(move || session.clone()))
        .and_then(
            |token: String, host: Option<String>, origin: Option<String>, session: Arc<Session>| async move {
                if session.valid(&token, host.as_deref(), origin.as_deref()) {
                    Ok(session)
                } else {
                    Err(warp::reject::custom(Denied))
                }
            },
        );
    let form = admit.clone().and(warp::get()).map(|session: Arc<Session>| {
        let page = if session.chinese {
            include_str!("lan-input-zh.html")
        } else {
            include_str!("lan-input-en.html")
        };
        response(page, StatusCode::OK)
    });
    let submit = admit
        .and(warp::post())
        .and(warp::body::content_length_limit(8192))
        .and(warp::body::form::<AddressInput>())
        .map(|session: Arc<Session>, input: AddressInput| {
            let address = input.address.trim();
            let valid = address.len() <= 4096
                && !address.chars().any(char::is_control)
                && reqwest::Url::parse(address).is_ok_and(|url| matches!(url.scheme(), "http" | "https"));
            if !valid {
                return response(
                    if session.chinese {
                        "地址无效，请输入以 http:// 或 https:// 开头的地址。"
                    } else {
                        "Invalid address"
                    },
                    StatusCode::BAD_REQUEST,
                );
            }
            if Instant::now() >= session.deadline
                || session
                    .active
                    .compare_exchange(true, false, Ordering::AcqRel, Ordering::Acquire)
                    .is_err()
            {
                return response(
                    if session.chinese {
                        "输入已结束，请重新扫码。"
                    } else {
                        "Input session has ended"
                    },
                    StatusCode::GONE,
                );
            }
            let delivered = (session.deliver)(address.to_owned());
            session.close();
            if !delivered {
                return response(
                    if session.chinese {
                        "电脑端输入已关闭。"
                    } else {
                        "Desktop input is closed"
                    },
                    StatusCode::GONE,
                );
            }
            response(
                if session.chinese {
                    "<meta charset=utf-8><p>地址已回填。请返回电脑，核对后点击导入。</p>"
                } else {
                    "<p>Address received. Review it on the desktop and click Import.</p>"
                },
                StatusCode::OK,
            )
        });
    form.or(submit).recover(move |error: warp::Rejection| async move {
        let status = if error.find::<Denied>().is_some() {
            StatusCode::FORBIDDEN
        } else if error.is_not_found() {
            StatusCode::NOT_FOUND
        } else {
            StatusCode::BAD_REQUEST
        };
        Ok::<_, Infallible>(response(
            if chinese {
                "输入请求不可用，请重新扫码。"
            } else {
                "Input request rejected"
            },
            status,
        ))
    })
}

pub async fn start(locale: String, on_address: Channel<String>) -> Result<LanProfileInputSession, &'static str> {
    let mut interfaces = NetworkInterface::show().map_err(|_| "LAN_INPUT_INTERFACE_FAILED")?;
    interfaces.sort_by_key(|interface| interface.name.clone());
    let address = interfaces
        .into_iter()
        .filter(|interface| {
            !["lo", "docker", "veth", "virbr", "br-", "tun", "tap", "clash"]
                .iter()
                .any(|prefix| interface.name.to_lowercase().starts_with(prefix))
        })
        .flat_map(|interface| interface.addr)
        .find_map(|address| match address {
            Addr::V4(value) if value.ip.is_private() => Some(value.ip),
            _ => None,
        })
        .ok_or("LAN_INPUT_NO_PRIVATE_INTERFACE")?;
    let listener = TcpListener::bind((address, 0))
        .await
        .map_err(|_| "LAN_INPUT_BIND_FAILED")?;
    let port = listener.local_addr().map_err(|_| "LAN_INPUT_BIND_FAILED")?.port();
    let host = format!("{address}:{port}");
    let id = nanoid::nanoid!(16);
    let token = nanoid::nanoid!(32);
    let (stop, stopped) = oneshot::channel();
    let session = Arc::new(Session {
        id: id.clone(),
        token: token.clone(),
        host: host.clone(),
        chinese: locale.starts_with("zh"),
        deadline: Instant::now() + TTL,
        active: AtomicBool::new(true),
        deliver: Arc::new(move |address| on_address.send(address).is_ok()),
        stop: Mutex::new(Some(stop)),
    });
    if let Some(previous) = CURRENT.lock().replace(session.clone()) {
        previous.close();
    }
    let server_session = session.clone();
    AsyncHandler::spawn(move || async move {
        let shutdown = session.clone();
        warp::serve(routes(server_session))
            .incoming(listener)
            .graceful(async move {
                tokio::select! { _ = stopped => {}, _ = tokio::time::sleep(TTL) => {} }
                shutdown.close();
            })
            .run()
            .await;
        let mut current = CURRENT.lock();
        if current.as_ref().is_some_and(|value| value.id == session.id) {
            current.take();
        }
    });
    Ok(LanProfileInputSession {
        id: id.clone(),
        url: format!("http://{host}/input/{token}"),
        expires_in_seconds: TTL.as_secs() as u32,
    })
}
pub fn stop(id: &str) {
    let mut current = CURRENT.lock();
    if current.as_ref().is_some_and(|value| value.id == id)
        && let Some(session) = current.take()
    {
        session.close();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    fn session(deadline: Instant, accept: bool) -> (Arc<Session>, Arc<Mutex<Vec<String>>>) {
        let received = Arc::new(Mutex::new(Vec::new()));
        let sink = received.clone();
        (
            Arc::new(Session {
                id: "owner".into(),
                token: "capability".into(),
                host: "127.0.0.1:12000".into(),
                chinese: false,
                deadline,
                active: AtomicBool::new(true),
                deliver: Arc::new(move |value| {
                    if accept {
                        sink.lock().push(value);
                    }
                    accept
                }),
                stop: Mutex::new(None),
            }),
            received,
        )
    }
    #[tokio::test]
    async fn admitted_address_is_delivered_once_without_echo() {
        let (session, received) = session(Instant::now() + TTL, true);
        let api = routes(session.clone());
        let wrong = warp::test::request()
            .method("GET")
            .path("/input/wrong")
            .header("host", "127.0.0.1:12000")
            .reply(&api)
            .await;
        assert_eq!(wrong.status(), 403);
        let foreign = warp::test::request()
            .method("POST")
            .path("/input/capability")
            .header("host", "127.0.0.1:12000")
            .header("origin", "http://foreign.invalid")
            .reply(&api)
            .await;
        assert_eq!(foreign.status(), 403);
        let body = "address=https%3A%2F%2Fexample.invalid%2Fone";
        let response = warp::test::request()
            .method("POST")
            .path("/input/capability")
            .header("host", "127.0.0.1:12000")
            .header("origin", "http://127.0.0.1:12000")
            .header("content-type", "application/x-www-form-urlencoded")
            .header("content-length", body.len())
            .body(body)
            .reply(&api)
            .await;
        assert_eq!(response.status(), 200);
        assert_eq!(&*received.lock(), &["https://example.invalid/one"]);
        assert!(!String::from_utf8_lossy(response.body()).contains("example.invalid"));
        assert_eq!(
            response.headers().get("cache-control").and_then(|v| v.to_str().ok()),
            Some("no-store")
        );
        let repeat = warp::test::request()
            .method("GET")
            .path("/input/capability")
            .header("host", "127.0.0.1:12000")
            .reply(&api)
            .await;
        assert_eq!(repeat.status(), 403);
        assert_eq!(received.lock().len(), 1);
    }
    #[tokio::test]
    async fn invalid_and_oversized_input_cannot_consume_the_session() {
        let (session, received) = session(Instant::now() + TTL, true);
        let api = routes(session.clone());
        for body in [
            "address=file%3A%2F%2F%2Fetc%2Fpasswd".to_owned(),
            "address=".to_owned(),
            "x".repeat(8193),
        ] {
            let result = warp::test::request()
                .method("POST")
                .path("/input/capability")
                .header("host", "127.0.0.1:12000")
                .header("content-type", "application/x-www-form-urlencoded")
                .header("content-length", body.len())
                .body(body)
                .reply(&api)
                .await;
            assert_ne!(result.status(), 200);
            assert!(session.active.load(Ordering::Acquire));
            assert!(received.lock().is_empty());
        }
    }
    #[tokio::test]
    async fn expiry_cancellation_and_closed_desktop_reject_delivery() {
        let (expired, _) = session(Instant::now() - Duration::from_secs(1), true);
        assert!(!expired.valid("capability", Some("127.0.0.1:12000"), None));
        let (closed, _) = session(Instant::now() + TTL, true);
        closed.close();
        assert!(!closed.valid("capability", Some("127.0.0.1:12000"), None));
        let (session, received) = session(Instant::now() + TTL, false);
        let body = "address=https%3A%2F%2Fexample.invalid";
        let result = warp::test::request()
            .method("POST")
            .path("/input/capability")
            .header("host", "127.0.0.1:12000")
            .header("content-type", "application/x-www-form-urlencoded")
            .header("content-length", body.len())
            .body(body)
            .reply(&routes(session.clone()))
            .await;
        assert_eq!(result.status(), 410);
        assert!(received.lock().is_empty());
        assert!(!session.active.load(Ordering::Acquire));
    }
}
