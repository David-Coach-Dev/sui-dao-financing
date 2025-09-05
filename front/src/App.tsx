import Dashboard from './components/DashboardRefactored'
import { ThemeProvider } from './components/ThemeProvider'
import './App.css'

function App() {
  return (
    <ThemeProvider>
      <div className="min-h-screen bg-background">
        <Dashboard />
      </div>
    </ThemeProvider>
  )
}

export default App
