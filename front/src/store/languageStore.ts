import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import translations from '../locales/translations.json'

export type Language = 'es' | 'en'

type TranslationSection = keyof typeof translations.es
type TranslationKey<T extends TranslationSection> = keyof typeof translations.es[T]

interface LanguageState {
  language: Language
  translations: typeof translations
  setLanguage: (language: Language) => void
  t: (key: string, section?: string) => string
}

export const useLanguageStore = create<LanguageState>()(
  persist(
    (set, get) => ({
      language: 'es',
      translations,
      
      setLanguage: (language: Language) => {
        set({ language })
      },
      
      t: (key: string, section?: string) => {
        const { language, translations } = get()
        const currentTranslations = translations[language] as any
        
        if (section) {
          return currentTranslations[section]?.[key] || key
        }
        
        // Try to find the key in any section if no section specified
        const sections = Object.keys(currentTranslations)
        for (const sectionName of sections) {
          if (currentTranslations[sectionName]?.[key]) {
            return currentTranslations[sectionName][key]
          }
        }
        
        return key
      }
    }),
    {
      name: 'language-storage',
      partialize: (state) => ({ language: state.language })
    }
  )
)
