# 📚 API Reference - DAO de Financiamiento

> **Referencia completa de todas las funciones públicas disponibles**

## 🎯 **Información General**

### 📦 **Package Information**
- **Package ID:** `dao_financing`
- **Module:** `dao_financing::dao`
- **Version:** 1.0.0
- **Network:** Sui Mainnet/Testnet

### 🔧 **Imports Necesarios**
```typescript
import { TransactionBlock } from '@mysten/sui.js/transactions';
import { SuiClient } from '@mysten/sui.js/client';
```

---

## 🏛️ **Core Functions**

### 1. `create_dao`

Crea una nueva DAO y la comparte globalmente para que todos puedan interactuar.

#### **Returns**
- **Type:** `(u64, u64)`
- **Description:** Tupla con (votes_for, votes_against)

#### **Example Usage**
```typescript
// Via RPC call (no gas cost)
const result = await suiClient.getObject({
  id: PROPOSAL_OBJECT_ID,
  options: {
    showContent: true,
    showType: true
  }
});

// Parse the votes_for and votes_against fields
const content = result.data?.content;
if (content && 'fields' in content) {
  const votesFor = content.fields.votes_for;
  const votesAgainst = content.fields.votes_against;
}
```

#### **Gas Cost**
- **Cost:** 0 (read-only function)

---

### 8. `has_voted`

Verifica si un usuario específico ya votó en una propuesta.

#### **Signature**
```move
public fun has_voted(proposal: &Proposal, voter: address): bool
```

#### **Parameters**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `proposal` | `&Proposal` | Referencia inmutable a la propuesta |
| `voter` | `address` | Dirección del votante a verificar |

#### **Returns**
- **Type:** `bool`
- **Description:** `true` si ya votó, `false` si no

#### **Example Usage**
```typescript
// Via Move call (for complex logic)
const tx = new TransactionBlock();
const hasVoted = tx.moveCall({
  target: `${PACKAGE_ID}::dao::has_voted`,
  arguments: [
    tx.object(PROPOSAL_OBJECT_ID),
    tx.pure(VOTER_ADDRESS, 'address')
  ],
});

// Or check dynamic fields directly
const dynamicFields = await suiClient.getDynamicFields({
  parentId: PROPOSAL_OBJECT_ID
});

const hasVoted = dynamicFields.data.some(field => 
  field.name.value === VOTER_ADDRESS
);
```

#### **Gas Cost**
- **Cost:** 0 (read-only via RPC) or ~100 units (via transaction)

---

### 9. `get_dao_info`

Obtiene información básica de una DAO.

#### **Signature**
```move
public fun get_dao_info(dao: &DAO): (String, u64, u64, bool)
```

#### **Parameters**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `dao` | `&DAO` | Referencia inmutable a la DAO |

#### **Returns**
- **Type:** `(String, u64, u64, bool)`
- **Description:** Tupla con (name, treasury_balance, proposal_count, active)

#### **Example Usage**
```typescript
// Via RPC call (recommended)
const result = await suiClient.getObject({
  id: DAO_OBJECT_ID,
  options: {
    showContent: true
  }
});

if (result.data?.content && 'fields' in result.data.content) {
  const fields = result.data.content.fields;
  const name = fields.name;
  const treasuryBalance = fields.treasury?.fields?.value || '0';
  const proposalCount = fields.proposal_count;
  const active = fields.active;
}
```

#### **Gas Cost**
- **Cost:** 0 (read-only function)

---

### 10. `can_execute`

Determina si una propuesta puede ser ejecutada.

#### **Signature**
```move
public fun can_execute(proposal: &Proposal): bool
```

#### **Parameters**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `proposal` | `&Proposal` | Referencia inmutable a la propuesta |

#### **Returns**
- **Type:** `bool`
- **Description:** `true` si puede ejecutarse, `false` si no

#### **Logic**
```move
!proposal.executed && 
proposal.votes_for > proposal.votes_against &&
proposal.status == PROPOSAL_ACTIVE
```

#### **Example Usage**
```typescript
// Via Move call
const tx = new TransactionBlock();
const canExecute = tx.moveCall({
  target: `${PACKAGE_ID}::dao::can_execute`,
  arguments: [tx.object(PROPOSAL_OBJECT_ID)]
});

// Or implement logic client-side
const proposalData = await getProposalData(PROPOSAL_OBJECT_ID);
const canExecute = 
  !proposalData.executed && 
  proposalData.votes_for > proposalData.votes_against &&
  proposalData.status === 0; // PROPOSAL_ACTIVE
```

#### **Gas Cost**
- **Cost:** 0 (read-only) or ~50 units (via transaction)

---

## 📋 **Data Structures**

### 🏛️ **DAO Object**
```typescript
interface DAO {
  id: string;                    // Object ID
  name: string;                  // DAO name
  treasury: {                    // Treasury balance
    type: string;                // "0x2::balance::Balance<0x2::sui::SUI>"
    fields: {
      value: string;             // Balance in MIST
    };
  };
  proposal_count: string;        // Number as string
  min_voting_power: string;      // Minimum power required
  active: boolean;               // DAO status
}
```

### 📝 **Proposal Object**
```typescript
interface Proposal {
  id: string;                    // Object ID
  dao_id: string;                // Parent DAO ID
  title: string;                 // Proposal title
  description: string;           // Detailed description
  amount_requested: string;      // Amount in MIST
  proposer: string;              // Proposer address
  deadline: string;              // Unix timestamp (future)
  executed: boolean;             // Execution status
  votes_for: string;             // Positive votes
  votes_against: string;         // Negative votes  
  status: number;                // Status enum (0-3)
}
```

### 🎫 **GovernanceToken Object**
```typescript
interface GovernanceToken {
  id: string;                    // Object ID
  dao_id: string;                // Parent DAO ID
  voting_power: string;          // Voting weight
}
```

### 🗳️ **Vote Object** (Dynamic Field)
```typescript
interface Vote {
  id: string;                    // Object ID
  support: boolean;              // Vote direction
  voting_power: string;          // Power used
  timestamp: string;             // Vote time (future)
}
```

---

## 🔍 **Query Patterns**

### 📊 **Getting DAO Overview**
```typescript
async function getDaoOverview(daoId: string) {
  const dao = await suiClient.getObject({
    id: daoId,
    options: { showContent: true, showType: true }
  });

  if (dao.data?.content && 'fields' in dao.data.content) {
    const fields = dao.data.content.fields;
    return {
      name: fields.name,
      treasury: fields.treasury?.fields?.value || '0',
      proposalCount: parseInt(fields.proposal_count),
      active: fields.active,
      minVotingPower: parseInt(fields.min_voting_power)
    };
  }
  
  throw new Error('DAO not found');
}
```

### 📝 **Finding All Proposals for a DAO**
```typescript
async function getDAOProposals(daoId: string) {
  // Query all Proposal objects
  const proposals = await suiClient.getOwnedObjects({
    filter: {
      StructType: `${PACKAGE_ID}::dao::Proposal`
    },
    options: { showContent: true }
  });

  // Filter by DAO ID
  return proposals.data
    .filter(obj => {
      if (obj.data?.content && 'fields' in obj.data.content) {
        return obj.data.content.fields.dao_id === daoId;
      }
      return false;
    })
    .map(obj => parseProposalObject(obj));
}
```

### 🗳️ **Getting All Votes for a Proposal**
```typescript
async function getProposalVotes(proposalId: string) {
  const dynamicFields = await suiClient.getDynamicFields({
    parentId: proposalId
  });

  const votes = await Promise.all(
    dynamicFields.data.map(async (field) => {
      const voteObject = await suiClient.getObject({
        id: field.objectId,
        options: { showContent: true }
      });

      if (voteObject.data?.content && 'fields' in voteObject.data.content) {
        return {
          voter: field.name.value,
          support: voteObject.data.content.fields.support,
          votingPower: voteObject.data.content.fields.voting_power,
          timestamp: voteObject.data.content.fields.timestamp
        };
      }
      return null;
    })
  );

  return votes.filter(vote => vote !== null);
}
```

### 🎫 **Finding User's Governance Tokens**
```typescript
async function getUserGovernanceTokens(userAddress: string, daoId?: string) {
  const ownedObjects = await suiClient.getOwnedObjects({
    owner: userAddress,
    filter: {
      StructType: `${PACKAGE_ID}::dao::GovernanceToken`
    },
    options: { showContent: true }
  });

  const tokens = ownedObjects.data
    .map(obj => parseGovernanceToken(obj))
    .filter(token => token !== null);

  // Filter by DAO if specified
  if (daoId) {
    return tokens.filter(token => token.dao_id === daoId);
  }

  return tokens;
}
```

---

## ⚡ **Batch Operations**

### 🔄 **Multi-Step Transactions**

#### **Create DAO + Mint Initial Tokens**
```typescript
function createDAOWithTokens(
  daoName: string,
  initialMembers: string[],
  tokenAmounts: number[]
) {
  const tx = new TransactionBlock();

  // 1. Create DAO
  tx.moveCall({
    target: `${PACKAGE_ID}::dao::create_dao`,
    arguments: [
      tx.pure(daoName),
      tx.pure(100, 'u64')
    ],
  });

  // 2. Get DAO object from first call
  // Note: This requires knowing the DAO ID after creation
  // In practice, you'd need to do this in separate transactions

  return tx;
}
```

#### **Vote on Multiple Proposals**
```typescript
function voteOnMultipleProposals(
  votes: Array<{
    proposalId: string;
    tokenId: string; 
    support: boolean;
  }>
) {
  const tx = new TransactionBlock();

  votes.forEach(vote => {
    tx.moveCall({
      target: `${PACKAGE_ID}::dao::cast_vote`,
      arguments: [
        tx.object(vote.proposalId),
        tx.object(vote.tokenId),
        tx.pure(vote.support, 'bool')
      ],
    });
  });

  return tx;
}
```

---

## 🚨 **Error Handling**

### 📋 **Error Codes Reference**
```typescript
const ERROR_CODES = {
  E_ALREADY_VOTED: 0,
  E_WRONG_DAO_TOKEN: 1,
  E_ALREADY_EXECUTED: 2,
  E_INSUFFICIENT_FUNDS: 3,
  E_PROPOSAL_REJECTED: 4,
  E_DAO_NOT_ACTIVE: 5,
} as const;

const ERROR_MESSAGES = {
  [ERROR_CODES.E_ALREADY_VOTED]: "Usuario ya votó en esta propuesta",
  [ERROR_CODES.E_WRONG_DAO_TOKEN]: "Token no pertenece a esta DAO",
  [ERROR_CODES.E_ALREADY_EXECUTED]: "Propuesta ya fue ejecutada",
  [ERROR_CODES.E_INSUFFICIENT_FUNDS]: "Fondos insuficientes en treasury",
  [ERROR_CODES.E_PROPOSAL_REJECTED]: "Propuesta fue rechazada por votación",
  [ERROR_CODES.E_DAO_NOT_ACTIVE]: "DAO está pausada o inactiva"
};
```

### 🔍 **Error Handling Example**
```typescript
async function executeProposal(daoId: string, proposalId: string) {
  try {
    const tx = new TransactionBlock();
    tx.moveCall({
      target: `${PACKAGE_ID}::dao::execute_proposal`,
      arguments: [
        tx.object(daoId),
        tx.object(proposalId)
      ],
    });

    const result = await suiClient.signAndExecuteTransactionBlock({
      transactionBlock: tx,
      signer: keypair,
    });

    return result;
  } catch (error) {
    if (error.message.includes('abort_code')) {
      const abortCode = extractAbortCode(error.message);
      const friendlyMessage = ERROR_MESSAGES[abortCode] || 'Error desconocido';
      throw new Error(`Error de ejecución: ${friendlyMessage}`);
    }
    throw error;
  }
}
```

---

## 📊 **Rate Limits y Performance**

### ⚡ **Request Limits**
| Endpoint Type | Rate Limit | Notes |
|---------------|------------|--------|
| **RPC Queries** | 100/second | Read-only operations |
| **Transactions** | 10/second | State-changing operations |
| **Object Queries** | 50/second | Individual object fetch |

### 🎯 **Performance Tips**

#### **1. Batch RPC Calls**
```typescript
// ❌ Multiple individual calls
const dao = await suiClient.getObject({ id: daoId });
const proposal1 = await suiClient.getObject({ id: proposalId1 });
const proposal2 = await suiClient.getObject({ id: proposalId2 });

// ✅ Single batch call
const [dao, proposal1, proposal2] = await suiClient.multiGetObjects({
  ids: [daoId, proposalId1, proposalId2],
  options: { showContent: true }
});
```

#### **2. Cache Static Data**
```typescript
// Cache DAO info since it changes infrequently
const daoCache = new Map<string, DAOInfo>();

async function getCachedDAOInfo(daoId: string) {
  if (daoCache.has(daoId)) {
    return daoCache.get(daoId);
  }
  
  const daoInfo = await getDaoOverview(daoId);
  daoCache.set(daoId, daoInfo);
  return daoInfo;
}
```

#### **3. Use Events for Real-time Updates**
```typescript
// Subscribe to DAO events instead of polling
suiClient.subscribeEvent({
  filter: {
    Package: PACKAGE_ID
  },
  onMessage: (event) => {
    // Handle ProposalCreated, VoteCast, ProposalExecuted
    updateUI(event);
  }
});
```

---

## 🧪 **Testing Utilities**

### 🔧 **Test Helpers**
```typescript
// Helper to create test DAO
export async function createTestDAO(
  name: string = "Test DAO",
  minPower: number = 100
) {
  const tx = new TransactionBlock();
  tx.moveCall({
    target: `${PACKAGE_ID}::dao::create_dao`,
    arguments: [
      tx.pure(name),
      tx.pure(minPower, 'u64')
    ],
  });

  const result = await suiClient.signAndExecuteTransactionBlock({
    transactionBlock: tx,
    signer: testKeypair,
  });

  // Extract DAO ID from transaction effects
  const daoId = extractCreatedObjectId(result, 'DAO');
  return daoId;
}

// Helper to create test proposal
export async function createTestProposal(
  daoId: string,
  title: string = "Test Proposal",
  amount: number = 1000000000
) {
  const tx = new TransactionBlock();
  tx.moveCall({
    target: `${PACKAGE_ID}::dao::create_proposal`,
    arguments: [
      tx.object(daoId),
      tx.pure(title),
      tx.pure("Test description"),
      tx.pure(amount, 'u64')
    ],
  });

  const result = await suiClient.signAndExecuteTransactionBlock({
    transactionBlock: tx,
    signer: testKeypair,
  });

  const proposalId = extractCreatedObjectId(result, 'Proposal');
  return proposalId;
}
```

---

## 🔗 **Integration Examples**

### 🌐 **Web3 Integration**
```typescript
import { ConnectButton, useWallet } from '@mysten/dapp-kit';

function DAOInterface() {
  const { currentWallet, signAndExecuteTransactionBlock } = useWallet();

  const castVote = async (proposalId: string, support: boolean) => {
    if (!currentWallet) return;

    // Get user's governance tokens
    const tokens = await getUserGovernanceTokens(
      currentWallet.accounts[0].address
    );

    if (tokens.length === 0) {
      throw new Error("No governance tokens found");
    }

    const tx = new TransactionBlock();
    tx.moveCall({
      target: `${PACKAGE_ID}::dao::cast_vote`,
      arguments: [
        tx.object(proposalId),
        tx.object(tokens[0].id),
        tx.pure(support, 'bool')
      ],
    });

    const result = await signAndExecuteTransactionBlock({
      transactionBlock: tx,
    });

    return result;
  };

  return (
    <div>
      <ConnectButton />
      {/* Your DAO UI components */}
    </div>
  );
}
```

---

## 📞 **Support and Resources**

### 🆘 **Getting Help**
- **Discord:** [Sui Latam Devs](https://discord.com/invite/QpdfBHgD6m)
- **Documentation:** [docs.sui.io](https://docs.sui.io/)
- **GitHub Issues:** [Create Issue](https://github.com/tu-usuario/sui-dao-financing/issues)

### 📚 **Additional Resources**
- [Sui TypeScript SDK Docs](https://sdk.mystenlabs.com/typescript)
- [Move Language Reference](https://move-language.github.io/)
- [Sui dApp Kit](https://sdk.mystenlabs.com/dapp-kit)

---

**📝 Última actualización:** 5 de Septiembre 2024  
**📚 Versión API:** 1.0  
**🔧 SDK Compatibility:** @mysten/sui.js ^0.45.0Signature**
```move
public fun create_dao(
    name: String,
    min_voting_power: u64,
    ctx: &mut TxContext
)
```

#### **Parameters**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `name` | `String` | Nombre legible de la DAO |
| `min_voting_power` | `u64` | Poder de voto mínimo requerido (futuro) |
| `ctx` | `&mut TxContext` | Contexto de transacción |

#### **Returns**
- **Type:** `void` (entry function)
- **Side Effects:** Crea y comparte objeto DAO globalmente

#### **Events Emitted**
- `DAOCreated` (futuro)

#### **Example Call**
```bash
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "Mi DAO Comunitaria" 100 \
  --gas-budget 20000000
```

#### **TypeScript Example**
```typescript
const tx = new TransactionBlock();
tx.moveCall({
  target: `${PACKAGE_ID}::dao::create_dao`,
  arguments: [
    tx.pure('Mi DAO Comunitaria'),
    tx.pure(100, 'u64')
  ],
});
```

#### **Gas Cost**
- **Estimated:** ~1,500 units
- **Factors:** String length, object creation

#### **Error Conditions**
- Ninguna (función básica de creación)

---

### 2. `create_proposal`

Crea una nueva propuesta de financiamiento en una DAO existente.

#### **Signature**
```move
public fun create_proposal(
    dao: &mut DAO,
    title: String,
    description: String,
    amount: u64,
    ctx: &mut TxContext
)
```

#### **Parameters**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `dao` | `&mut DAO` | Referencia mutable a la DAO |
| `title` | `String` | Título de la propuesta |
| `description` | `String` | Descripción detallada |
| `amount` | `u64` | Cantidad solicitada en SUI (en MIST) |
| `ctx` | `&mut TxContext` | Contexto de transacción |

#### **Returns**
- **Type:** `void` (entry function)
- **Side Effects:** 
  - Incrementa `dao.proposal_count`
  - Crea y comparte objeto Proposal

#### **Example Call**
```bash
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function create_proposal \
  --args $DAO_OBJECT_ID "Nuevo Proyecto" "Descripción detallada del proyecto" 1000000000 \
  --gas-budget 20000000
```

#### **TypeScript Example**
```typescript
const tx = new TransactionBlock();
tx.moveCall({
  target: `${PACKAGE_ID}::dao::create_proposal`,
  arguments: [
    tx.object(DAO_OBJECT_ID),
    tx.pure('Nuevo Proyecto'),
    tx.pure('Descripción detallada del proyecto'),
    tx.pure(1000000000, 'u64') // 1 SUI en MIST
  ],
});
```

#### **Gas Cost**
- **Estimated:** ~2,000 units
- **Factors:** String lengths, object creation, shared object modification

#### **Error Conditions**
| Error | Code | Descripción |
|-------|------|-------------|
| `E_DAO_NOT_ACTIVE` | 5 | La DAO está pausada/inactiva |

---

### 3. `cast_vote`

Permite a un usuario votar en una propuesta usando su token de gobernanza.

#### **Signature**
```move
public fun cast_vote(
    proposal: &mut Proposal,
    token: &GovernanceToken,
    support: bool,
    ctx: &mut TxContext
)
```

#### **Parameters**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `proposal` | `&mut Proposal` | Referencia mutable a la propuesta |
| `token` | `&GovernanceToken` | Token de gobernanza del votante |
| `support` | `bool` | `true` = a favor, `false` = en contra |
| `ctx` | `&mut TxContext` | Contexto de transacción |

#### **Returns**
- **Type:** `void` (entry function)
- **Side Effects:**
  - Actualiza contadores `votes_for`/`votes_against`
  - Crea dynamic field con el voto

#### **Example Call**
```bash
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function cast_vote \
  --args $PROPOSAL_OBJECT_ID $GOVERNANCE_TOKEN_ID true \
  --gas-budget 20000000
```

#### **TypeScript Example**
```typescript
const tx = new TransactionBlock();
tx.moveCall({
  target: `${PACKAGE_ID}::dao::cast_vote`,
  arguments: [
    tx.object(PROPOSAL_OBJECT_ID),
    tx.object(GOVERNANCE_TOKEN_ID),
    tx.pure(true, 'bool')
  ],
});
```

#### **Gas Cost**
- **Estimated:** ~800 units
- **Factors:** Dynamic field creation, counter updates

#### **Error Conditions**
| Error | Code | Descripción |
|-------|------|-------------|
| `E_ALREADY_VOTED` | 0 | El usuario ya votó en esta propuesta |
| `E_WRONG_DAO_TOKEN` | 1 | El token no pertenece a esta DAO |
| `E_PROPOSAL_NOT_ACTIVE` | - | La propuesta no está activa |

---

### 4. `execute_proposal`

Ejecuta una propuesta aprobada, transfiriendo los fondos al proposer.

#### **Signature**
```move
public fun execute_proposal(
    dao: &mut DAO,
    proposal: &mut Proposal,
    ctx: &mut TxContext
)
```

#### **Parameters**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `dao` | `&mut DAO` | Referencia mutable a la DAO |
| `proposal` | `&mut Proposal` | Referencia mutable a la propuesta |
| `ctx` | `&mut TxContext` | Contexto de transacción |

#### **Returns**
- **Type:** `void` (entry function)
- **Side Effects:**
  - Transfiere fondos de treasury a proposer
  - Marca propuesta como ejecutada
  - Actualiza status a `PROPOSAL_EXECUTED`

#### **Example Call**
```bash
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function execute_proposal \
  --args $DAO_OBJECT_ID $PROPOSAL_OBJECT_ID \
  --gas-budget 20000000
```

#### **TypeScript Example**
```typescript
const tx = new TransactionBlock();
tx.moveCall({
  target: `${PACKAGE_ID}::dao::execute_proposal`,
  arguments: [
    tx.object(DAO_OBJECT_ID),
    tx.object(PROPOSAL_OBJECT_ID)
  ],
});
```

#### **Gas Cost**
- **Estimated:** ~1,200 units
- **Factors:** Balance operations, coin creation, transfer

#### **Error Conditions**
| Error | Code | Descripción |
|-------|------|-------------|
| `E_ALREADY_EXECUTED` | 2 | La propuesta ya fue ejecutada |
| `E_INSUFFICIENT_FUNDS` | 3 | Treasury no tiene fondos suficientes |
| `E_PROPOSAL_REJECTED` | 4 | La propuesta perdió la votación |

---

### 5. `mint_governance_token`

Crea un nuevo token de gobernanza para un usuario específico.

#### **Signature**
```move
public fun mint_governance_token(
    dao: &DAO,
    to: address,
    voting_power: u64,
    ctx: &mut TxContext
)
```

#### **Parameters**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `dao` | `&DAO` | Referencia inmutable a la DAO |
| `to` | `address` | Dirección destinataria del token |
| `voting_power` | `u64` | Poder de voto del token |
| `ctx` | `&mut TxContext` | Contexto de transacción |

#### **Returns**
- **Type:** `void` (entry function)
- **Side Effects:** Crea y transfiere GovernanceToken al usuario

#### **Example Call**
```bash
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function mint_governance_token \
  --args $DAO_OBJECT_ID $USER_ADDRESS 100 \
  --gas-budget 20000000
```

#### **TypeScript Example**
```typescript
const tx = new TransactionBlock();
tx.moveCall({
  target: `${PACKAGE_ID}::dao::mint_governance_token`,
  arguments: [
    tx.object(DAO_OBJECT_ID),
    tx.pure(USER_ADDRESS, 'address'),
    tx.pure(100, 'u64')
  ],
});
```

#### **Gas Cost**
- **Estimated:** ~600 units
- **Factors:** Object creation, transfer operation

#### **Error Conditions**
- Ninguna (función básica de minting)

---

### 6. `fund_dao`

Añade fondos a la tesorería de la DAO.

#### **Signature**
```move
public fun fund_dao(dao: &mut DAO, payment: Coin<SUI>)
```

#### **Parameters**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `dao` | `&mut DAO` | Referencia mutable a la DAO |
| `payment` | `Coin<SUI>` | Moneda SUI para depositar |

#### **Returns**
- **Type:** `void`
- **Side Effects:** Incrementa balance de treasury

#### **Example Call**
```bash
# Primero obtener coins
sui client pay --input-amounts 1000000000 --recipients $PACKAGE_ID

sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function fund_dao \
  --args $DAO_OBJECT_ID $COIN_OBJECT_ID \
  --gas-budget 20000000
```

#### **TypeScript Example**
```typescript
const tx = new TransactionBlock();

// Crear coin de la cantidad deseada
const [coin] = tx.splitCoins(tx.gas, [tx.pure(1000000000)]);

tx.moveCall({
  target: `${PACKAGE_ID}::dao::fund_dao`,
  arguments: [
    tx.object(DAO_OBJECT_ID),
    coin
  ],
});
```

#### **Gas Cost**
- **Estimated:** ~400 units
- **Factors:** Balance join operation

#### **Error Conditions**
- Ninguna (función básica de funding)

---

## 📊 **Query Functions**

### 7. `get_proposal_votes`

Obtiene los contadores de votos de una propuesta.

#### **Signature**
```move
public fun get_proposal_votes(proposal: &Proposal): (u64, u64)
```

#### **Parameters**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `proposal` | `&Proposal` | Referencia inmutable a la propuesta |

#### **