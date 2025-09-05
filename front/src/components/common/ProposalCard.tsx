import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card'
import { Button } from '../ui/button'
import { Badge } from '../ui/badge'
import { Progress } from '../ui/progress'
import { formatSUI, formatProposalStatus, getProposalStatusColor, ProposalStatus } from '../../store'
import type { Proposal } from '../../store'

interface ProposalCardProps {
  proposal: Proposal
  isConnected: boolean
  hasUserVoted: boolean
  onVote: (proposalId: string, support: boolean) => Promise<void>
  onViewDetails?: (proposalId: string) => void
  className?: string
}

export function ProposalCard({ 
  proposal, 
  isConnected, 
  hasUserVoted,
  onVote,
  onViewDetails,
  className = "" 
}: ProposalCardProps) {
  const totalVotes = proposal.votes_for + proposal.votes_against
  const supportPercentage = totalVotes > 0 ? (proposal.votes_for / totalVotes) * 100 : 0

  const handleVoteFor = () => onVote(proposal.id, true)
  const handleVoteAgainst = () => onVote(proposal.id, false)
  const handleViewDetails = () => onViewDetails?.(proposal.id)

  return (
    <Card className={`w-full ${className}`}>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div className="space-y-1 flex-1">
            <CardTitle className="text-lg">{proposal.title}</CardTitle>
            <CardDescription className="text-sm text-muted-foreground">
              {proposal.description}
            </CardDescription>
          </div>
          <div className="flex items-center space-x-2 ml-4">
            <Badge className={getProposalStatusColor(proposal.status)}>
              {formatProposalStatus(proposal.status)}
            </Badge>
            <div className="text-right">
              <div className="text-sm font-medium">
                {formatSUI(proposal.amount_requested)} SUI
              </div>
              <div className="text-xs text-muted-foreground">Solicitado</div>
            </div>
          </div>
        </div>
      </CardHeader>
      
      <CardContent>
        {proposal.status === ProposalStatus.ACTIVE && (
          <div className="space-y-4">
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-green-600">A favor: {proposal.votes_for.toLocaleString()}</span>
                <span className="text-red-600">En contra: {proposal.votes_against.toLocaleString()}</span>
                <span className="font-medium">Total: {totalVotes.toLocaleString()}</span>
              </div>
              
              <Progress value={supportPercentage} className="h-2" />
              
              <div className="flex justify-between text-xs text-muted-foreground">
                <span>{supportPercentage.toFixed(1)}% de apoyo</span>
                <span>
                  Finaliza: {new Date(proposal.deadline).toLocaleDateString('es-ES')}
                </span>
              </div>
            </div>
            
            <div className="flex justify-between items-center">
              <div className="flex space-x-2">
                <Button 
                  variant="outline" 
                  size="sm"
                  onClick={handleVoteAgainst}
                  disabled={hasUserVoted || !isConnected}
                  className="text-red-600 hover:text-red-700"
                >
                  Votar En Contra
                </Button>
                <Button 
                  size="sm"
                  onClick={handleVoteFor}
                  disabled={hasUserVoted || !isConnected}
                  className="bg-green-600 hover:bg-green-700"
                >
                  Votar A Favor
                </Button>
              </div>
              
              {!isConnected && (
                <span className="text-xs text-muted-foreground">
                  Conecta tu wallet para votar
                </span>
              )}
              
              {hasUserVoted && (
                <span className="text-xs text-green-600">
                  Ya has votado en esta propuesta
                </span>
              )}
            </div>
          </div>
        )}
        
        {proposal.status === ProposalStatus.EXECUTED && (
          <div className="flex justify-between items-center">
            <div className="space-y-1">
              <div className="text-sm font-medium text-green-600">
                ✓ Propuesta ejecutada exitosamente
              </div>
              <div className="text-xs text-muted-foreground">
                {proposal.votes_for.toLocaleString()} votos a favor de {totalVotes.toLocaleString()} total
              </div>
            </div>
            <Button variant="outline" size="sm" onClick={handleViewDetails}>
              Ver Detalles
            </Button>
          </div>
        )}

        {proposal.status === ProposalStatus.REJECTED && (
          <div className="flex justify-between items-center">
            <div className="space-y-1">
              <div className="text-sm font-medium text-red-600">
                ✗ Propuesta rechazada
              </div>
              <div className="text-xs text-muted-foreground">
                {proposal.votes_against.toLocaleString()} votos en contra de {totalVotes.toLocaleString()} total
              </div>
            </div>
            <Button variant="outline" size="sm" onClick={handleViewDetails}>
              Ver Detalles
            </Button>
          </div>
        )}

        {proposal.status === ProposalStatus.DRAFT && (
          <div className="flex justify-between items-center">
            <div className="text-sm text-muted-foreground">
              Propuesta en borrador - Pendiente de envío
            </div>
            <Button variant="outline" size="sm" onClick={handleViewDetails}>
              Revisar
            </Button>
          </div>
        )}
      </CardContent>
    </Card>
  )
}
