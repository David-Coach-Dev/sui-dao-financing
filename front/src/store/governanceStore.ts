import { create } from 'zustand'
import { persist } from 'zustand/middleware'

// Tipos para tokens de gobernanza y votación
export interface GovernanceToken {
  id: string
  dao_id: string
  voting_power: number
  owner: string
  created_at?: string
}

export interface Vote {
  id: string
  proposal_id: string
  voter: string
  support: boolean
  voting_power: number
  timestamp: number
}

interface GovernanceState {
  // Tokens de gobernanza
  tokens: GovernanceToken[]
  userTokens: GovernanceToken[]
  totalVotingPower: number
  userVotingPower: number
  
  // Votos
  votes: Vote[]
  userVotes: Vote[]
  
  // Estado de carga
  isLoading: boolean
  error: string | null
  
  // Acciones - Tokens
  setTokens: (tokens: GovernanceToken[]) => void
  addToken: (token: GovernanceToken) => void
  updateToken: (id: string, updates: Partial<GovernanceToken>) => void
  setUserTokens: (tokens: GovernanceToken[]) => void
  
  // Acciones - Votos
  setVotes: (votes: Vote[]) => void
  addVote: (vote: Vote) => void
  setUserVotes: (votes: Vote[]) => void
  
  // Estado
  setLoading: (loading: boolean) => void
  setError: (error: string | null) => void
  clearError: () => void
  
  // Acciones de datos
  refreshTokens: (daoId: string, userAddress?: string) => Promise<void>
  refreshVotes: (proposalId: string, userAddress?: string) => Promise<void>
  mintToken: (daoId: string, votingPower: number) => Promise<void>
  castVote: (proposalId: string, support: boolean, tokenId: string) => Promise<void>
  
  // Getters computados
  getUserVotingPowerForDAO: (daoId: string) => number
  getUserVoteForProposal: (proposalId: string) => Vote | undefined
  hasUserVotedOnProposal: (proposalId: string) => boolean
  getVotesForProposal: (proposalId: string) => Vote[]
}

export const useGovernanceStore = create<GovernanceState>()(
  persist(
    (set, get) => ({
      // Estado inicial
      tokens: [],
      userTokens: [],
      totalVotingPower: 0,
      userVotingPower: 0,
      votes: [],
      userVotes: [],
      isLoading: false,
      error: null,
      
      // Acciones - Tokens
      setTokens: (tokens) => {
        const totalVotingPower = tokens.reduce((sum, token) => sum + token.voting_power, 0)
        set({ tokens, totalVotingPower, error: null })
      },
      
      addToken: (token) => {
        set(state => {
          const newTokens = [...state.tokens, token]
          const totalVotingPower = newTokens.reduce((sum, t) => sum + t.voting_power, 0)
          
          return { 
            tokens: newTokens,
            totalVotingPower,
            error: null 
          }
        })
      },
      
      updateToken: (id, updates) => {
        set(state => {
          const newTokens = state.tokens.map(token => 
            token.id === id ? { ...token, ...updates } : token
          )
          const totalVotingPower = newTokens.reduce((sum, t) => sum + t.voting_power, 0)
          
          return {
            tokens: newTokens,
            totalVotingPower
          }
        })
      },
      
      setUserTokens: (userTokens) => {
        const userVotingPower = userTokens.reduce((sum, token) => sum + token.voting_power, 0)
        set({ userTokens, userVotingPower, error: null })
      },
      
      // Acciones - Votos
      setVotes: (votes) => {
        set({ votes, error: null })
      },
      
      addVote: (vote) => {
        set(state => ({ 
          votes: [...state.votes, vote],
          error: null 
        }))
      },
      
      setUserVotes: (userVotes) => {
        set({ userVotes, error: null })
      },
      
      // Estado
      setLoading: (loading) => {
        set({ isLoading: loading })
      },
      
      setError: (error) => {
        set({ error })
      },
      
      clearError: () => {
        set({ error: null })
      },
      
      // Acciones de datos
      refreshTokens: async (daoId: string, userAddress?: string) => {
        set({ isLoading: true, error: null })
        
        try {
          // TODO: Integrar con servicio Sui
          // const daoService = new SuiDaoService()
          // const tokens = await daoService.getGovernanceTokens(daoId)
          // const userTokens = userAddress ? await daoService.getUserTokens(daoId, userAddress) : []
          
          // Datos mock para desarrollo
          const mockTokens: GovernanceToken[] = [
            {
              id: "0xtoken1",
              dao_id: daoId,
              voting_power: 12500,
              owner: "0xuser1",
              created_at: "2025-08-15T10:00:00Z"
            },
            {
              id: "0xtoken2",
              dao_id: daoId,
              voting_power: 8000,
              owner: "0xuser2",
              created_at: "2025-08-20T14:30:00Z"
            },
            {
              id: "0xtoken3",
              dao_id: daoId,
              voting_power: 15000,
              owner: "0xuser3",
              created_at: "2025-08-25T09:15:00Z"
            }
          ]
          
          const userTokens = userAddress 
            ? mockTokens.filter(token => token.owner === userAddress)
            : [mockTokens[0]] // Mock: usuario actual tiene el primer token
          
          const { setTokens, setUserTokens } = get()
          setTokens(mockTokens)
          setUserTokens(userTokens)
          
          set({ isLoading: false })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al cargar tokens',
            isLoading: false 
          })
        }
      },
      
      refreshVotes: async (proposalId: string, userAddress?: string) => {
        set({ isLoading: true, error: null })
        
        try {
          // TODO: Integrar con servicio Sui
          // const daoService = new SuiDaoService()
          // const votes = await daoService.getVotes(proposalId)
          // const userVotes = userAddress ? await daoService.getUserVotes(userAddress) : []
          
          // Datos mock para desarrollo
          const mockVotes: Vote[] = [
            {
              id: "0xvote1",
              proposal_id: proposalId,
              voter: "0xuser1",
              support: true,
              voting_power: 12500,
              timestamp: Date.now() - (2 * 24 * 60 * 60 * 1000)
            },
            {
              id: "0xvote2",
              proposal_id: proposalId,
              voter: "0xuser2",
              support: true,
              voting_power: 8000,
              timestamp: Date.now() - (1 * 24 * 60 * 60 * 1000)
            },
            {
              id: "0xvote3",
              proposal_id: proposalId,
              voter: "0xuser3",
              support: false,
              voting_power: 15000,
              timestamp: Date.now() - (3 * 60 * 60 * 1000)
            }
          ]
          
          const userVotes = userAddress 
            ? mockVotes.filter(vote => vote.voter === userAddress)
            : []
          
          const { setVotes, setUserVotes } = get()
          setVotes(mockVotes)
          setUserVotes(userVotes)
          
          set({ isLoading: false })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al cargar votos',
            isLoading: false 
          })
        }
      },
      
      mintToken: async (daoId: string, votingPower: number) => {
        set({ isLoading: true, error: null })
        
        try {
          // TODO: Integrar con servicio Sui
          const newToken: GovernanceToken = {
            id: `0x${Date.now().toString(16)}`,
            dao_id: daoId,
            voting_power: votingPower,
            owner: "0xuser", // TODO: Obtener del wallet conectado
            created_at: new Date().toISOString()
          }
          
          const { addToken, setUserTokens } = get()
          addToken(newToken)
          
          // Actualizar tokens del usuario
          const currentUserTokens = get().userTokens
          setUserTokens([...currentUserTokens, newToken])
          
          set({ isLoading: false })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al crear token',
            isLoading: false 
          })
        }
      },
      
      castVote: async (proposalId: string, support: boolean, tokenId: string) => {
        set({ isLoading: true, error: null })
        
        try {
          // TODO: Integrar con servicio Sui
          const token = get().userTokens.find(t => t.id === tokenId)
          
          if (!token) {
            throw new Error('Token no encontrado')
          }
          
          const newVote: Vote = {
            id: `0x${Date.now().toString(16)}`,
            proposal_id: proposalId,
            voter: token.owner,
            support,
            voting_power: token.voting_power,
            timestamp: Date.now()
          }
          
          const { addVote, setUserVotes } = get()
          addVote(newVote)
          
          // Actualizar votos del usuario
          const currentUserVotes = get().userVotes
          setUserVotes([...currentUserVotes, newVote])
          
          set({ isLoading: false })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al votar',
            isLoading: false 
          })
        }
      },
      
      // Getters computados
      getUserVotingPowerForDAO: (daoId: string) => {
        const userTokens = get().userTokens.filter(token => token.dao_id === daoId)
        return userTokens.reduce((sum, token) => sum + token.voting_power, 0)
      },
      
      getUserVoteForProposal: (proposalId: string) => {
        return get().userVotes.find(vote => vote.proposal_id === proposalId)
      },
      
      hasUserVotedOnProposal: (proposalId: string) => {
        return get().userVotes.some(vote => vote.proposal_id === proposalId)
      },
      
      getVotesForProposal: (proposalId: string) => {
        return get().votes.filter(vote => vote.proposal_id === proposalId)
      }
    }),
    {
      name: 'governance-storage',
      partialize: (state) => ({
        tokens: state.tokens,
        userTokens: state.userTokens,
        votes: state.votes,
        userVotes: state.userVotes
      })
    }
  )
)
