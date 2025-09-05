import { create } from 'zustand'
import { persist } from 'zustand/middleware'

// Tipos basados en el contrato de Sui
export interface DAO {
  id: string
  name: string
  treasury: string // Balance en SUI
  proposal_count: number
  min_voting_power: number
  active: boolean
  creator?: string
  created_at?: string
}

interface DAOState {
  // Estado del DAO
  currentDAO: DAO | null
  daos: DAO[]
  
  // Estado de carga
  isLoading: boolean
  error: string | null
  
  // Acciones
  setCurrentDAO: (dao: DAO) => void
  addDAO: (dao: DAO) => void
  updateDAO: (id: string, updates: Partial<DAO>) => void
  setDAOs: (daos: DAO[]) => void
  setLoading: (loading: boolean) => void
  setError: (error: string | null) => void
  clearError: () => void
  
  // Acciones de datos
  refreshDAOData: () => Promise<void>
  createDAO: (name: string, minVotingPower: number) => Promise<void>
}

export const useDAOStore = create<DAOState>()(
  persist(
    (set, get) => ({
      // Estado inicial
      currentDAO: null,
      daos: [],
      isLoading: false,
      error: null,
      
      // Acciones básicas
      setCurrentDAO: (dao) => {
        set({ currentDAO: dao, error: null })
      },
      
      addDAO: (dao) => {
        set(state => ({ 
          daos: [...state.daos, dao],
          error: null 
        }))
      },
      
      updateDAO: (id, updates) => {
        set(state => ({
          daos: state.daos.map(dao => 
            dao.id === id ? { ...dao, ...updates } : dao
          ),
          currentDAO: state.currentDAO?.id === id 
            ? { ...state.currentDAO, ...updates }
            : state.currentDAO
        }))
      },
      
      setDAOs: (daos) => {
        set({ daos, error: null })
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
      
      // Acciones de datos (placeholder para integración con Sui)
      refreshDAOData: async () => {
        set({ isLoading: true, error: null })
        
        try {
          // TODO: Integrar con servicio Sui para obtener DAOs
          // const daoService = new SuiDaoService()
          // const daos = await daoService.getAllDAOs()
          // set({ daos, isLoading: false })
          
          // Por ahora, datos mock para desarrollo
          const mockDAOs: DAO[] = [
            {
              id: "0x1234567890abcdef",
              name: "Sui DAO Financing",
              treasury: "125000000000000", // 125,000 SUI en MIST
              proposal_count: 8,
              min_voting_power: 1000,
              active: true,
              creator: "0xabcdef1234567890",
              created_at: "2025-01-15T10:00:00Z"
            }
          ]
          
          set({ 
            daos: mockDAOs, 
            currentDAO: mockDAOs[0],
            isLoading: false 
          })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al cargar DAOs',
            isLoading: false 
          })
        }
      },
      
      createDAO: async (name: string, minVotingPower: number) => {
        set({ isLoading: true, error: null })
        
        try {
          // TODO: Integrar con servicio Sui para crear DAO
          // const daoService = new SuiDaoService()
          // const newDAO = await daoService.createDAO(name, minVotingPower)
          
          // Por ahora, mock del nuevo DAO
          const newDAO: DAO = {
            id: `0x${Date.now().toString(16)}`,
            name,
            treasury: "0",
            proposal_count: 0,
            min_voting_power: minVotingPower,
            active: true,
            creator: "0xuser",
            created_at: new Date().toISOString()
          }
          
          const { addDAO } = get()
          addDAO(newDAO)
          
          set({ isLoading: false })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al crear DAO',
            isLoading: false 
          })
        }
      }
    }),
    {
      name: 'dao-storage',
      partialize: (state) => ({
        currentDAO: state.currentDAO,
        daos: state.daos
      })
    }
  )
)
