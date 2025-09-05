import { Tabs, TabsList, TabsTrigger } from '../ui/tabs'
import { Button } from '../ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select'
import { PlusCircle, Filter, SortAsc, SortDesc } from 'lucide-react'
import { ProposalStatus } from '../../store'

interface DashboardTabsProps {
  activeTab: string
  onTabChange: (value: string) => void
  onNewProposal?: () => void
  // Filtros para propuestas
  statusFilter?: ProposalStatus | 'all'
  onStatusFilterChange?: (status: ProposalStatus | 'all') => void
  sortBy?: string
  sortOrder?: 'asc' | 'desc'
  onSortChange?: (sortBy: string, order: 'asc' | 'desc') => void
  children: React.ReactNode
  className?: string
}

export function DashboardTabs({
  activeTab,
  onTabChange,
  onNewProposal,
  statusFilter,
  onStatusFilterChange,
  sortBy,
  sortOrder,
  onSortChange,
  children,
  className = ""
}: DashboardTabsProps) {
  const handleSort = () => {
    if (onSortChange && sortBy) {
      const newOrder = sortOrder === 'asc' ? 'desc' : 'asc'
      onSortChange(sortBy, newOrder)
    }
  }

  return (
    <Tabs value={activeTab} onValueChange={onTabChange} className={`space-y-6 ${className}`}>
      <div className="flex items-center justify-between">
        <TabsList className="grid w-auto grid-cols-4">
          <TabsTrigger value="proposals" className="flex items-center space-x-2">
            <span>Propuestas</span>
          </TabsTrigger>
          <TabsTrigger value="portfolio" className="flex items-center space-x-2">
            <span>Portfolio</span>
          </TabsTrigger>
          <TabsTrigger value="analytics" className="flex items-center space-x-2">
            <span>Analytics</span>
          </TabsTrigger>
          <TabsTrigger value="governance" className="flex items-center space-x-2">
            <span>Gobernanza</span>
          </TabsTrigger>
        </TabsList>
        
        <div className="flex items-center space-x-2">
          {/* Filtros de propuestas */}
          {activeTab === 'proposals' && (
            <>
              {statusFilter !== undefined && onStatusFilterChange && (
                <Select 
                  value={statusFilter.toString()} 
                  onValueChange={(value) => onStatusFilterChange(value as ProposalStatus | 'all')}
                >
                  <SelectTrigger className="w-[140px] h-8">
                    <SelectValue placeholder="Filtrar..." />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Todas</SelectItem>
                    <SelectItem value={ProposalStatus.ACTIVE.toString()}>En Votación</SelectItem>
                    <SelectItem value={ProposalStatus.EXECUTED.toString()}>Ejecutadas</SelectItem>
                    <SelectItem value={ProposalStatus.REJECTED.toString()}>Rechazadas</SelectItem>
                    <SelectItem value={ProposalStatus.DRAFT.toString()}>Borradores</SelectItem>
                  </SelectContent>
                </Select>
              )}
              
              {sortBy && onSortChange && (
                <Button 
                  variant="outline" 
                  size="sm"
                  onClick={handleSort}
                  className="flex items-center space-x-1"
                >
                  <Filter className="h-3 w-3" />
                  {sortOrder === 'asc' ? <SortAsc className="h-3 w-3" /> : <SortDesc className="h-3 w-3" />}
                  <span className="hidden sm:inline">Ordenar</span>
                </Button>
              )}
            </>
          )}
          
          {/* Botón de nueva propuesta */}
          {onNewProposal && (
            <Button onClick={onNewProposal} className="flex items-center space-x-2">
              <PlusCircle className="h-4 w-4" />
              <span>Nueva Propuesta</span>
            </Button>
          )}
        </div>
      </div>

      {children}
    </Tabs>
  )
}
