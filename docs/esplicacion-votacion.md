# 🗳️ Sistema de Votación - Explicación Detallada

> **Comprende cómo funciona el proceso democrático de toma de decisiones en la DAO**

## 🎯 **¿Qué es el Sistema de Votación?**

El **sistema de votación** es el mecanismo democrático que permite a los miembros de la DAO participar en la toma de decisiones. Cada miembro con un token de gobernanza puede votar en las propuestas, y su poder de voto está determinado por el `voting_power` de su token.

---

## 🏗️ **Arquitectura del Sistema**

### 🎫 **Token de Gobernanza**
```move
public struct GovernanceToken has key, store {
    id: UID,
    dao_id: ID,
    voting_power: u64,
}
```

### 🗳️ **Estructura de Voto**
```move
public struct Vote has store {
    support: bool,      // true = a favor, false = en contra
    voting_power: u64,  // Poder de voto aplicado
}
```

### 📊 **Almacenamiento de Votos**
Los votos se almacenan como **dynamic fields** en la propuesta:
```move
// Key: address del votante
// Value: Vote struct
df::add(&mut proposal.id, voter_address, vote);
```

---

## ⚡ **Proceso de Votación**

### 📝 **Función cast_vote**
```move
public fun cast_vote(
    proposal: &mut Proposal,
    token: &GovernanceToken,
    support: bool,
    ctx: &mut TxContext
)
```

### 🔍 **Validaciones Pre-Voto**
```move
// 1. Verificar que la propuesta está activa
assert!(proposal.status == PROPOSAL_ACTIVE, E_PROPOSAL_NOT_ACTIVE);

// 2. Verificar que el token pertenece a la DAO correcta
assert!(token.dao_id == proposal.dao_id, E_WRONG_DAO_TOKEN);

// 3. Verificar que el token tiene poder de voto
assert!(token.voting_power > 0, E_ZERO_VOTING_POWER);

// 4. Verificar que no ha votado antes
let voter = tx_context::sender(ctx);
assert!(!df::exists_<address>(&proposal.id, voter), E_ALREADY_VOTED);
```

### 📊 **Registro del Voto**
```move
// Crear registro del voto
let vote = Vote {
    support,
    voting_power: token.voting_power,
};

// Almacenar en dynamic field
df::add(&mut proposal.id, voter, vote);

// Actualizar contadores de la propuesta
if (support) {
    proposal.votes_for = proposal.votes_for + token.voting_power;
} else {
    proposal.votes_against = proposal.votes_against + token.voting_power;
}
```

### 📡 **Emisión de Evento**
```move
event::emit(VoteCast {
    proposal_id: object::id(proposal),
    voter,
    support,
    voting_power: token.voting_power,
});
```

---

## 📊 **Conteo y Resultados**

### 🧮 **Acumulación de Votos**
```move
// Votos a favor: suma de voting_power de todos los votos con support=true
votes_for: u64

// Votos en contra: suma de voting_power de todos los votos con support=false  
votes_against: u64
```

### 🎯 **Determinación del Resultado**
```move
public fun can_execute(proposal: &Proposal): bool {
    proposal.status == PROPOSAL_ACTIVE &&
    !proposal.executed &&
    proposal.votes_for > proposal.votes_against  // Mayoría simple
}
```

### 📈 **Ejemplo de Conteo**
```
Votantes:
- Alice (token poder 1000) → A FAVOR
- Bob (token poder 800) → A FAVOR  
- Charlie (token poder 500) → EN CONTRA

Resultado:
votes_for = 1000 + 800 = 1800
votes_against = 500
Resultado: 1800 > 500 → PROPUESTA APROBADA ✅
```

---

## 🔍 **Consultas del Sistema**

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

### 🎫 **get_token_info**
```move
public fun get_token_info(token: &GovernanceToken): (ID, u64) {
    (token.dao_id, token.voting_power)
}
```

---

## 🛡️ **Protecciones de Seguridad**

### 🚫 **Prevención de Doble Votación**
```move
// Verificar antes de votar
assert!(!df::exists_<address>(&proposal.id, voter), E_ALREADY_VOTED);

// Un token solo puede votar una vez por propuesta
// El dynamic field con la address del votante actúa como lock
```

### 🔒 **Verificación de Autorización**
```move
// Solo tokens de la DAO correcta pueden votar
assert!(token.dao_id == proposal.dao_id, E_WRONG_DAO_TOKEN);

// Solo tokens con poder de voto pueden participar
assert!(token.voting_power > 0, E_ZERO_VOTING_POWER);
```

### ⏰ **Estado de Propuesta**
```move
// Solo propuestas activas pueden recibir votos
assert!(proposal.status == PROPOSAL_ACTIVE, E_PROPOSAL_NOT_ACTIVE);
```

---

## 🎭 **Tipos de Voto**

### ✅ **Voto A Favor (support = true)**
```move
// Incrementa votes_for
proposal.votes_for = proposal.votes_for + voting_power;

// Indica apoyo al proyecto propuesto
// Contribuye a la aprobación de la propuesta
```

### ❌ **Voto En Contra (support = false)**  
```move
// Incrementa votes_against
proposal.votes_against = proposal.votes_against + voting_power;

// Indica oposición al proyecto propuesto
// Previene la aprobación de la propuesta
```

### 🤔 **Abstención**
```
// No implementada actualmente
// Los miembros que no votan simplemente no participan
// Su poder de voto no se cuenta para ningún lado
```

---

## 📊 **Poder de Voto**

### 🎫 **Distribución del Poder**
```move
// Cada token tiene voting_power configurable
GovernanceToken {
    voting_power: u64,  // Puede ser cualquier valor > 0
}
```

### ⚖️ **Ejemplos de Distribución**

#### **🌟 Distribución Igualitaria**
```
Fundador: 1000 votos
Miembro A: 1000 votos  
Miembro B: 1000 votos
Total: 3000 votos (cada uno tiene 33.3%)
```

#### **🏛️ Distribución Jerárquica**
```
Fundador: 2000 votos (50%)
Desarrollador Senior: 1500 votos (37.5%)
Miembro Junior: 500 votos (12.5%)
Total: 4000 votos
```

#### **💰 Distribución por Contribución**
```
Inversor Principal: 5000 votos
Desarrollador: 2000 votos
Community Manager: 1000 votos
Miembros: 500 votos c/u
```

---

## 🔄 **Flujo Completo de Votación**

### 📝 **1. Preparación**
```bash
# Verificar propuesta activa
sui client call --function get_proposal_info --args $PROPOSAL_ID

# Verificar tu token de gobernanza
sui client call --function get_token_info --args $TOKEN_ID

# Verificar si ya votaste
sui client call --function has_voted --args $PROPOSAL_ID $(sui client active-address)
```

### 🗳️ **2. Votación**
```bash
# Votar A FAVOR
sui client call \
  --function cast_vote \
  --args $PROPOSAL_ID $TOKEN_ID true

# Votar EN CONTRA  
sui client call \
  --function cast_vote \
  --args $PROPOSAL_ID $TOKEN_ID false
```

### 📊 **3. Verificación**
```bash
# Ver conteo actualizado
sui client call --function get_proposal_votes --args $PROPOSAL_ID

# Ver tu voto específico
sui client call --function get_vote --args $PROPOSAL_ID $(sui client active-address)

# Verificar si puede ejecutarse
sui client call --function can_execute --args $PROPOSAL_ID
```

---

## 🚨 **Códigos de Error**

### ❌ **Errores de Votación**
```move
const E_ALREADY_VOTED: u64 = 1;           // Ya votó con este token
const E_WRONG_DAO_TOKEN: u64 = 2;         // Token no pertenece a esta DAO
const E_PROPOSAL_NOT_ACTIVE: u64 = 3;     // Propuesta no está activa
const E_ZERO_VOTING_POWER: u64 = 7;       // Token sin poder de voto
```

### 🔧 **Soluciones Comunes**
```move
// E_ALREADY_VOTED: Cada token solo puede votar una vez
// Solución: Usar un token diferente o esperar nueva propuesta

// E_WRONG_DAO_TOKEN: El token debe pertenecer a la DAO de la propuesta
// Solución: Verificar dao_id del token y la propuesta

// E_PROPOSAL_NOT_ACTIVE: Solo propuestas activas reciben votos
// Solución: Verificar status de la propuesta

// E_ZERO_VOTING_POWER: El token debe tener poder de voto > 0
// Solución: Obtener token con voting_power válido
```

---

## 📡 **Eventos de Votación**

### 🗳️ **VoteCast**
```move
public struct VoteCast has copy, drop {
    proposal_id: ID,        // ID de la propuesta votada
    voter: address,         // Dirección del votante
    support: bool,          // Tipo de voto (a favor/en contra)
    voting_power: u64,      // Poder de voto aplicado
}
```

### 📊 **Utilidad de los Eventos**
- **🔍 Transparencia**: Todos los votos son públicos
- **📈 Analytics**: Analizar patrones de votación
- **🤖 Bots**: Automatización basada en votos
- **📱 UIs**: Actualizar interfaces en tiempo real

---

## 🎯 **Estrategias de Votación**

### 🏛️ **Para DAOs Pequeñas**
```
- Mayoría simple (50% + 1 voto)
- Participación mínima no requerida
- Votación abierta indefinidamente
- Poder de voto igualitario
```

### 🏢 **Para DAOs Grandes**
```
- Quórum mínimo requerido
- Período de votación limitado
- Múltiples categorías de propuestas
- Delegación de votos (futuro)
```

### 💼 **Para DAOs Empresariales**
```
- Votación ponderada por contribución
- Múltiples rondas de votación
- Veto por stakeholders clave
- Auditoría de decisiones
```

---

## 🔮 **Mejoras Futuras**

### 🚀 **V1.1 - Próximas Características**
- **⏰ Timelock**: Período entre aprobación y ejecución
- **📅 Deadlines**: Tiempo límite para votar
- **🎯 Quórum**: Participación mínima requerida
- **🔄 Voto múltiple**: Permitir cambiar voto antes del deadline

### 🌟 **V2.0 - Características Avanzadas**
- **🎭 Delegación**: Delegar votos a otros miembros
- **📊 Votación cuadrática**: Poder de voto no lineal
- **🏆 Reputación**: Votos ponderados por historial
- **🔐 Votación privada**: Votos ocultos hasta el final

---

## 📊 **Métricas y Analytics**

### 📈 **Participación**
```
Tasa de participación = (Votantes únicos / Total de token holders) * 100
Poder de voto utilizado = (Votos emitidos / Total voting_power) * 100
```

### 🎯 **Consenso**
```
Consenso = |votes_for - votes_against| / (votes_for + votes_against)
0 = Empate perfecto
1 = Consenso total
```

### ⏱️ **Velocidad**
```
Tiempo promedio de decisión = (Tiempo desde creación hasta ejecución)
Velocidad de votación = (Votos en primeras 24h / Total de votos)
```

---

## 🎓 **Casos de Estudio**

### ✅ **Propuesta Exitosa**
```
Propuesta: "Desarrollo de DApp NFT"
Votantes: 15 miembros
Resultado: 12,000 a favor vs 3,000 en contra
Consenso: 60% a favor
Tiempo: 3 días desde creación hasta ejecución
```

### ❌ **Propuesta Rechazada**
```
Propuesta: "Compra de servidor dedicado"
Votantes: 10 miembros  
Resultado: 4,000 a favor vs 8,000 en contra
Consenso: 66% en contra
Estado: Propuesta no ejecutable
```

### ⏳ **Propuesta Estancada**
```
Propuesta: "Cambio de logo de la DAO"
Votantes: 5 miembros
Resultado: 2,500 a favor vs 2,500 en contra
Consenso: Empate perfecto (0%)
Estado: Necesita más participación
```

---

## 📚 **Recursos Relacionados**

- **🏛️ DAO Principal**: [`esplicacion-dao.md`](esplicacion-dao.md)
- **📝 Propuestas**: [`esplicacion-propuesta.md`](esplicacion-propuesta.md)
- **⚡ Ejecución**: [`esplicacion-ejecucion.md`](esplicacion-ejecucion.md)
- **🎫 Tokens**: [`esplicacion-tokens.md`](esplicacion-tokens.md)
- **🧪 Tests**: [`esplicacion-tests.md`](esplicacion-tests.md)

---

**🗳️ El sistema de votación es la columna vertebral de la democracia descentralizada. Cada voto cuenta y contribuye a construir el futuro de la organización.**
