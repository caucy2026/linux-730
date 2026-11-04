import { Box, Typography } from '@mui/material'
import { QRCodeSVG } from 'qrcode.react'
import { useEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'

import { BaseDialog } from '@/components/base'
import {
  type LanProfileInput,
  startLanProfileInput,
  stopLanProfileInput,
  takeLanProfileSubmission,
} from '@/services/profile-lan-input'

interface Props {
  open: boolean
  onClose: () => void
  onBackfill: (url: string) => void
}

export function LanInputDialog({ open, onClose, onBackfill }: Props) {
  const { t, i18n } = useTranslation()
  const [session, setSession] = useState<LanProfileInput | null>(null)
  const [error, setError] = useState('')
  const onBackfillRef = useRef(onBackfill)
  onBackfillRef.current = onBackfill

  useEffect(() => {
    if (!open) {
      setSession(null)
      setError('')
      return
    }

    let cancelled = false
    let timer = 0

    const openSession = async () => {
      try {
        const next = await startLanProfileInput()
        if (cancelled) {
          await stopLanProfileInput()
          return
        }
        setSession(next)
        timer = window.setInterval(() => {
          void takeLanProfileSubmission().then((url) => {
            if (!cancelled && url) onBackfillRef.current(url)
          })
        }, 1000)
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : String(err))
        }
      }
    }

    void openSession()
    return () => {
      cancelled = true
      window.clearInterval(timer)
      void stopLanProfileInput()
    }
  }, [open])

  const lang = i18n.language?.toLowerCase().startsWith('zh') ? 'zh' : 'en'
  const page = session?.urls[0]
  const scanUrl = page
    ? `${page}${lang}?code=${encodeURIComponent(session?.code ?? '')}`
    : ''

  return (
    <BaseDialog
      open={open}
      title={t('profiles.page.importForm.lan.title')}
      cancelBtn={t('shared.actions.close')}
      disableOk
      onCancel={onClose}
      onClose={onClose}
    >
      <Typography variant="body2" sx={{ mb: 1.5 }}>
        {t('profiles.page.importForm.lan.hint')}
      </Typography>
      {error ? (
        <Typography color="error" variant="body2">
          {t('profiles.page.importForm.lan.failed')} {error}
        </Typography>
      ) : null}
      {session && session.urls.length === 0 ? (
        <Typography variant="body2">
          {t('profiles.page.importForm.lan.empty')}
        </Typography>
      ) : null}
      {session ? (
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
          <Typography variant="body2">
            {t('profiles.page.importForm.lan.code')}: {session.code}
          </Typography>
          {session.urls.map((url) => (
            <Typography key={url} variant="body2" sx={{ wordBreak: 'break-all' }}>
              {url}
              {lang}
            </Typography>
          ))}
          {scanUrl ? (
            <Box
              sx={{
                display: 'flex',
                justifyContent: 'center',
                p: 2,
                bgcolor: '#fff',
                borderRadius: 1,
              }}
            >
              <QRCodeSVG value={scanUrl} size={220} level="M" />
            </Box>
          ) : null}
          <Typography variant="body2" color="text.secondary">
            {t('profiles.page.importForm.lan.waiting')}
          </Typography>
        </Box>
      ) : null}
    </BaseDialog>
  )
}
