import { Languages } from "lucide-react"
import { Button } from "./ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "./ui/dropdown-menu"
import { useLanguageStore, Language } from "../store"

export function LanguageToggle() {
  const { language, setLanguage, t } = useLanguageStore()

  const getLanguageLabel = (lang: Language) => {
    switch (lang) {
      case 'es':
        return 'Español'
      case 'en':
        return 'English'
      default:
        return lang
    }
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="outline" size="icon">
          <Languages className="h-4 w-4" />
          <span className="sr-only">Change language</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem 
          onClick={() => setLanguage('es')}
          className={language === 'es' ? 'bg-accent' : ''}
        >
          <span className="mr-2">🇪🇸</span>
          <span>Español</span>
        </DropdownMenuItem>
        <DropdownMenuItem 
          onClick={() => setLanguage('en')}
          className={language === 'en' ? 'bg-accent' : ''}
        >
          <span className="mr-2">🇺🇸</span>
          <span>English</span>
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
