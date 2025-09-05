import { Button } from '../ui/button'
import { Avatar, AvatarFallback } from '../ui/avatar'
import { Bell, Settings, Wallet, LogOut } from 'lucide-react'
import { formatAddress, formatSUI } from '../../store'
import type { WalletInfo } from '../../store'

interface DashboardHeaderProps {
  title: string
  subtitle?: string
  wallet: WalletInfo | null
  isConnected: boolean
  isConnecting: boolean
  onConnectWallet: () => Promise<void>
  onDisconnectWallet: () => void
  className?: string
}

export function DashboardHeader({
  title,
  subtitle,
  wallet,
  isConnected,
  isConnecting,
  onConnectWallet,
  onDisconnectWallet,
  className = ""
}: DashboardHeaderProps) {
  return (
    <header className={`border-b bg-white/95 backdrop-blur supports-[backdrop-filter]:bg-white/60 ${className}`}>
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          {/* Logo y título */}
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-primary rounded-lg flex items-center justify-center">
                <span className="text-primary-foreground font-bold text-lg">S</span>
              </div>
              <div>
                <h1 className="text-2xl font-bold text-foreground">{title}</h1>
                {subtitle && (
                  <p className="text-sm text-muted-foreground">{subtitle}</p>
                )}
              </div>
            </div>
          </div>
          
          {/* Acciones del usuario */}
          <div className="flex items-center space-x-3">
            {/* Notificaciones */}
            <Button variant="ghost" size="icon" className="relative">
              <Bell className="h-5 w-5" />
              <span className="absolute -top-1 -right-1 h-4 w-4 bg-destructive rounded-full text-xs text-destructive-foreground flex items-center justify-center">
                3
              </span>
            </Button>
            
            {/* Wallet Section */}
            {isConnected && wallet ? (
              <div className="flex items-center space-x-3 bg-secondary rounded-lg px-3 py-2">
                <Avatar className="h-8 w-8">
                  <AvatarFallback className="bg-primary text-primary-foreground text-xs">
                    {wallet.address.slice(2, 4).toUpperCase()}
                  </AvatarFallback>
                </Avatar>
                
                <div className="flex flex-col min-w-0">
                  <span className="text-sm font-medium text-gray-900 truncate">
                    {formatAddress(wallet.address)}
                  </span>
                  <span className="text-xs text-muted-foreground">
                    {formatSUI(wallet.balance)} SUI
                  </span>
                </div>
                
                <div className="flex items-center space-x-1">
                  <div className={`w-2 h-2 rounded-full ${
                    wallet.network === 'mainnet' ? 'bg-green-500' : 
                    wallet.network === 'testnet' ? 'bg-yellow-500' : 'bg-primary'
                  }`} />
                  <span className="text-xs text-muted-foreground capitalize">
                    {wallet.network}
                  </span>
                </div>
                
                <Button 
                  variant="ghost" 
                  size="icon"
                  onClick={onDisconnectWallet}
                  className="h-6 w-6"
                  title="Desconectar wallet"
                >
                  <LogOut className="h-3 w-3" />
                </Button>
              </div>
            ) : (
              <Button 
                onClick={onConnectWallet}
                disabled={isConnecting}
                className="bg-primary hover:bg-primary/90 text-primary-foreground"
              >
                <Wallet className="h-4 w-4 mr-2" />
                {isConnecting ? 'Conectando...' : 'Conectar Wallet'}
              </Button>
            )}
            
            {/* Configuraciones */}
            <Button variant="ghost" size="icon">
              <Settings className="h-5 w-5" />
            </Button>
          </div>
        </div>
      </div>
    </header>
  )
}
