# 🏗️ Día 4: Estructuras y Funciones Avanzadas

> **Fecha:** 5 de Septiembre 2024  
> **Duración:** 2.5 horas  
> **Objetivo:** Dominar estructuras complejas y patrones de funciones para nuestra DAO

## 🎯 Lo que aprenderemos hoy

- ✅ Estructuras complejas con múltiples campos
- ✅ Patrones de funciones entry vs públicas
- ✅ Manejo avanzado de referencias y ownership
- ✅ Validaciones y error handling
- ✅ Optimización de estructuras para gas

---

## 🏗️ 1. ESTRUCTURAS AVANZADAS

### 📊 **Evolución de Nuestras Estructuras**

#### **Versión Inicial (Simple)**
```move
struct DAO has key {
    id: UID,
    name: String,
    treasury: u64,  // ❌ Problemas: overflow, no es real Balance
}
```

#### **Versión Mejorada (Robusta)**
```move
struct DAO has key {
    id: UID,
    name: String,
    treasury: Balance<SUI>,      // ✅ Real balance type
    proposal_count: u64,         // ✅ Counter for proposals
    min_voting_power: u64,       // ✅ Governance threshold
    active: bool,                // ✅ Circuit breaker
    created_at: u64,             // ✅ Timestamp tracking
}
```

#### **Versión Final (Producción)**
```move
struct DAO has key {
    id: UID,
    name: String,
    description: String,         // ✅ Rich metadata
    treasury: Balance<SUI>,
    proposal_count: u64,
    min_voting_power: u64,
    max_proposal_amount: u64,    // ✅ Safety limit
    voting_period_ms: u64,       // ✅ Voting duration
    active: bool,
    admin: address,              // ✅ Emergency admin
    created_at: u64,
    last_updated: u64,           // ✅ Update tracking
}
```

### 🤔 **Decisiones de Diseño Explicadas**

#### **¿Por qué Balance<SUI> vs u64?**
```move
// ❌ Problemático
struct Treasury {
    amount: u64,  // Solo número, no es real dinero
}

// ✅ Correcto
struct Treasury {
    balance: Balance<SUI>,  // Real SUI tokens, no puede falsificarse
}
```

#### **¿Por qué contadores incrementales?**
```move
// ❌ Ineficiente
fun count_proposals(dao: &DAO): u64 {
    // Tendría que iterar sobre todos los objetos del mundo
    // Costo: O(n) donde n = total proposals
}

// ✅ Eficiente
struct DAO {
    proposal_count: u64,  // Costo: O(1)
}
```

---

## 🎯 2. PATRONES DE FUNCIONES

### 🔧 **Entry Functions vs Public Functions**

#### **Entry Functions - Para Usuarios Finales**
```move
// Entry = punto de entrada para transacciones
public entry fun create_dao_entry(
    name: vector<u8>,           // ✅ Primitivos más fáciles de llamar
    min_voting_power: u64,
    ctx: &mut TxContext
) {
    let dao = create_dao_internal(
        string::utf8(name),     // Convertir internamente
        min_voting_power,
        ctx
    );
    transfer::share_object(dao);
}

// Public = para otros contratos Move
public fun create_dao_internal(
    name: String,               // ✅ Tipos Move más ricos
    min_voting_power: u64,
    ctx: &mut TxContext
): DAO {
    DAO {
        id: object::new(ctx),
        name,
        treasury: balance::zero(),
        proposal_count: 0,
        min_voting_power,
        active: true,
        created_at: tx_context::epoch_timestamp_ms(ctx),
    }
}
```

#### **¿Cuándo usar cada uno?**

**Entry Functions:**
- ✅ Para llamadas desde CLI/dApps
- ✅ Manejan efectos secundarios (transfers, events)
- ✅ Parámetros simples (u64, bool, vector<u8>)
- ❌ No retornan valores

**Public Functions:**
- ✅ Para composabilidad entre contratos
- ✅ Retornan valores complejos
- ✅ Tipos Move ricos (String, Option<T>)
- ✅ Lógica pura sin efectos secundarios

### 🔄 **Patrón Híbrido Recomendado**

```move
// Entry wrapper para usuarios
public entry fun cast_vote_entry(
    proposal_id: address,
    token_id: address, 
    support: bool,
    ctx: &mut TxContext
) {
    // Obtener objetos
    let proposal = borrow_global_mut<Proposal>(proposal_id);
    let token = borrow_global<GovernanceToken>(token_id);
    
    // Llamar función pura
    let vote = cast_vote_internal(proposal, token, support, ctx);
    
    // Manejar efectos
    transfer::transfer(vote, tx_context::sender(ctx));
    event::emit(VoteCastEvent { ... });
}

// Función pura para lógica
public fun cast_vote_internal(
    proposal: &mut Proposal,
    token: &GovernanceToken, 
    support: bool,
    ctx: &mut TxContext
): Vote {
    // Toda la lógica de validación y creación
    // Sin efectos secundarios
}
```

---

## 🔒 3. VALIDACIONES ROBUSTAS

### 🛡️ **Layers de Validación**

#### **Layer 1: Validaciones de Tipo (Compile Time)**
```move
public fun cast_vote(
    proposal: &mut Proposal,    // ✅ Debe ser mutable
    token: &GovernanceToken,    // ✅ Solo lectura suficiente
    support: bool,              // ✅ Tipo específico
    ctx: &mut TxContext         // ✅ Contexto mutable
) {
    // Si llega aquí, los tipos son correctos
}
```

#### **Layer 2: Validaciones de Estado (Runtime)**
```move
public fun cast_vote(
    proposal: &mut Proposal,
    token: &GovernanceToken,
    support: bool,
    ctx: &mut TxContext
) {
    let voter = tx_context::sender(ctx);
    
    // === VALIDACIONES DE ESTADO ===
    
    // 1. Propuesta debe estar activa
    assert!(proposal.status == PROPOSAL_ACTIVE, E_PROPOSAL_NOT_ACTIVE);
    
    // 2. No debe haber votado antes
    assert!(
        !dynamic_field::exists_(&proposal.id, voter),
        E_ALREADY_VOTED
    );
    
    // 3. Token debe ser de la misma DAO
    assert!(token.dao_id == proposal.dao_id, E_WRONG_DAO_TOKEN);
    
    // 4. Token debe tener poder suficiente
    assert!(token.voting_power > 0, E_ZERO_VOTING_POWER);
    
    // 5. Propuesta no debe haber expirado (futuro)
    // assert!(current_time < proposal.deadline, E_PROPOSAL_EXPIRED);
    
    // Solo entonces proceder con la lógica...
}
```

#### **Layer 3: Validaciones de Negocio**
```move
public fun execute_proposal(
    dao: &mut DAO,
    proposal: &mut Proposal,
    ctx: &mut TxContext
) {
    // === VALIDACIONES DE NEGOCIO ===
    
    // 1. Quórum mínimo alcanzado
    let total_votes = proposal.votes_for + proposal.votes_against;
    let min_quorum = dao.min_voting_power * 3; // 3x minimum for quorum
    assert!(total_votes >= min_quorum, E_INSUFFICIENT_QUORUM);
    
    // 2. Mayoría simple
    assert!(proposal.votes_for > proposal.votes_against, E_PROPOSAL_REJECTED);
    
    // 3. Fondos suficientes disponibles
    assert!(
        balance::value(&dao.treasury) >= proposal.amount_requested,
        E_INSUFFICIENT_FUNDS
    );
    
    // 4. Cantidad dentro de límites permitidos
    assert!(
        proposal.amount_requested <= dao.max_proposal_amount,
        E_AMOUNT_TOO_HIGH
    );
    
    // 5. DAO debe estar activa
    assert!(dao.active, E_DAO_PAUSED);
    
    // Proceder con ejecución...
}
```

### 📋 **Error Codes Organizados**

```move
// === ACCESS CONTROL ERRORS ===
const E_UNAUTHORIZED: u64 = 100;
const E_WRONG_DAO_TOKEN: u64 = 101;
const E_INSUFFICIENT_POWER: u64 = 102;

// === STATE ERRORS ===
const E_PROPOSAL_NOT_ACTIVE: u64 = 200;
const E_PROPOSAL_EXPIRED: u64 = 201;
const E_ALREADY_VOTED: u64 = 202;
const E_ALREADY_EXECUTED: u64 = 203;
const E_DAO_PAUSED: u64 = 204;

// === BUSINESS LOGIC ERRORS ===
const E_INSUFFICIENT_FUNDS: u64 = 300;
const E_INSUFFICIENT_QUORUM: u64 = 301;
const E_PROPOSAL_REJECTED: u64 = 302;
const E_AMOUNT_TOO_HIGH: u64 = 303;
const E_ZERO_VOTING_POWER: u64 = 304;

// === SYSTEM ERRORS ===
const E_INVALID_TIMESTAMP: u64 = 400;
const E_OBJECT_NOT_FOUND: u64 = 401;
const E_COMPUTATION_ERROR: u64 = 402;
```

---

## ⚡ 4. OPTIMIZACIONES DE GAS

### 💰 **Gas Cost Analysis**

#### **Crear Objetos**
```move
// ❌ Ineficiente: Múltiples objetos
struct Vote has key {
    id: UID,              // Costo: ~200 units
    voter: address,       // Costo: ~32 units
    support: bool,        // Costo: ~1 unit
    metadata: VoteData,   // Costo: ~100 units
}
struct VoteData has store {
    timestamp: u64,
    comments: String,
}
// Total: ~333 units per vote

// ✅ Eficiente: Objeto simple
struct Vote has key, store {
    id: UID,              // Costo: ~200 units
    support: bool,        // Costo: ~1 unit
    voting_power: u64,    // Costo: ~8 units
    timestamp: u64,       // Costo: ~8 units
}
// Total: ~217 units per vote (35% saving)
```

#### **Storage vs Computation Trade-offs**

```move
// ❌ Computación costosa en cada consulta
public fun get_vote_results(proposal: &Proposal): (u64, u64) {
    let votes_for = 0;
    let votes_against = 0;
    
    // Iterar todos los dynamic fields (muy costoso)
    // Cost: O(n) donde n = número de votos
    
    (votes_for, votes_against)
}

// ✅ Storage pequeño, consultas rápidas
struct Proposal has key {
    // ... otros campos ...
    votes_for: u64,        // Costo storage: ~8 units
    votes_against: u64,    // Costo storage: ~8 units
}

public fun get_vote_results(proposal: &Proposal): (u64, u64) {
    // Costo: O(1) - instantáneo
    (proposal.votes_for, proposal.votes_against)
}
```

### 🚀 **Patrones de Optimización**

#### **1. Early Returns**
```move
public fun cast_vote(...) {
    // ✅ Verificaciones más baratas primero
    assert!(support == true || support == false, E_INVALID_VOTE); // Casi gratis
    assert!(token.voting_power > 0, E_ZERO_POWER); // Barato
    
    // Verificaciones más caras después
    assert!(!ofield::exists_(&proposal.id, voter), E_ALREADY_VOTED); // Caro
    assert!(complex_business_logic(), E_BUSINESS_ERROR); // Muy caro
}
```

#### **2. Batch Operations**
```move
// ❌ Múltiples transacciones
public entry fun mint_tokens_individual(
    dao: &DAO,
    recipient1: address, power1: u64,
    recipient2: address, power2: u64,
    ctx: &mut TxContext
) {
    mint_governance_token(dao, recipient1, power1, ctx); // TX 1
    mint_governance_token(dao, recipient2, power2, ctx); // TX 2
}

// ✅ Una sola transacción
public entry fun mint_tokens_batch(
    dao: &DAO,
    recipients: vector<address>,
    powers: vector<u64>,
    ctx: &mut TxContext
) {
    let i = 0;
    let len = vector::length(&recipients);
    while (i < len) {
        let recipient = *vector::borrow(&recipients, i);
        let power = *vector::borrow(&powers, i);
        mint_governance_token(dao, recipient, power, ctx);
        i = i + 1;
    };
}
```

---

## 🔄 5. PATTERNS AVANZADOS

### 🎯 **Witness Pattern**

```move
// Capability única para funciones administrativas
struct AdminCap has key, store {
    id: UID,
    dao_id: ID,
}

// Solo el que tiene AdminCap puede pausar
public fun pause_dao(
    dao: &mut DAO,
    _admin_cap: &AdminCap,  // Proof de autorización
) {
    dao.active = false;
}

// Transferir capacidades administrativas
public fun transfer_admin(
    admin_cap: AdminCap,
    new_admin: address
) {
    transfer::transfer(admin_cap, new_admin);
}
```

### 🔥 **Hot Potato Pattern**

```move
// Objeto que DEBE consumirse en la misma transacción
struct ProposalReceipt {
    dao_id: ID,
    amount: u64,
    // No tiene 'drop' - debe ser consumido explícitamente
}

public fun propose_funding(
    dao: &mut DAO,
    title: String,
    amount: u64,
    ctx: &mut TxContext
): ProposalReceipt {
    // Crear propuesta...
    dao.proposal_count = dao.proposal_count + 1;
    
    // Retornar receipt que DEBE ser consumido
    ProposalReceipt {
        dao_id: object::id(dao),
        amount,
    }
}

public fun finalize_proposal(
    receipt: ProposalReceipt,  // Debe consumirse
    additional_data: String,
    ctx: &mut TxContext
): Proposal {
    let ProposalReceipt { dao_id, amount } = receipt; // Consume receipt
    
    // Crear propuesta final
    Proposal {
        id: object::new(ctx),
        dao_id,
        amount_requested: amount,
        // ... más campos
    }
}
```

---

## 🧪 6. TESTING AVANZADO

### 🔧 **Test Helpers**

```move
#[test_only]
module dao_financing::test_helpers {
    use dao_financing::dao::{Self, DAO, Proposal, GovernanceToken};
    
    // Helper para crear DAO de prueba
    public fun create_test_dao(ctx: &mut TxContext): DAO {
        dao::create_dao_internal(
            string::utf8(b"Test DAO"),
            100,
            ctx
        )
    }
    
    // Helper para crear propuesta de prueba
    public fun create_test_proposal(
        dao: &mut DAO,
        amount: u64,
        ctx: &mut TxContext
    ): Proposal {
        dao::create_proposal_internal(
            dao,
            string::utf8(b"Test Proposal"),
            string::utf8(b"Test Description"),
            amount,
            ctx
        )
    }
    
    // Helper para crear token con poder específico
    public fun create_test_token(
        dao_id: ID,
        power: u64,
        ctx: &mut TxContext
    ): GovernanceToken {
        dao::create_governance_token(dao_id, power, ctx)
    }
}
```

### 🧪 **Tests de Integración**

```move
#[test]
fun test_full_voting_workflow() {
    let scenario_val = test_scenario::begin(@0x1);
    let scenario = &mut scenario_val;
    
    // Setup: Crear DAO
    let dao = test_helpers::create_test_dao(test_scenario::ctx(scenario));
    let dao_id = object::id(&dao);
    transfer::share_object(dao);
    
    test_scenario::next_tx(scenario, @0x1);
    let dao = test_scenario::take_shared<DAO>(scenario);
    
    // Setup: Crear propuesta
    let proposal = test_helpers::create_test_proposal(&mut dao, 1000000000, test_scenario::ctx(scenario));
    let proposal_id = object::id(&proposal);
    transfer::share_object(proposal);
    
    test_scenario::return_shared(dao);
    test_scenario::next_tx(scenario, @0x2); // Cambiar a voter
    
    // Setup: Crear token para voter
    let token = test_helpers::create_test_token(dao_id, 500, test_scenario::ctx(scenario));
    let proposal = test_scenario::take_shared<Proposal>(scenario);
    
    // Test: Votar
    dao::cast_vote_internal(&mut proposal, &token, true, test_scenario::ctx(scenario));
    
    // Verify: Votos actualizados
    let (votes_for, votes_against) = dao::get_vote_results(&proposal);
    assert!(votes_for == 500, 0);
    assert!(votes_against == 0, 1);
    
    // Cleanup
    test_scenario::return_shared(proposal);
    transfer::transfer(token, @0x2);
    test_scenario::end(scenario_val);
}
```

---

## 🤔 DUDAS Y PREGUNTAS

### ❓ Resueltas:
1. **¿Entry vs Public?** → Entry para usuarios, Public para contratos
2. **¿Cuántas validaciones?** → Tantas como sean necesarias para seguridad
3. **¿Storage vs Computation?** → Storage barato para queries frecuentes

### ❓ Pendientes:
1. ¿Cómo manejar upgrades de estructuras?
2. ¿Patrones para migración de datos?
3. ¿Límites prácticos de dynamic fields?

---

## ✅ RESUMEN DEL DÍA

**Lo que dominamos:**
- ✅ Estructuras robustas con campos optimizados
- ✅ Patrones entry/public para diferentes casos de uso
- ✅ Validaciones en capas para máxima seguridad
- ✅ Optimizaciones de gas efectivas
- ✅ Patrones avanzados (Witness, Hot Potato)
- ✅ Testing exhaustivo con helpers

**Insights importantes:**
- Las estructuras evolucionan - planear para el futuro
- Las validaciones son inversión, no costo
- Gas optimization requiere trade-offs conscientes
- Los patterns avanzados resuelven problemas reales

**Próximos pasos:**
- [ ] Implementación final con todas las optimizaciones
- [ ] Testing exhaustivo de casos edge
- [ ] Documentación de patterns utilizados
- [ ] Preparación para deployment

---

## 📝 NOTAS PERSONALES

- Las estructuras bien diseñadas ahorran problemas futuros
- Las validaciones exhaustivas dan confianza al deployment
- Los patterns avanzados no son solo "cool" - resuelven problemas reales
- El balance entre simplicidad y robustez es un arte

**Tiempo invertido:** 2.5 horas  
**Dificultad:** ⭐⭐⭐⭐⚪ (4/5)  
**Siguiente sesión:** Live coding - implementación final