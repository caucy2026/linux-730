import { invoke } from '@tauri-apps/api/core'

export interface LanProfileInput {
  port: number
  code: string
  urls: string[]
}

export function startLanProfileInput() {
  return invoke<LanProfileInput>('start_lan_profile_input')
}

export function getLanProfileInput() {
  return invoke<LanProfileInput | null>('get_lan_profile_input')
}

export function takeLanProfileSubmission() {
  return invoke<string | null>('take_lan_profile_submission')
}

export function stopLanProfileInput() {
  return invoke<null>('stop_lan_profile_input')
}
