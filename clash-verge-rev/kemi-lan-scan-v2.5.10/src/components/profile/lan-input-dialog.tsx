import {
  Box,
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Typography,
} from '@mui/material'
import { QRCodeSVG } from 'qrcode.react'
import { useEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'

import { showNotice } from '@/services/notice-service'
import { openProfileLanInput } from '@/services/profile-lan-input'

type InputHandle = Awaited<ReturnType<typeof openProfileLanInput>>
interface Props {
  open: boolean
  onClose: () => void
  onAddress: (value: string) => void
}

export const LanInputDialog = ({ open, onClose, onAddress }: Props) => {
  const { t, i18n } = useTranslation()
  const [value, setValue] = useState<string | null>(null)
  const [state, setState] = useState<
    'loading' | 'ready' | 'expired' | 'failed'
  >('loading')
  const addressRef = useRef(onAddress)
  const closeRef = useRef(onClose)
  addressRef.current = onAddress
  closeRef.current = onClose

  useEffect(() => {
    if (!open) return
    let disposed = false
    let handle: InputHandle | undefined
    let timer: ReturnType<typeof setTimeout> | undefined
    setValue(null)
    setState('loading')
    const closeInput = (input: InputHandle) => {
      void input
        .close()
        .catch(() => showNotice.error('profiles.modals.lanInput.closeFailed'))
    }
    void openProfileLanInput(i18n.language, (address) => {
      if (disposed) return
      addressRef.current(address)
      closeRef.current()
    })
      .then((input) => {
        if (disposed) {
          closeInput(input)
          return
        }
        handle = input
        setValue(input.info.url)
        setState('ready')
        timer = setTimeout(() => {
          if (disposed) return
          setValue(null)
          setState('expired')
          closeInput(input)
        }, input.info.expiresInSeconds * 1000)
      })
      .catch(() => {
        if (!disposed) setState('failed')
      })
    return () => {
      disposed = true
      if (timer) clearTimeout(timer)
      if (handle) closeInput(handle)
    }
  }, [open, i18n.language])

  return (
    <Dialog open={open} onClose={onClose} maxWidth="xs" fullWidth>
      <DialogTitle>{t('profiles.modals.lanInput.title')}</DialogTitle>
      <DialogContent>
        <Typography variant="body2" sx={{ mb: 2 }}>
          {t('profiles.modals.lanInput.hint')}
        </Typography>
        {value && state === 'ready' ? (
          <Box
            sx={{
              display: 'flex',
              justifyContent: 'center',
              p: 2,
              bgcolor: '#fff',
              borderRadius: 1,
            }}
          >
            <QRCodeSVG value={value} size={240} level="M" />
          </Box>
        ) : (
          <Typography>{t(`profiles.modals.lanInput.${state}`)}</Typography>
        )}
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>{t('shared.actions.close')}</Button>
      </DialogActions>
    </Dialog>
  )
}
