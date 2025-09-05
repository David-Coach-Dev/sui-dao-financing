import { Card, CardContent, CardHeader, CardTitle } from '../ui/card'
import { LucideIcon } from 'lucide-react'

interface StatsCardProps {
  title: string
  value: string | number
  description?: string
  icon: LucideIcon
  trend?: {
    value: string
    isPositive: boolean
  }
  className?: string
}

export function StatsCard({ 
  title, 
  value, 
  description, 
  icon: Icon, 
  trend,
  className = "" 
}: StatsCardProps) {
  return (
    <Card className={className}>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">
          {title}
        </CardTitle>
        <Icon className="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">
          {value}
        </div>
        {(description || trend) && (
          <div className="flex items-center space-x-2 text-xs text-muted-foreground">
            {trend && (
              <span className={trend.isPositive ? "text-green-500" : "text-red-500"}>
                {trend.isPositive ? "+" : ""}{trend.value}
              </span>
            )}
            {description && (
              <span>{description}</span>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
