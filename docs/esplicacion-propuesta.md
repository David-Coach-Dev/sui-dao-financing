# 📝 Sistema de Propuestas - Explicación Detallada

> **Comprende cómo funcionan las propuestas de financiamiento en la DAO**

## 🎯 **¿Qué es una Propuesta?**

Una **propuesta** es una solicitud formal para que la DAO transfiera fondos de su tesorería a un destinatario específico para un proyecto o propósito determinado. Es el mecanismo principal a través del cual los miembros de la DAO pueden solicitar financiamiento para sus iniciativas.

---

## 🏗️ **Estructura de una Propuesta**

### 📋 **Proposal Struct**
```move
public struct Proposal has key, store {
    id: UID,                    // Identificador único de la propuesta
    dao_id: ID,                 // ID de la DAO a la que pertenece
    title: String,              // Título descriptivo de la propuesta
    amount: u64,                // Cantidad solicitada en MIST (1 SUI = 1,000,000,000 MIST)
    recipient: address,         // Dirección que recibirá los fondos
    proposer: address,          // Dirección del creador de la propuesta
    votes_for: u64,             // Total de votos a favor
    votes_against: u64,         // Total de votos en contra
    executed: bool,             // Si la propuesta ya fue ejecutada
    status: u8,                 // Estado actual de la propuesta
}
```

### 🔍 **Campos Explicados**

#### **🆔 Identificación**
- **`id`**: Identificador único generado automáticamente
- **`dao_id`**: Vincula la propuesta a una DAO específica
- **`proposer`**: Quien creó la propuesta (debe tener token de gobernanza)

#### **📝 Descripción**
- **`title`**: Nombre del proyecto o iniciativa (ej: "Desarrollo de DApp NFT")
- **`amount`**: Fondos solicitados en MIST (unidad mínima de SUI)
- **`recipient`**: Quien recibirá los fondos (puede ser diferente al proposer)

#### **🗳️ Votación**
- **`votes_for`**: Suma del poder de voto de todos los votos a favor
- **`votes_against`**: Suma del poder de voto de todos los votos en contra

#### **⚡ Ejecución**
- **`executed`**: Flag que indica si ya se transfirieron los fondos
- **`status`**: Estado numérico de la propuesta

---

## 📊 **Estados de Propuesta**

### 🎯 **Constantes de Estado**
```move
const PROPOSAL_ACTIVE: u8 = 0;      // Propuesta activa, puede recibir votos
const PROPOSAL_APPROVED: u8 = 1;    // Mayoría a favor (no usado actualmente)
const PROPOSAL_REJECTED: u8 = 2;    // Mayoría en contra (no usado actualmente)
const PROPOSAL_EXECUTED: u8 = 3;    // Propuesta ejecutada exitosamente
```

### 🔄 **Flujo de Estados**
```
📝 CREACIÓN
    ↓
🟢 ACTIVE (0) ← Puede recibir votos
    ↓
⚡ EXECUTED (3) ← Fondos transferidos
```

**Nota**: Los estados APPROVED (1) y REJECTED (2) están definidos pero no se usan en la implementación actual.

---

## 🔧 **Crear una Propuesta**

### 📝 **Función submit_proposal**
```move
public fun submit_proposal(
    dao: &mut DAO,
    title: String,
    amount: u64,
    recipient: address,
    token: &GovernanceToken,
    ctx: &mut TxContext
): ID
```

### ✅ **Validaciones**
1. **Token válido**: El token debe pertenecer a la DAO
2. **Poder de voto**: El token debe tener voting_power > 0
3. **Formato de datos**: Title y recipient válidos

### 🎯 **Proceso de Creación**
```move
// 1. Crear nueva propuesta
let proposal = Proposal {
    id: object::new(ctx),
    dao_id: object::id(dao),
    title,
    amount,
    recipient,
    proposer: tx_context::sender(ctx),
    votes_for: 0,
    votes_against: 0,
    executed: false,
    status: PROPOSAL_ACTIVE,
};

// 2. Incrementar contador
dao.proposal_count = dao.proposal_count + 1;

// 3. Hacer pública la propuesta
let proposal_id = object::id(&proposal);
transfer::share_object(proposal);

// 4. Emitir evento
event::emit(ProposalCreated {
    proposal_id,
    dao_id: object::id(dao),
    title,
    amount,
    proposer: tx_context::sender(ctx),
});
```

---

## 🗳️ **Votación en Propuestas**

### 📊 **Registro de Votos**
Los votos se almacenan usando **dynamic fields** en la propuesta:
```move
// Key: address del votante
// Value: Vote struct con detalles del voto
df::add(&mut proposal.id, voter_address, vote_details);
```

### 🔍 **Vote Struct**
```move
public struct Vote has store {
    support: bool,      // true = a favor, false = en contra
    voting_power: u64,  // Poder de voto usado
}
```

### ⚡ **Función cast_vote**
```move
public fun cast_vote(
    proposal: &mut Proposal,
    token: &GovernanceToken,
    support: bool,
    ctx: &mut TxContext
)
```

### 📈 **Actualización de Conteos**
```move
if (support) {
    proposal.votes_for = proposal.votes_for + voting_power;
} else {
    proposal.votes_against = proposal.votes_against + voting_power;
}
```

---

## ⚡ **Ejecución de Propuestas**

### 🎯 **Condiciones para Ejecución**
Una propuesta puede ejecutarse si:
1. **Estado activo**: `status == PROPOSAL_ACTIVE`
2. **No ejecutada**: `executed == false`
3. **Mayoría a favor**: `votes_for > votes_against`

### 🔍 **Función can_execute**
```move
public fun can_execute(proposal: &Proposal): bool {
    proposal.status == PROPOSAL_ACTIVE &&
    !proposal.executed &&
    proposal.votes_for > proposal.votes_against
}
```

### ⚡ **Función execute_proposal**
```move
public fun execute_proposal(
    dao: &mut DAO,
    proposal: &mut Proposal,
    ctx: &mut TxContext
)
```

### 📊 **Proceso de Ejecución**
```move
// 1. Validar que puede ejecutarse
assert!(can_execute(proposal), E_PROPOSAL_NOT_EXECUTABLE);

// 2. Verificar fondos suficientes
assert!(balance::value(&dao.balance) >= proposal.amount, E_INSUFFICIENT_FUNDS);

// 3. Crear moneda y transferir
let coin = coin::take(&mut dao.balance, proposal.amount, ctx);
transfer::public_transfer(coin, proposal.recipient);

// 4. Actualizar estado
proposal.executed = true;
proposal.status = PROPOSAL_EXECUTED;

// 5. Emitir evento
event::emit(ProposalExecuted {
    proposal_id: object::id(proposal),
    amount: proposal.amount,
    recipient: proposal.recipient,
});
```

---

## 🔍 **Consultas de Propuestas**

### 📋 **get_proposal_info**
```move
public fun get_proposal_info(proposal: &Proposal): (String, u64, address, bool, u8) {
    (proposal.title, proposal.amount, proposal.proposer, proposal.executed, proposal.status)
}
```

### 📊 **get_proposal_votes**
```move
public fun get_proposal_votes(proposal: &Proposal): (u64, u64) {
    (proposal.votes_for, proposal.votes_against)
}
```

### 🗳️ **get_vote**
```move
public fun get_vote(proposal: &Proposal, voter: address): (bool, u64) {
    let vote = df::borrow<address, Vote>(&proposal.id, voter);
    (vote.support, vote.voting_power)
}
```

### ✅ **has_voted**
```move
public fun has_voted(proposal: &Proposal, voter: address): bool {
    df::exists_<address>(&proposal.id, voter)
}
```

---

## 🚨 **Códigos de Error**

### ❌ **Errores de Propuesta**
```move
const E_PROPOSAL_NOT_ACTIVE: u64 = 3;          // Propuesta no está activa
const E_PROPOSAL_NOT_EXECUTABLE: u64 = 4;      // No puede ejecutarse
const E_PROPOSAL_ALREADY_EXECUTED: u64 = 5;    // Ya fue ejecutada
const E_INSUFFICIENT_FUNDS: u64 = 6;           // DAO sin fondos suficientes
```

### 🔍 **Cuándo Ocurren**
- **E_PROPOSAL_NOT_ACTIVE**: Al votar en propuesta ejecutada
- **E_PROPOSAL_NOT_EXECUTABLE**: Al ejecutar sin mayoría
- **E_PROPOSAL_ALREADY_EXECUTED**: Al ejecutar dos veces
- **E_INSUFFICIENT_FUNDS**: Al ejecutar sin balance suficiente

---

## 📡 **Eventos de Propuesta**

### 📝 **ProposalCreated**
```move
public struct ProposalCreated has copy, drop {
    proposal_id: ID,
    dao_id: ID,
    title: String,
    amount: u64,
    proposer: address,
}
```

### ⚡ **ProposalExecuted**
```move
public struct ProposalExecuted has copy, drop {
    proposal_id: ID,
    amount: u64,
    recipient: address,
}
```

### 🗳️ **VoteCast**
```move
public struct VoteCast has copy, drop {
    proposal_id: ID,
    voter: address,
    support: bool,
    voting_power: u64,
}
```

---

## 🎯 **Casos de Uso Comunes**

### 💻 **Financiamiento de Desarrollo**
```
Título: "Desarrollo de DApp de NFTs"
Cantidad: 2,000,000,000 MIST (2 SUI)
Destinatario: Desarrollador de la comunidad
Uso: Crear plataforma de NFTs para la DAO
```

### 🎓 **Programa Educativo**
```
Título: "Taller de Move para la Comunidad"
Cantidad: 500,000,000 MIST (0.5 SUI)
Destinatario: Instructor certificado
Uso: Materiales y tiempo de enseñanza
```

### 💝 **Donación Benéfica**
```
Título: "Donación para Refugio Animal"
Cantidad: 1,000,000,000 MIST (1 SUI)
Destinatario: Organización benéfica verificada
Uso: Apoyo a causa social
```

---

## 🔧 **Mejores Prácticas**

### ✅ **Para Proposers**
1. **Título claro**: Describe exactamente qué harás con los fondos
2. **Cantidad justa**: Solicita lo necesario, no más
3. **Destinatario correcto**: Verifica la dirección de recepción
4. **Engagement**: Participa en la discusión de tu propuesta

### ✅ **Para Votantes**
1. **Revisar detalles**: Lee toda la información antes de votar
2. **Verificar historial**: Considera la reputación del proposer
3. **Evaluar impacto**: ¿Beneficia a la comunidad?
4. **Participar activamente**: No solo votes, también discute

### ✅ **Para Ejecutores**
1. **Verificar condiciones**: Asegúrate que puede ejecutarse
2. **Monitorear gas**: Ten suficiente SUI para gas fees
3. **Confirmar resultado**: Verifica que la transferencia fue exitosa
4. **Notificar comunidad**: Informa cuando ejecutes

---

## 🔮 **Futuras Mejoras**

### 🚀 **V1.1 - Mejoras Planeadas**
- **⏰ Timelock**: Período de espera antes de ejecutar
- **📝 Descripciones**: Campo para descripción detallada
- **📅 Fechas límite**: Tiempo límite para votación
- **🔄 Cancelación**: Permitir cancelar propuestas

### 🌟 **V2.0 - Características Avanzadas**
- **📊 Categorías**: Tipos de propuestas (desarrollo, marketing, etc.)
- **💰 Presupuestos**: Límites por categoría
- **🎯 Milestones**: Propuestas con entregas parciales
- **🔗 Dependencias**: Propuestas que dependen de otras

---

## 📚 **Recursos Relacionados**

- **🏛️ DAO Principal**: [`esplicacion-dao.md`](esplicacion-dao.md)
- **🗳️ Sistema de Votación**: [`esplicacion-votacion.md`](esplicacion-votacion.md)
- **⚡ Ejecución**: [`esplicacion-ejecucion.md`](esplicacion-ejecucion.md)
- **🎫 Tokens**: [`esplicacion-tokens.md`](esplicacion-tokens.md)
- **🧪 Tests**: [`esplicacion-tests.md`](esplicacion-tests.md)

---

**🎯 Las propuestas son el corazón de la democracia en la DAO. A través de ellas, la comunidad decide cómo usar sus recursos para el beneficio colectivo.**
