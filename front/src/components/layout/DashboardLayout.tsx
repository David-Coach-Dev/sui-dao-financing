import { DashboardNav } from "./DashboardNav"
import { Sidebar, SidebarNav } from "./Sidebar"
import { 
  Home, 
  FileText, 
  Users, 
  Settings, 
  BarChart3,
  Plus,
  User,
  Wallet,
  Vote,
  History,
  TrendingUp
} from "lucide-react"
import { useWalletStore, useProposalStore, useDAOStore, useLanguageStore } from "../../store"

interface DashboardLayoutProps {
  children: React.ReactNode
  activeSection?: string
  onSectionChange?: (section: string) => void
}

export function DashboardLayout({ 
  children, 
  activeSection = "dashboard",
  onSectionChange 
}: DashboardLayoutProps) {
  const { 
    wallet, 
    isConnected, 
    isConnecting, 
    connectWallet, 
    disconnectWallet 
  } = useWalletStore()
  
  const { proposals } = useProposalStore()
  const { currentDAO } = useDAOStore()
  const { t } = useLanguageStore()
  
  // Default member count if no DAO is loaded
  const memberCount = 12

  const mainNavItems = [
    {
      title: t('dashboard', 'navigation'),
      href: "dashboard",
      icon: Home,
      isActive: activeSection === "dashboard"
    },
    {
      title: t('proposals', 'navigation'),
      href: "proposals",
      icon: FileText,
      badge: proposals.length,
      isActive: activeSection === "proposals"
    },
    {
      title: t('voting', 'navigation'),
      href: "voting",
      icon: Vote,
      isActive: activeSection === "voting"
    },
    {
      title: t('members', 'navigation'),
      href: "members", 
      icon: Users,
      badge: memberCount,
      isActive: activeSection === "members"
    },
    {
      title: t('treasury', 'navigation'),
      href: "treasury",
      icon: Wallet,
      isActive: activeSection === "treasury"
    },
    {
      title: t('analytics', 'navigation'),
      href: "analytics",
      icon: BarChart3,
      isActive: activeSection === "analytics"
    },
    {
      title: t('history', 'navigation'),
      href: "history",
      icon: History,
      isActive: activeSection === "history"
    }
  ]

  const quickActions = [
    {
      title: t('createProposal', 'navigation'),
      href: "create-proposal",
      icon: Plus,
      isActive: activeSection === "create-proposal"
    },
    {
      title: t('profile', 'navigation'),
      href: "profile",
      icon: User,
      isActive: activeSection === "profile"
    },
    {
      title: t('settings', 'dashboard'),
      href: "settings",
      icon: Settings,
      isActive: activeSection === "settings"
    }
  ]

  const sidebarContent = (
    <Sidebar className="w-full">
      {/* Logo */}
      <div className="px-3 py-2">
        <div className="flex items-center gap-2 px-4">
          <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
            <span className="text-primary-foreground font-bold text-sm">S</span>
          </div>
          <h2 className="text-lg font-semibold tracking-tight">
            {t('title', 'dashboard')}
          </h2>
        </div>
      </div>

      {/* Main Navigation */}
      <div className="px-3 py-2">
        <h3 className="mb-2 px-4 text-sm font-medium text-muted-foreground uppercase tracking-wide">
          {t('main', 'navigation')}
        </h3>
        <SidebarNav items={mainNavItems} onItemClick={onSectionChange} />
      </div>

      {/* Quick Actions */}
      <div className="px-3 py-2">
        <h3 className="mb-2 px-4 text-sm font-medium text-muted-foreground uppercase tracking-wide">
          {t('actions', 'navigation')}
        </h3>
        <SidebarNav items={quickActions} onItemClick={onSectionChange} />
      </div>

      {/* Stats Card */}
      <div className="mx-3 my-4">
        <div className="bg-secondary/50 rounded-lg p-4 border border-border">
          <div className="flex items-center gap-2 mb-2">
            <TrendingUp className="h-4 w-4 text-primary" />
            <span className="text-sm font-medium">{t('activity', 'navigation')}</span>
          </div>
          <p className="text-xs text-muted-foreground">
            {proposals.length} {t('activeProposals', 'navigation')}
          </p>
          <p className="text-xs text-muted-foreground">
            {memberCount} {t('participatingMembers', 'navigation')}
          </p>
        </div>
      </div>
    </Sidebar>
  )

  return (
    <div className="grid min-h-screen w-full md:grid-cols-[220px_1fr] lg:grid-cols-[280px_1fr]">
      {/* Desktop Sidebar */}
      <div className="hidden border-r bg-muted/40 md:block">
        <div className="flex h-full max-h-screen flex-col gap-2">
          <div className="flex h-14 items-center border-b px-4 lg:h-[60px] lg:px-6">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
                <span className="text-primary-foreground font-bold text-sm">S</span>
              </div>
              <span className="font-semibold">{t('title', 'dashboard')}</span>
            </div>
          </div>
          <div className="flex-1 overflow-auto">
            {sidebarContent}
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex flex-col">
        <DashboardNav
          wallet={wallet}
          isConnected={isConnected}
          isConnecting={isConnecting}
          onConnectWallet={connectWallet}
          onDisconnectWallet={disconnectWallet}
          sidebarContent={sidebarContent}
        />
        <main className="flex flex-1 flex-col gap-4 p-4 lg:gap-6 lg:p-6">
          {children}
        </main>
      </div>
    </div>
  )
}
