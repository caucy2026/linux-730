import { Channel } from '@tauri-apps/api/core'

import { commands } from '@/services/bindings'
import { mutate } from '@/services/mutate'

export async function openProfileLanInput(
  locale: string,
  onAddress: (value: string) => void,
) {
  let released = false
  let closing: Promise<void> | undefined
  const channel = new Channel<string>()
  channel.onmessage = (value) => {
    if (!released) onAddress(value)
  }
  const result = await mutate(
    () => commands.startProfileLanInput(locale, channel),
    { id: 'profile-lan-input', errorNotice: false },
  )
  if (!result.ok) throw new Error('LAN_INPUT_BUSY')
  return {
    info: result.value,
    close: () => {
      released = true
      channel.onmessage = () => {}
      closing ??= mutate(() => commands.stopProfileLanInput(result.value.id), {
        id: 'profile-lan-input',
        errorNotice: false,
      }).then(() => {})
      return closing
    },
  }
}
