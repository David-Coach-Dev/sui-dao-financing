import { create } from 'zustand';
import { persist } from 'zustand/middleware';

// Tipos
type Theme = 'light' | 'dark';
type Language = 'es' | 'en';

interface AppState {
  // Estados
  theme: Theme;
  language: Language;
  
  // Acciones
  setTheme: (theme: Theme) => void;
  toggleTheme: () => void;
  setLanguage: (language: Language) => void;
  toggleLanguage: () => void;
}

// Store principal de la app
export const useAppStore = create<AppState>()(
  persist(
    (set, _get) => ({
      // Estados iniciales
      theme: 'light',
      language: 'es',
      
      // Acciones
      setTheme: (theme) => set({ theme }),
      toggleTheme: () => set((state) => ({ 
        theme: state.theme === 'light' ? 'dark' : 'light' 
      })),
      setLanguage: (language) => set({ language }),
      toggleLanguage: () => set((state) => ({ 
        language: state.language === 'es' ? 'en' : 'es' 
      })),
    }),
    {
      name: 'sui-dao-storage', // Nombre para localStorage
    }
  )
);
