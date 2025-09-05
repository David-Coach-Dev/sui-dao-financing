import { SuiClient, getFullnodeUrl } from '@mysten/sui.js/client';
import { TransactionBlock } from '@mysten/sui.js/transactions';
import { SUI_CONFIG, DAO_OBJECT_IDS } from '../config/sui-objects';

// Cliente Sui
const suiClient = new SuiClient({
  url: getFullnodeUrl(SUI_CONFIG.network as 'devnet' | 'testnet' | 'mainnet')
});

// Tipos para los datos del DAO
export interface DaoData {
  id: string;
  name: string;
  description: string;
  balance: number;
  memberCount: number;
  proposalCount: number;
  treasuryAddress: string;
  createdAt: number;
}

export interface ProposalData {
  id: string;
  title: string;
  description: string;
  proposer: string;
  votesFor: number;
  votesAgainst: number;
  status: 'active' | 'passed' | 'rejected' | 'executed';
  deadline: number;
  createdAt: number;
}

// Clase principal para interactuar con Sui
export class SuiDaoService {
  private client: SuiClient;
  private packageId: string;

  constructor() {
    this.client = suiClient;
    this.packageId = SUI_CONFIG.packageId;
  }

  // Obtener información de un DAO
  async getDaoInfo(daoId: string): Promise<DaoData | null> {
    try {
      const objectId = DAO_OBJECT_IDS[daoId as keyof typeof DAO_OBJECT_IDS]?.objectId;
      
      if (!objectId || objectId === '0x...') {
        // Retornar datos simulados si no hay ID real
        return this.getMockDaoData(daoId);
      }

      const daoObject = await this.client.getObject({
        id: objectId,
        options: { showContent: true, showOwner: true }
      });

      if (!daoObject.data) {
        throw new Error(`DAO ${daoId} no encontrado`);
      }

      // Procesar los datos del objeto Sui
      const content = daoObject.data.content as any;
      
      return {
        id: daoId,
        name: content.fields?.name || `DAO ${daoId}`,
        description: content.fields?.description || 'Descripción del DAO',
        balance: content.fields?.balance || 0,
        memberCount: content.fields?.member_count || 0,
        proposalCount: content.fields?.proposal_count || 0,
        treasuryAddress: content.fields?.treasury || '',
        createdAt: content.fields?.created_at || Date.now()
      };

    } catch (error) {
      console.error(`Error obteniendo datos del DAO ${daoId}:`, error);
      return this.getMockDaoData(daoId);
    }
  }

  // Obtener todas las propuestas de un DAO
  async getDaoProposals(daoId: string): Promise<ProposalData[]> {
    try {
      const objectId = DAO_OBJECT_IDS[daoId as keyof typeof DAO_OBJECT_IDS]?.objectId;
      
      if (!objectId || objectId === '0x...') {
        return this.getMockProposals(daoId);
      }

      // Consultar propuestas dinámicamente
      const proposals = await this.client.getDynamicFields({
        parentId: objectId
      });

      const proposalData: ProposalData[] = [];
      
      for (const proposal of proposals.data) {
        const proposalObject = await this.client.getObject({
          id: proposal.objectId,
          options: { showContent: true }
        });

        if (proposalObject.data?.content) {
          const content = proposalObject.data.content as any;
          proposalData.push({
            id: proposal.objectId,
            title: content.fields?.title || 'Propuesta',
            description: content.fields?.description || '',
            proposer: content.fields?.proposer || '',
            votesFor: content.fields?.votes_for || 0,
            votesAgainst: content.fields?.votes_against || 0,
            status: content.fields?.status || 'active',
            deadline: content.fields?.deadline || 0,
            createdAt: content.fields?.created_at || Date.now()
          });
        }
      }

      return proposalData;

    } catch (error) {
      console.error(`Error obteniendo propuestas del DAO ${daoId}:`, error);
      return this.getMockProposals(daoId);
    }
  }

  // Crear una nueva propuesta
  async createProposal(
    daoId: string,
    title: string,
    description: string,
    signer: any // Wallet signer
  ): Promise<string> {
    try {
      const objectId = DAO_OBJECT_IDS[daoId as keyof typeof DAO_OBJECT_IDS]?.objectId;
      
      if (!objectId || objectId === '0x...') {
        throw new Error('DAO no desplegado en Sui');
      }

      const txb = new TransactionBlock();
      
      txb.moveCall({
        target: `${this.packageId}::dao::create_proposal`,
        arguments: [
          txb.object(objectId),
          txb.pure.string(title),
          txb.pure.string(description),
          txb.pure.u64(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 días deadline
        ]
      });

      const result = await this.client.signAndExecuteTransactionBlock({
        transactionBlock: txb,
        signer,
        options: { showEffects: true }
      });

      return result.digest;

    } catch (error) {
      console.error('Error creando propuesta:', error);
      throw error;
    }
  }

  // Votar en una propuesta
  async voteOnProposal(
    proposalId: string,
    vote: boolean, // true = a favor, false = en contra
    signer: any
  ): Promise<string> {
    try {
      const txb = new TransactionBlock();
      
      txb.moveCall({
        target: `${this.packageId}::dao::vote_on_proposal`,
        arguments: [
          txb.object(proposalId),
          txb.pure.bool(vote)
        ]
      });

      const result = await this.client.signAndExecuteTransactionBlock({
        transactionBlock: txb,
        signer,
        options: { showEffects: true }
      });

      return result.digest;

    } catch (error) {
      console.error('Error votando en propuesta:', error);
      throw error;
    }
  }

  // Datos simulados para desarrollo
  private getMockDaoData(daoId: string): DaoData {
    const mockData = {
      'tech-dao': {
        id: 'tech-dao',
        name: 'Tech Innovation DAO',
        description: 'DAO enfocado en innovación tecnológica y desarrollo',
        balance: 1250000,
        memberCount: 156,
        proposalCount: 8,
        treasuryAddress: '0x1521fb7afe1d0dc171c962',
        createdAt: Date.now() - 30 * 24 * 60 * 60 * 1000
      },
      'defi-dao': {
        id: 'defi-dao',
        name: 'DeFi Protocol DAO',
        description: 'Protocolo descentralizado para finanzas DeFi',
        balance: 890000,
        memberCount: 89,
        proposalCount: 5,
        treasuryAddress: '0xf17bca5583ae3f2bb6802c',
        createdAt: Date.now() - 20 * 24 * 60 * 60 * 1000
      },
      'governance-dao': {
        id: 'governance-dao',
        name: 'Governance & Strategy DAO',
        description: 'DAO para gobernanza y estrategia del ecosistema',
        balance: 2100000,
        memberCount: 234,
        proposalCount: 12,
        treasuryAddress: '0x69eb64bc9c0c7696336e56',
        createdAt: Date.now() - 45 * 24 * 60 * 60 * 1000
      }
    };

    return mockData[daoId as keyof typeof mockData] || mockData['tech-dao'];
  }

  private getMockProposals(_daoId: string): ProposalData[] {
    return [
      {
        id: '0x001',
        title: 'Actualización del protocolo v2.0',
        description: 'Propuesta para actualizar el protocolo a la versión 2.0 con nuevas funcionalidades',
        proposer: '0xabc...def',
        votesFor: 45,
        votesAgainst: 12,
        status: 'active',
        deadline: Date.now() + 5 * 24 * 60 * 60 * 1000,
        createdAt: Date.now() - 2 * 24 * 60 * 60 * 1000
      },
      {
        id: '0x002',
        title: 'Distribución de tokens de recompensa',
        description: 'Propuesta para distribuir tokens de recompensa a los contribuidores activos',
        proposer: '0x123...456',
        votesFor: 78,
        votesAgainst: 5,
        status: 'passed',
        deadline: Date.now() - 1 * 24 * 60 * 60 * 1000,
        createdAt: Date.now() - 7 * 24 * 60 * 60 * 1000
      }
    ];
  }
}

// Instancia singleton del servicio
export const suiDaoService = new SuiDaoService();

export default suiDaoService;
