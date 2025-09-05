import { ReactNode } from 'react'

interface LoadingStateProps {
  isLoading: boolean
  children: ReactNode
  loadingText?: string
  className?: string
}

export function LoadingState({ 
  isLoading, 
  children, 
  loadingText = "Cargando...",
  className = "" 
}: LoadingStateProps) {
  if (!isLoading) return <>{children}</>

  return (
    <div className={`fixed top-4 right-4 z-50 ${className}`}>
      <div className="bg-primary text-primary-foreground px-4 py-2 rounded-lg shadow-lg flex items-center space-x-2">
        <div className="animate-spin rounded-full h-4 w-4 border-2 border-primary-foreground border-t-transparent" />
        <span className="text-sm font-medium">{loadingText}</span>
      </div>
    </div>
  )
}

interface EmptyStateProps {
  title: string
  description?: string
  action?: ReactNode
  icon?: ReactNode
  className?: string
}

export function EmptyState({ 
  title, 
  description, 
  action, 
  icon,
  className = "" 
}: EmptyStateProps) {
  return (
    <div className={`text-center py-12 ${className}`}>
      {icon && (
        <div className="mx-auto mb-4 text-muted-foreground">
          {icon}
        </div>
      )}
      <h3 className="text-lg font-semibold text-gray-900 mb-2">{title}</h3>
      {description && (
        <p className="text-muted-foreground mb-6 max-w-md mx-auto">
          {description}
        </p>
      )}
      {action && action}
    </div>
  )
}

interface ErrorStateProps {
  title?: string
  message: string
  onRetry?: () => void
  className?: string
}

export function ErrorState({ 
  title = "Algo salió mal",
  message, 
  onRetry,
  className = "" 
}: ErrorStateProps) {
  return (
    <div className={`text-center py-12 ${className}`}>
      <div className="mx-auto mb-4 w-12 h-12 bg-destructive/10 rounded-full flex items-center justify-center">
        <svg className="w-6 h-6 text-destructive" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
        </svg>
      </div>
      <h3 className="text-lg font-semibold text-foreground mb-2">{title}</h3>
      <p className="text-destructive mb-6 max-w-md mx-auto">{message}</p>
      {onRetry && (
        <button 
          onClick={onRetry}
          className="bg-destructive text-destructive-foreground px-4 py-2 rounded-md hover:bg-destructive/90 transition-colors"
        >
          Intentar de nuevo
        </button>
      )}
    </div>
  )
}
