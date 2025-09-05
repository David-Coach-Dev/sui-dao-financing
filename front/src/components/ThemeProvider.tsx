import { useEffect } from 'react'
import { useThemeStore } from '../store'

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const { applyTheme } = useThemeStore()

  useEffect(() => {
    // Apply theme on mount
    applyTheme()
  }, [applyTheme])

  return <>{children}</>
}
