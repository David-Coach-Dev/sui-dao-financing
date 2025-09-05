import { Moon, Sun, ExternalLink, Code, Database, Shield } from 'lucide-react'
import { useAppStore } from '../store/app-store'
import { Button } from './ui/button'

export function Footer() {
  const { theme, language, toggleTheme, setLanguage } = useAppStore()

  const handleThemeToggle = () => {
    toggleTheme()
  }

  const handleLanguageChange = (newLanguage: 'en' | 'es') => {
    setLanguage(newLanguage)
  }

  return (
    <footer className={`border-t mt-12 ${
      theme === 'dark' 
        ? 'bg-slate-800 border-slate-700' 
        : 'bg-white/90 backdrop-blur-sm border-slate-200'
    }`}>
      <div className="container mx-auto px-8 py-8">
        
        {/* Contenedor principal - 3 columnas horizontales */}
        <div className="flex flex-col md:flex-row justify-between items-start gap-6 md:gap-8">
          
          {/* DIV 1: Información del Proyecto y Desarrollador */}
          <div className="flex-1 space-y-4 min-w-0">
            <div>
              <h3 className={`text-xl font-bold mb-2 ${
                theme === 'dark' ? 'text-white' : 'text-slate-900'
              }`}>
                Sui DAO Finance
              </h3>
              <p className={`text-sm leading-relaxed mb-4 ${
                theme === 'dark' ? 'text-slate-300' : 'text-slate-600'
              }`}>
                Plataforma descentralizada para la gestión de DAOs en la red Sui
              </p>
            </div>
            
            {/* Información del desarrollador */}
            <div className={`pt-3 border-t ${
              theme === 'dark' ? 'border-slate-700' : 'border-slate-200'
            }`}>
              <p className={`text-xs font-medium ${
                theme === 'dark' ? 'text-slate-400' : 'text-slate-500'
              }`}>
                Desarrollado por <span className={`font-semibold ${
                  theme === 'dark' ? 'text-white' : 'text-slate-900'
                }`}>David Coach Dev</span>
              </p>
              <p className={`text-xs ${
                theme === 'dark' ? 'text-slate-500' : 'text-slate-400'
              }`}>
                Full Stack Developer & Blockchain Specialist
              </p>
            </div>
          </div>

          {/* DIV 2: Enlaces y Tecnologías */}
          <div className="flex-1 space-y-4 min-w-0">
            <h4 className={`text-lg font-semibold ${
              theme === 'dark' ? 'text-white' : 'text-slate-900'
            }`}>
              Tecnologías & Enlaces
            </h4>
            
            {/* Badges de tecnologías */}
            <div className="flex flex-wrap gap-2">
              <div className="flex items-center gap-1 px-2 py-1 rounded-full text-xs bg-primary/10 text-primary">
                <Database className="h-3 w-3" />
                Sui Network
              </div>
              <div className="flex items-center gap-1 px-2 py-1 rounded-full text-xs bg-secondary text-secondary-foreground">
                <Shield className="h-3 w-3" />
                Web3 Security
              </div>
              <div className="flex items-center gap-1 px-2 py-1 rounded-full text-xs bg-accent text-accent-foreground">
                <Code className="h-3 w-3" />
                Open Source
              </div>
            </div>
            
            {/* Enlaces principales */}
            <div className="flex flex-wrap gap-4">
              <a 
                href="https://sui.io" 
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm hover:underline flex items-center gap-1 text-primary hover:text-primary/80"
              >
                Sui Network <ExternalLink className="h-3 w-3" />
              </a>
              <a 
                href="https://github.com/David-Coach-Dev" 
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm hover:underline flex items-center gap-1 text-primary hover:text-primary/80"
              >
                GitHub <ExternalLink className="h-3 w-3" />
              </a>
              <a 
                href="https://docs.sui.io" 
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm hover:underline flex items-center gap-1 text-primary hover:text-primary/80"
              >
                Documentación <ExternalLink className="h-3 w-3" />
              </a>
            </div>
          </div>

          {/* DIV 3: Configuración y Copyright */}
          <div className="flex-1 space-y-4 min-w-0">
            <h4 className={`text-lg font-semibold ${
              theme === 'dark' ? 'text-white' : 'text-slate-900'
            }`}>
              Configuración
            </h4>
            
            {/* Controles de tema e idioma */}
            <div className="space-y-3">
              {/* Selector de Tema */}
              <Button
                onClick={handleThemeToggle}
                variant="outline"
                size="sm"
                className="w-full justify-start"
              >
                {theme === 'dark' ? (
                  <>
                    <Sun className="mr-2 h-4 w-4" />
                    Modo Claro
                  </>
                ) : (
                  <>
                    <Moon className="mr-2 h-4 w-4" />
                    Modo Oscuro
                  </>
                )}
              </Button>

              {/* Selector de Idioma */}
              <div className={`flex rounded-lg overflow-hidden ${
                theme === 'dark' ? 'bg-slate-700' : 'bg-slate-100'
              }`}>
                <Button
                  variant={language === 'es' ? 'default' : 'ghost'}
                  size="sm"
                  onClick={() => handleLanguageChange('es')}
                  className="flex-1 text-xs rounded-none"
                >
                  🇪🇸 ES
                </Button>
                <Button
                  variant={language === 'en' ? 'default' : 'ghost'}
                  size="sm"
                  onClick={() => handleLanguageChange('en')}
                  className="flex-1 text-xs rounded-none"
                >
                  🇺🇸 EN
                </Button>
              </div>
            </div>
            
            {/* Copyright */}
            <div className={`pt-3 border-t text-center ${
              theme === 'dark' ? 'border-slate-700' : 'border-slate-200'
            }`}>
              <p className={`text-xs ${
                theme === 'dark' ? 'text-slate-500' : 'text-slate-500'
              }`}>
                © 2025 Sui DAO Finance
              </p>
              <p className={`text-xs mt-1 ${
                theme === 'dark' ? 'text-slate-500' : 'text-slate-500'
              }`}>
                Todos los derechos reservados
              </p>
            </div>
          </div>
        </div>
      </div>
    </footer>
  )
}
