import { Button } from '../ui/button'
import { Input } from '../ui/input'
import { Label } from '../ui/label'
import { Textarea } from '../ui/textarea'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '../ui/dialog'
import { useState } from 'react'

interface CreateProposalModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit: (title: string, description: string, amount: string) => Promise<void>
  isLoading?: boolean
}

export function CreateProposalModal({ 
  isOpen, 
  onClose, 
  onSubmit, 
  isLoading = false 
}: CreateProposalModalProps) {
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [amount, setAmount] = useState('')
  const [errors, setErrors] = useState<Record<string, string>>({})

  const validateForm = () => {
    const newErrors: Record<string, string> = {}
    
    if (!title.trim()) {
      newErrors.title = 'El título es requerido'
    }
    
    if (!description.trim()) {
      newErrors.description = 'La descripción es requerida'
    }
    
    if (!amount.trim()) {
      newErrors.amount = 'El monto es requerido'
    } else if (isNaN(Number(amount)) || Number(amount) <= 0) {
      newErrors.amount = 'El monto debe ser un número positivo'
    }
    
    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!validateForm()) return
    
    try {
      // Convert SUI to MIST (multiply by 1 billion)
      const amountInMist = (Number(amount) * 1_000_000_000).toString()
      await onSubmit(title, description, amountInMist)
      
      // Reset form
      setTitle('')
      setDescription('')
      setAmount('')
      setErrors({})
      onClose()
    } catch (error) {
      console.error('Error creating proposal:', error)
    }
  }

  const handleClose = () => {
    setTitle('')
    setDescription('')
    setAmount('')
    setErrors({})
    onClose()
  }

  return (
    <Dialog open={isOpen} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-[600px]">
        <DialogHeader>
          <DialogTitle>Crear Nueva Propuesta</DialogTitle>
          <DialogDescription>
            Crea una nueva propuesta para que la comunidad vote sobre el financiamiento.
          </DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="space-y-2">
            <Label htmlFor="title">Título de la propuesta</Label>
            <Input
              id="title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Ej: Financiamiento para desarrollo de protocolo DeFi"
              className={errors.title ? "border-red-500" : ""}
            />
            {errors.title && (
              <p className="text-sm text-red-500">{errors.title}</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">Descripción detallada</Label>
            <Textarea
              id="description"
              value={description}
              onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => setDescription(e.target.value)}
              placeholder="Describe en detalle qué se hará con los fondos, objetivos, cronograma, etc."
              rows={4}
              className={errors.description ? "border-red-500" : ""}
            />
            {errors.description && (
              <p className="text-sm text-red-500">{errors.description}</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="amount">Monto solicitado (SUI)</Label>
            <Input
              id="amount"
              type="number"
              step="0.01"
              min="0"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="1000"
              className={errors.amount ? "border-red-500" : ""}
            />
            {errors.amount && (
              <p className="text-sm text-red-500">{errors.amount}</p>
            )}
            <p className="text-xs text-muted-foreground">
              Los fondos se liberarán automáticamente si la propuesta es aprobada
            </p>
          </div>

          <DialogFooter>
            <Button type="button" variant="outline" onClick={handleClose}>
              Cancelar
            </Button>
            <Button type="submit" disabled={isLoading}>
              {isLoading ? 'Creando...' : 'Crear Propuesta'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
