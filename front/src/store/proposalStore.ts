import { create } from 'zustand'
import { persist } from 'zustand/middleware'

// Tipos basados en el contrato Sui
export interface Proposal {
  id: string
  dao_id: string
  title: string
  description: string
  amount_requested: string // En MIST (unidades básicas de SUI)
  proposer: string
  deadline: number
  executed: boolean
  votes_for: number
  votes_against: number
  status: ProposalStatus
  created_at?: string
}

export enum ProposalStatus {
  ACTIVE = 0,
  EXECUTED = 3,
  REJECTED = 4,
  DRAFT = 5
}

interface ProposalState {
  // Estado de propuestas
  proposals: Proposal[]
  activeProposals: Proposal[]
  currentProposal: Proposal | null
  
  // Estado de carga
  isLoading: boolean
  error: string | null
  
  // Filtros y ordenamiento
  statusFilter: ProposalStatus | 'all'
  sortBy: 'created_at' | 'votes_for' | 'amount_requested'
  sortOrder: 'asc' | 'desc'
  
  // Acciones
  setProposals: (proposals: Proposal[]) => void
  addProposal: (proposal: Proposal) => void
  updateProposal: (id: string, updates: Partial<Proposal>) => void
  setCurrentProposal: (proposal: Proposal | null) => void
  setLoading: (loading: boolean) => void
  setError: (error: string | null) => void
  clearError: () => void
  
  // Filtros
  setStatusFilter: (status: ProposalStatus | 'all') => void
  setSortBy: (sortBy: 'created_at' | 'votes_for' | 'amount_requested') => void
  setSortOrder: (order: 'asc' | 'desc') => void
  
  // Acciones de datos
  refreshProposals: (daoId: string) => Promise<void>
  createProposal: (daoId: string, title: string, description: string, amount: string) => Promise<void>
  voteOnProposal: (proposalId: string, support: boolean, votingPower: number) => Promise<void>
  executeProposal: (proposalId: string) => Promise<void>
  
  // Getters computados
  getFilteredProposals: () => Proposal[]
  getProposalById: (id: string) => Proposal | undefined
  getProposalsByStatus: (status: ProposalStatus) => Proposal[]
}

export const useProposalStore = create<ProposalState>()(
  persist(
    (set, get) => ({
      // Estado inicial
      proposals: [],
      activeProposals: [],
      currentProposal: null,
      isLoading: false,
      error: null,
      
      // Filtros
      statusFilter: 'all',
      sortBy: 'created_at',
      sortOrder: 'desc',
      
      // Acciones básicas
      setProposals: (proposals) => {
        const activeProposals = proposals.filter(p => p.status === ProposalStatus.ACTIVE)
        set({ proposals, activeProposals, error: null })
      },
      
      addProposal: (proposal) => {
        set(state => {
          const newProposals = [...state.proposals, proposal]
          const activeProposals = newProposals.filter(p => p.status === ProposalStatus.ACTIVE)
          return { 
            proposals: newProposals, 
            activeProposals,
            error: null 
          }
        })
      },
      
      updateProposal: (id, updates) => {
        set(state => {
          const newProposals = state.proposals.map(proposal => 
            proposal.id === id ? { ...proposal, ...updates } : proposal
          )
          const activeProposals = newProposals.filter(p => p.status === ProposalStatus.ACTIVE)
          
          return {
            proposals: newProposals,
            activeProposals,
            currentProposal: state.currentProposal?.id === id 
              ? { ...state.currentProposal, ...updates }
              : state.currentProposal
          }
        })
      },
      
      setCurrentProposal: (proposal) => {
        set({ currentProposal: proposal })
      },
      
      setLoading: (loading) => {
        set({ isLoading: loading })
      },
      
      setError: (error) => {
        set({ error })
      },
      
      clearError: () => {
        set({ error: null })
      },
      
      // Filtros
      setStatusFilter: (statusFilter) => {
        set({ statusFilter })
      },
      
      setSortBy: (sortBy) => {
        set({ sortBy })
      },
      
      setSortOrder: (sortOrder) => {
        set({ sortOrder })
      },
      
      // Acciones de datos
      refreshProposals: async (daoId: string) => {
        set({ isLoading: true, error: null })
        
        try {
          // TODO: Integrar con servicio Sui
          // const daoService = new SuiDaoService()
          // const proposals = await daoService.getProposals(daoId)
          
          // Datos mock para desarrollo
          const mockProposals: Proposal[] = [
            {
              id: "0xproposal1",
              dao_id: daoId,
              title: "Financiamiento para DeFi Protocol",
              description: "Propuesta para invertir 50,000 SUI en el desarrollo de un nuevo protocolo DeFi que permitirá...",
              amount_requested: "50000000000000", // 50,000 SUI en MIST
              proposer: "0xproposer1",
              deadline: Date.now() + (7 * 24 * 60 * 60 * 1000), // 7 días
              executed: false,
              votes_for: 156000,
              votes_against: 23000,
              status: ProposalStatus.ACTIVE,
              created_at: "2025-09-01T10:00:00Z"
            },
            {
              id: "0xproposal2",
              dao_id: daoId,
              title: "Expansión del equipo de desarrollo",
              description: "Contratar 3 desarrolladores adicionales especializados en Move y Sui para acelerar el roadmap de la plataforma",
              amount_requested: "25000000000000", // 25,000 SUI en MIST
              proposer: "0xproposer2",
              deadline: Date.now() - (1 * 24 * 60 * 60 * 1000), // Pasado
              executed: true,
              votes_for: 203000,
              votes_against: 15000,
              status: ProposalStatus.EXECUTED,
              created_at: "2025-08-25T15:30:00Z"
            },
            {
              id: "0xproposal3",
              dao_id: daoId,
              title: "Marketing y partnerships estratégicos",
              description: "Campaña de marketing integral y establecimiento de partnerships con otros protocolos DeFi",
              amount_requested: "15000000000000", // 15,000 SUI en MIST
              proposer: "0xproposer3",
              deadline: Date.now() + (10 * 24 * 60 * 60 * 1000), // 10 días
              executed: false,
              votes_for: 0,
              votes_against: 0,
              status: ProposalStatus.DRAFT,
              created_at: "2025-09-05T08:00:00Z"
            }
          ]
          
          const { setProposals } = get()
          setProposals(mockProposals)
          set({ isLoading: false })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al cargar propuestas',
            isLoading: false 
          })
        }
      },
      
      createProposal: async (daoId: string, title: string, description: string, amount: string) => {
        set({ isLoading: true, error: null })
        
        try {
          // TODO: Integrar con servicio Sui
          const newProposal: Proposal = {
            id: `0x${Date.now().toString(16)}`,
            dao_id: daoId,
            title,
            description,
            amount_requested: amount,
            proposer: "0xuser", // TODO: Obtener del wallet conectado
            deadline: Date.now() + (14 * 24 * 60 * 60 * 1000), // 14 días por defecto
            executed: false,
            votes_for: 0,
            votes_against: 0,
            status: ProposalStatus.DRAFT,
            created_at: new Date().toISOString()
          }
          
          const { addProposal } = get()
          addProposal(newProposal)
          set({ isLoading: false })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al crear propuesta',
            isLoading: false 
          })
        }
      },
      
      voteOnProposal: async (proposalId: string, support: boolean, votingPower: number) => {
        set({ isLoading: true, error: null })
        
        try {
          // TODO: Integrar con servicio Sui
          const { updateProposal } = get()
          const proposal = get().proposals.find(p => p.id === proposalId)
          
          if (proposal) {
            const updates: Partial<Proposal> = support
              ? { votes_for: proposal.votes_for + votingPower }
              : { votes_against: proposal.votes_against + votingPower }
            
            updateProposal(proposalId, updates)
          }
          
          set({ isLoading: false })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al votar',
            isLoading: false 
          })
        }
      },
      
      executeProposal: async (proposalId: string) => {
        set({ isLoading: true, error: null })
        
        try {
          // TODO: Integrar con servicio Sui
          const { updateProposal } = get()
          updateProposal(proposalId, { 
            executed: true, 
            status: ProposalStatus.EXECUTED 
          })
          
          set({ isLoading: false })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al ejecutar propuesta',
            isLoading: false 
          })
        }
      },
      
      // Getters computados
      getFilteredProposals: () => {
        const state = get()
        let filtered = state.proposals
        
        // Filtrar por estado
        if (state.statusFilter !== 'all') {
          filtered = filtered.filter(p => p.status === state.statusFilter)
        }
        
        // Ordenar
        filtered.sort((a, b) => {
          const getValue = (proposal: Proposal) => {
            switch (state.sortBy) {
              case 'votes_for': return proposal.votes_for
              case 'amount_requested': return parseInt(proposal.amount_requested)
              case 'created_at': return new Date(proposal.created_at || 0).getTime()
              default: return 0
            }
          }
          
          const aVal = getValue(a)
          const bVal = getValue(b)
          
          return state.sortOrder === 'asc' ? aVal - bVal : bVal - aVal
        })
        
        return filtered
      },
      
      getProposalById: (id: string) => {
        return get().proposals.find(p => p.id === id)
      },
      
      getProposalsByStatus: (status: ProposalStatus) => {
        return get().proposals.filter(p => p.status === status)
      }
    }),
    {
      name: 'proposal-storage',
      partialize: (state) => ({
        proposals: state.proposals,
        statusFilter: state.statusFilter,
        sortBy: state.sortBy,
        sortOrder: state.sortOrder
      })
    }
  )
)
