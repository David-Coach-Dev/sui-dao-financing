import { ProposalStatus } from './proposalStore'

// Re-export all stores for easy importing
export { useDAOStore } from './daoStore'
export type { DAO } from './daoStore'

export { useProposalStore, ProposalStatus } from './proposalStore'
export type { Proposal } from './proposalStore'

export { useGovernanceStore } from './governanceStore'
export type { GovernanceToken, Vote } from './governanceStore'

export { useWalletStore } from './walletStore'
export type { WalletInfo } from './walletStore'

export { useLanguageStore } from './languageStore'
export type { Language } from './languageStore'

export { useThemeStore } from './themeStore'
export type { Theme } from './themeStore'

// Utility functions for formatting data
export const formatSUI = (amount: string): string => {
  const sui = parseFloat(amount) / 1_000_000_000 // Convert MIST to SUI
  return sui.toLocaleString('en-US', { 
    minimumFractionDigits: 0,
    maximumFractionDigits: 2 
  })
}

export const formatAddress = (address: string): string => {
  if (address.length < 12) return address
  return `${address.slice(0, 6)}...${address.slice(-4)}`
}

export const formatTimestamp = (timestamp: number): string => {
  return new Date(timestamp).toLocaleDateString('es-ES', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

export const formatProposalStatus = (status: ProposalStatus): string => {
  switch (status) {
    case ProposalStatus.ACTIVE:
      return 'En Votación'
    case ProposalStatus.EXECUTED:
      return 'Ejecutada'
    case ProposalStatus.REJECTED:
      return 'Rechazada'
    case ProposalStatus.DRAFT:
      return 'Borrador'
    default:
      return 'Desconocido'
  }
}

export const getProposalStatusColor = (status: ProposalStatus): string => {
  switch (status) {
    case ProposalStatus.ACTIVE:
      return 'bg-blue-500 text-white'
    case ProposalStatus.EXECUTED:
      return 'bg-green-500 text-white'
    case ProposalStatus.REJECTED:
      return 'bg-red-500 text-white'
    case ProposalStatus.DRAFT:
      return 'bg-gray-500 text-white'
    default:
      return 'bg-gray-400 text-white'
  }
}
