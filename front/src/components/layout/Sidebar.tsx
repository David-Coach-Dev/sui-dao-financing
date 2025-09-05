import { cn } from "../../lib/utils"

interface SidebarProps {
  className?: string
  children: React.ReactNode
}

export function Sidebar({ className, children }: SidebarProps) {
  return (
    <div className={cn("pb-12", className)}>
      <div className="space-y-4 py-4">
        {children}
      </div>
    </div>
  )
}

interface SidebarNavProps {
  className?: string
  items: {
    title: string
    href: string
    icon: React.ComponentType<{ className?: string }>
    isActive?: boolean
    badge?: string | number
  }[]
  onItemClick?: (href: string) => void
}

export function SidebarNav({ className, items, onItemClick }: SidebarNavProps) {
  return (
    <nav className={cn("grid items-start px-2 text-sm font-medium lg:px-4", className)}>
      {items.map((item) => (
        <button
          key={item.href}
          onClick={() => onItemClick?.(item.href)}
          className={cn(
            "flex items-center gap-3 rounded-lg px-3 py-2 text-muted-foreground transition-all hover:text-primary",
            item.isActive && "bg-muted text-primary"
          )}
        >
          <item.icon className="h-4 w-4" />
          <span>{item.title}</span>
          {item.badge && (
            <span className="ml-auto flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary text-xs text-primary-foreground">
              {item.badge}
            </span>
          )}
        </button>
      ))}
    </nav>
  )
}
