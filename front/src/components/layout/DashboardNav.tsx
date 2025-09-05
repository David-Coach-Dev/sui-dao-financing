import { Button } from "../ui/button"
import { Sheet, SheetContent, SheetTrigger } from "../ui/sheet"
import { Avatar, AvatarFallback } from "../ui/avatar"
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuLabel, 
  DropdownMenuSeparator, 
  DropdownMenuTrigger 
} from "../ui/dropdown-menu"
import { Bell, Menu, Search, Settings, LogOut, Wallet, User } from "lucide-react"
import { Input } from "../ui/input"
import { formatAddress, formatSUI, useLanguageStore } from "../../store"
import { ThemeToggle } from "../ThemeToggle"
import { LanguageToggle } from "../LanguageToggle"
import type { WalletInfo } from "../../store"

interface DashboardNavProps {
  wallet: WalletInfo | null
  isConnected: boolean
  isConnecting: boolean
  onConnectWallet: () => Promise<void>
  onDisconnectWallet: () => void
  sidebarContent: React.ReactNode
  className?: string
}

export function DashboardNav({
  wallet,
  isConnected,
  isConnecting,
  onConnectWallet,
  onDisconnectWallet,
  sidebarContent,
  className = ""
}: DashboardNavProps) {
  const { t } = useLanguageStore()
  return (
    <header className={`sticky top-0 flex h-16 items-center gap-4 border-b bg-background px-4 md:px-6 ${className}`}>
      {/* Mobile menu */}
      <Sheet>
        <SheetTrigger asChild>
          <Button variant="outline" size="icon" className="shrink-0 md:hidden">
            <Menu className="h-5 w-5" />
            <span className="sr-only">Toggle navigation menu</span>
          </Button>
        </SheetTrigger>
        <SheetContent side="left" className="flex flex-col">
          {sidebarContent}
        </SheetContent>
      </Sheet>

      {/* Logo and title */}
      <div className="flex items-center gap-2 md:gap-4">
        <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
          <span className="text-primary-foreground font-bold text-sm">S</span>
        </div>
        <div className="hidden md:block">
          <h1 className="text-lg font-semibold text-foreground">Sui DAO</h1>
        </div>
      </div>

      {/* Search */}
      <div className="flex w-full gap-4 md:ml-auto md:gap-2 lg:gap-4">
        <form className="ml-auto flex-1 sm:flex-initial">
          <div className="relative">
            <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input
              type="search"
              placeholder={t('search', 'dashboard')}
              className="pl-8 sm:w-[300px] md:w-[200px] lg:w-[300px]"
            />
          </div>
        </form>

        {/* Notifications */}
        <Button variant="outline" size="icon" className="relative">
          <Bell className="h-4 w-4" />
          <span className="absolute -top-1 -right-1 h-4 w-4 bg-destructive rounded-full text-xs text-destructive-foreground flex items-center justify-center">
            3
          </span>
          <span className="sr-only">{t('notifications', 'dashboard')}</span>
        </Button>

        {/* Theme Toggle */}
        <ThemeToggle />

        {/* Language Toggle */}
        <LanguageToggle />

        {/* User menu */}
        {isConnected && wallet ? (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" className="flex items-center gap-2 px-3">
                <Avatar className="h-6 w-6">
                  <AvatarFallback className="bg-primary text-primary-foreground text-xs">
                    {wallet.address.slice(2, 4).toUpperCase()}
                  </AvatarFallback>
                </Avatar>
                <div className="hidden md:flex flex-col items-start">
                  <span className="text-sm font-medium">
                    {formatAddress(wallet.address)}
                  </span>
                  <span className="text-xs text-muted-foreground">
                    {formatSUI(wallet.balance)} SUI
                  </span>
                </div>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56">
              <DropdownMenuLabel className="font-normal">
                <div className="flex flex-col space-y-1">
                  <p className="text-sm font-medium leading-none">{t('myWallet', 'dashboard')}</p>
                  <p className="text-xs leading-none text-muted-foreground">
                    {formatAddress(wallet.address)}
                  </p>
                </div>
              </DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuItem>
                <User className="mr-2 h-4 w-4" />
                <span>{t('profile', 'dashboard')}</span>
              </DropdownMenuItem>
              <DropdownMenuItem>
                <Wallet className="mr-2 h-4 w-4" />
                <span>{t('balance', 'dashboard')}: {formatSUI(wallet.balance)} SUI</span>
              </DropdownMenuItem>
              <DropdownMenuItem>
                <Settings className="mr-2 h-4 w-4" />
                <span>{t('settings', 'dashboard')}</span>
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={onDisconnectWallet}>
                <LogOut className="mr-2 h-4 w-4" />
                <span>{t('disconnect', 'dashboard')}</span>
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        ) : (
          <Button 
            onClick={onConnectWallet}
            disabled={isConnecting}
            className="bg-primary hover:bg-primary/90 text-primary-foreground"
          >
            <Wallet className="h-4 w-4 mr-2" />
            {isConnecting ? t('connecting', 'dashboard') : t('connect', 'dashboard')}
          </Button>
        )}
      </div>
    </header>
  )
}
