import { create } from 'zustand'
import { persist } from 'zustand/middleware'

// Tipos para el wallet y autenticación
export interface WalletInfo {
  address: string
  balance: string // Balance en SUI
  network: 'mainnet' | 'testnet' | 'devnet'
  connected: boolean
  connecting: boolean
}

interface WalletState {
  // Estado del wallet
  wallet: WalletInfo | null
  isConnected: boolean
  isConnecting: boolean
  
  // Estado de carga
  isLoading: boolean
  error: string | null
  
  // Configuración
  preferredNetwork: 'mainnet' | 'testnet' | 'devnet'
  autoConnect: boolean
  
  // Acciones
  setWallet: (wallet: WalletInfo) => void
  setConnected: (connected: boolean) => void
  setConnecting: (connecting: boolean) => void
  setLoading: (loading: boolean) => void
  setError: (error: string | null) => void
  clearError: () => void
  setPreferredNetwork: (network: 'mainnet' | 'testnet' | 'devnet') => void
  setAutoConnect: (autoConnect: boolean) => void
  
  // Acciones del wallet
  connectWallet: () => Promise<void>
  disconnectWallet: () => void
  refreshBalance: () => Promise<void>
  switchNetwork: (network: 'mainnet' | 'testnet' | 'devnet') => Promise<void>
}

export const useWalletStore = create<WalletState>()(
  persist(
    (set, get) => ({
      // Estado inicial
      wallet: null,
      isConnected: false,
      isConnecting: false,
      isLoading: false,
      error: null,
      
      // Configuración
      preferredNetwork: 'testnet',
      autoConnect: true,
      
      // Acciones básicas
      setWallet: (wallet) => {
        set({ 
          wallet, 
          isConnected: wallet.connected,
          error: null 
        })
      },
      
      setConnected: (connected) => {
        set(state => ({
          isConnected: connected,
          wallet: state.wallet ? { ...state.wallet, connected } : null
        }))
      },
      
      setConnecting: (connecting) => {
        set({ isConnecting: connecting })
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
      
      setPreferredNetwork: (network) => {
        set({ preferredNetwork: network })
      },
      
      setAutoConnect: (autoConnect) => {
        set({ autoConnect })
      },
      
      // Acciones del wallet
      connectWallet: async () => {
        set({ isConnecting: true, error: null })
        
        try {
          // TODO: Integrar con @mysten/dapp-kit
          // const wallet = await suiWallet.connect()
          
          // Mock para desarrollo
          const mockWallet: WalletInfo = {
            address: "0x1234567890abcdef1234567890abcdef12345678",
            balance: "1000000000000", // 1,000 SUI en MIST
            network: get().preferredNetwork,
            connected: true,
            connecting: false
          }
          
          const { setWallet } = get()
          setWallet(mockWallet)
          
          set({ isConnecting: false })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al conectar wallet',
            isConnecting: false 
          })
        }
      },
      
      disconnectWallet: () => {
        try {
          // TODO: Integrar con @mysten/dapp-kit
          // await suiWallet.disconnect()
          
          set({
            wallet: null,
            isConnected: false,
            isConnecting: false,
            error: null
          })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al desconectar wallet'
          })
        }
      },
      
      refreshBalance: async () => {
        const currentWallet = get().wallet
        if (!currentWallet?.address) return
        
        set({ isLoading: true, error: null })
        
        try {
          // TODO: Integrar con servicio Sui
          // const daoService = new SuiDaoService()
          // const balance = await daoService.getBalance(currentWallet.address)
          
          // Mock para desarrollo
          const newBalance = "1500000000000" // 1,500 SUI actualizado
          
          const { setWallet } = get()
          setWallet({
            ...currentWallet,
            balance: newBalance
          })
          
          set({ isLoading: false })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al actualizar balance',
            isLoading: false 
          })
        }
      },
      
      switchNetwork: async (network: 'mainnet' | 'testnet' | 'devnet') => {
        set({ isLoading: true, error: null })
        
        try {
          // TODO: Integrar con @mysten/dapp-kit
          // await suiWallet.switchNetwork(network)
          
          const currentWallet = get().wallet
          if (currentWallet) {
            const { setWallet, setPreferredNetwork } = get()
            setWallet({
              ...currentWallet,
              network
            })
            setPreferredNetwork(network)
          }
          
          set({ isLoading: false })
          
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Error al cambiar red',
            isLoading: false 
          })
        }
      }
    }),
    {
      name: 'wallet-storage',
      partialize: (state) => ({
        wallet: state.wallet,
        preferredNetwork: state.preferredNetwork,
        autoConnect: state.autoConnect
      })
    }
  )
)
