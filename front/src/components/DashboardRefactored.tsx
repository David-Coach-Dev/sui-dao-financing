import { useEffect, useState } from 'react'
import { TabsContent } from './ui/tabs'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card'
import { BarChart3, TrendingUp, Users, DollarSign, Vote, Settings } from 'lucide-react'
import { DashboardLayout } from './layout/DashboardLayout'

// Importar componentes reutilizables
import { 
  StatsCard, 
  ProposalCard, 
  DashboardHeader, 
  DashboardTabs,
  LoadingState,
  EmptyState,
  ErrorState
} from './common'

import { CreateProposalModal } from './modals/CreateProposalModal'

// Importar stores
import { 
  useDAOStore, 
  useProposalStore, 
  useGovernanceStore, 
  useWalletStore,
  formatSUI,
  ProposalStatus
} from '../store'

const Dashboard = () => {
  const [activeTab, setActiveTab] = useState('proposals')
  const [isCreateProposalOpen, setIsCreateProposalOpen] = useState(false)

  // Estados de los stores
  const { 
    currentDAO, 
    isLoading: daoLoading, 
    error: daoError,
    refreshDAOData 
  } = useDAOStore()
  
  const { 
    activeProposals, 
    isLoading: proposalLoading,
    error: proposalError,
    statusFilter,
    sortBy,
    sortOrder,
    refreshProposals,
    voteOnProposal,
    createProposal,
    setStatusFilter,
    setSortBy,
    setSortOrder,
    getFilteredProposals
  } = useProposalStore()
  
  const { 
    userVotingPower, 
    isLoading: governanceLoading, 
    refreshTokens,
    hasUserVotedOnProposal,
    castVote 
  } = useGovernanceStore()
  
  const { 
    wallet, 
    isConnected, 
    isConnecting, 
    connectWallet, 
    disconnectWallet 
  } = useWalletStore()

  // Estado general de carga
  const isLoading = daoLoading || proposalLoading || governanceLoading
  const hasError = daoError || proposalError

  // Cargar datos iniciales
  useEffect(() => {
    const initializeData = async () => {
      try {
        await refreshDAOData()
        
        if (currentDAO) {
          await refreshProposals(currentDAO.id)
          
          if (wallet?.address) {
            await refreshTokens(currentDAO.id, wallet.address)
          }
        }
      } catch (error) {
        console.error('Error initializing data:', error)
      }
    }

    initializeData()
  }, [currentDAO?.id, wallet?.address])

  // Manejar conexión de wallet
  const handleConnectWallet = async () => {
    try {
      await connectWallet()
    } catch (error) {
      console.error('Error connecting wallet:', error)
    }
  }

  // Manejar votación
  const handleVote = async (proposalId: string, support: boolean) => {
    if (!wallet?.address || !currentDAO) return
    
    try {
      await castVote(proposalId, support, "user-token-id")
      await voteOnProposal(proposalId, support, userVotingPower)
    } catch (error) {
      console.error('Error voting:', error)
    }
  }

  // Manejar cambios de filtros
  const handleStatusFilterChange = (status: ProposalStatus | 'all') => {
    setStatusFilter(status)
  }

  const handleSortChange = (newSortBy: string, order: 'asc' | 'desc') => {
    setSortBy(newSortBy as 'created_at' | 'votes_for' | 'amount_requested')
    setSortOrder(order)
  }

  // Manejar modal de nueva propuesta
  const handleNewProposal = () => {
    setIsCreateProposalOpen(true)
  }

  const handleCreateProposal = async (title: string, description: string, amount: string) => {
    if (!currentDAO) return
    
    try {
      await createProposal(currentDAO.id, title, description, amount)
      setIsCreateProposalOpen(false)
    } catch (error) {
      console.error('Error creating proposal:', error)
    }
  }

  // Datos computados para las estadísticas
  const statsData = [
    {
      title: "Fondos Totales",
      value: currentDAO ? `${formatSUI(currentDAO.treasury)} SUI` : "0 SUI",
      description: "del mes pasado",
      icon: DollarSign,
      trend: { value: "12.5%", isPositive: true }
    },
    {
      title: "Propuestas Activas", 
      value: activeProposals.length,
      description: "finalizan esta semana",
      icon: Vote,
      trend: { value: "3", isPositive: true }
    },
    {
      title: "Miembros Totales",
      value: 247, // TODO: Calcular desde tokens de gobernanza
      description: "nuevos esta semana", 
      icon: Users,
      trend: { value: "15", isPositive: true }
    },
    {
      title: "Mi Poder de Voto",
      value: `${formatSUI(userVotingPower.toString())} SUI`,
      description: "del total",
      icon: TrendingUp,
      trend: { value: "5.1%", isPositive: true }
    }
  ]

  // Obtener propuestas filtradas
  const filteredProposals = getFilteredProposals()

  if (hasError) {
    return (
      <div className="min-h-screen bg-background">
        <DashboardHeader
          title="Sui DAO Financing"
          subtitle="Plataforma de financiamiento descentralizado"
          wallet={wallet}
          isConnected={isConnected}
          isConnecting={isConnecting}
          onConnectWallet={handleConnectWallet}
          onDisconnectWallet={disconnectWallet}
        />
        <div className="container mx-auto px-4 py-8">
          <ErrorState 
            message={hasError}
            onRetry={refreshDAOData}
          />
        </div>
      </div>
    )
  }

  return (
    <DashboardLayout activeSection={activeTab} onSectionChange={setActiveTab}>
      <LoadingState isLoading={isLoading}>
        <></>
      </LoadingState>
      
      {/* Tarjetas de estadísticas */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {statsData.map((stat, index) => (
          <StatsCard
            key={index}
            title={stat.title}
            value={stat.value}
            description={stat.description}
            icon={stat.icon}
            trend={stat.trend}
          />
        ))}
      </div>

      {/* Contenido principal con tabs */}
      <DashboardTabs
          activeTab={activeTab}
          onTabChange={setActiveTab}
          onNewProposal={handleNewProposal}
          statusFilter={statusFilter}
          onStatusFilterChange={handleStatusFilterChange}
          sortBy={sortBy}
          sortOrder={sortOrder}
          onSortChange={handleSortChange}
        >
          <TabsContent value="proposals" className="space-y-6">
            {filteredProposals.length === 0 ? (
              <EmptyState
                title="No hay propuestas"
                description="Aún no se han creado propuestas para este DAO. ¡Sé el primero en crear una!"
                icon={<Vote className="h-12 w-12" />}
              />
            ) : (
              <div className="grid gap-6">
                {filteredProposals.map((proposal) => (
                  <ProposalCard
                    key={proposal.id}
                    proposal={proposal}
                    isConnected={isConnected}
                    hasUserVoted={hasUserVotedOnProposal(proposal.id)}
                    onVote={handleVote}
                    onViewDetails={(id) => console.log('Ver detalles:', id)}
                  />
                ))}
              </div>
            )}
          </TabsContent>

          <TabsContent value="portfolio" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Portfolio de Inversiones</CardTitle>
                <CardDescription>
                  Vista general de las inversiones del DAO
                </CardDescription>
              </CardHeader>
              <CardContent>
                <EmptyState
                  title="Portfolio en desarrollo"
                  description="Funcionalidad de portfolio estará disponible próximamente"
                  icon={<BarChart3 className="h-12 w-12" />}
                />
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="analytics" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Analytics y Métricas</CardTitle>
                <CardDescription>
                  Análisis detallado del rendimiento del DAO
                </CardDescription>
              </CardHeader>
              <CardContent>
                <EmptyState
                  title="Dashboard de analytics en desarrollo"
                  description="Métricas y análisis estarán disponibles próximamente"
                  icon={<TrendingUp className="h-12 w-12" />}
                />
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="governance" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Configuración de Gobernanza</CardTitle>
                <CardDescription>
                  Parámetros y configuración del DAO
                </CardDescription>
              </CardHeader>
              <CardContent>
                <EmptyState
                  title="Panel de gobernanza en desarrollo"
                  description="Configuración de gobernanza estará disponible próximamente"
                  icon={<Settings className="h-12 w-12" />}
                />
              </CardContent>
            </Card>
          </TabsContent>
        </DashboardTabs>

      {/* Modal para crear propuesta */}
      <CreateProposalModal
        isOpen={isCreateProposalOpen}
        onClose={() => setIsCreateProposalOpen(false)}
        onSubmit={handleCreateProposal}
        isLoading={proposalLoading}
      />
    </DashboardLayout>
  )
}

export default Dashboard
