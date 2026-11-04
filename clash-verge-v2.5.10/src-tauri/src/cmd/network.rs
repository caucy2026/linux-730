use super::CmdResult;
use crate::cmd::StringifyErr as _;
use crate::core::{proxy_control, sysopt::Sysopt};

use gethostname::gethostname;
use sysproxy::{Autoproxy, Sysproxy};
use tauri_plugin_clash_verge_sysinfo;

#[tauri::command]
#[specta::specta]
pub async fn get_sys_proxy() -> CmdResult<SystemProxy> {
    Sysopt::global().wait_idle().await;
    // With no network service there is no proxy configured anywhere, which reads as disabled.
    let sys_proxy = match Sysproxy::get_system_proxy() {
        Err(error) if proxy_control::is_missing_network_service(&error) => Sysproxy::default(),
        other => other.stringify_err()?,
    };
    let Sysproxy {
        host,
        bypass,
        port,
        enable,
    } = sys_proxy;

    Ok(SystemProxy {
        enable,
        server: format!("{host}:{port}"),
        bypass,
    })
}

#[tauri::command]
#[specta::specta]
pub async fn get_auto_proxy() -> CmdResult<AutoProxy> {
    Sysopt::global().wait_idle().await;
    let auto_proxy = match Autoproxy::get_auto_proxy() {
        Err(error) if proxy_control::is_missing_network_service(&error) => Autoproxy::default(),
        other => other.stringify_err()?,
    };
    let Autoproxy { enable, url } = auto_proxy;

    Ok(AutoProxy { enable, url })
}

#[tauri::command]
#[specta::specta]
pub fn get_embedded_server_port() -> CmdResult<u16> {
    crate::utils::server::embedded_server_port().stringify_err()
}

#[tauri::command]
#[specta::specta]
pub fn get_system_hostname() -> String {
    match gethostname().into_string() {
        Ok(name) => name,
        Err(os_string) => {
            let fallback = format!("{os_string:?}");
            fallback.trim_matches('"').to_string()
        }
    }
}

#[tauri::command]
#[specta::specta]
pub fn get_network_interfaces() -> Vec<String> {
    tauri_plugin_clash_verge_sysinfo::list_network_interfaces()
}

#[tauri::command]
#[specta::specta]
pub fn get_network_interfaces_info() -> CmdResult<Vec<crate::ipc::NetworkInterfaceView>> {
    use network_interface::{NetworkInterface, NetworkInterfaceConfig as _};

    let names = get_network_interfaces();
    let interfaces = NetworkInterface::show().stringify_err()?;

    let mut result = Vec::new();

    for interface in interfaces {
        if names.contains(&interface.name) {
            result.push(interface.into());
        }
    }

    Ok(result)
}

#[derive(serde::Serialize, specta::Type)]
pub struct SystemProxy {
    pub enable: bool,
    pub server: String,
    pub bypass: String,
}

#[derive(serde::Serialize, specta::Type)]
pub struct AutoProxy {
    pub enable: bool,
    pub url: String,
}

#[derive(serde::Serialize, specta::Type)]
pub struct LanProfileInput {
    pub port: u16,
    pub code: String,
    pub urls: Vec<String>,
}

fn lan_view(session: crate::utils::lan_profile_input::LanProfileSession) -> LanProfileInput {
    LanProfileInput {
        port: session.port,
        code: session.code,
        urls: session.urls,
    }
}

/// Open the LAN page that accepts a profile URL from another device.
#[tauri::command]
#[specta::specta]
pub async fn start_lan_profile_input() -> CmdResult<LanProfileInput> {
    crate::utils::lan_profile_input::start()
        .await
        .map(lan_view)
        .stringify_err()
}

/// Describe the open LAN page, if one is running.
#[tauri::command]
#[specta::specta]
pub fn get_lan_profile_input() -> CmdResult<Option<LanProfileInput>> {
    Ok(crate::utils::lan_profile_input::current().map(lan_view))
}

/// Take one submitted profile URL so the import field can be backfilled.
#[tauri::command]
#[specta::specta]
pub fn take_lan_profile_submission() -> CmdResult<Option<String>> {
    Ok(crate::utils::lan_profile_input::take_submission())
}

/// Close the LAN page and drop any URL still held in memory.
#[tauri::command]
#[specta::specta]
pub fn stop_lan_profile_input() -> CmdResult {
    crate::utils::lan_profile_input::stop();
    Ok(())
}
