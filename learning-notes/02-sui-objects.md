# 🎯 Día 2: Objetos en Sui

> **Fecha:** 2 de Septiembre 2024  
> **Duración:** 2.5 horas  
> **Objetivo:** Dominar el sistema de objetos de Sui para implementar nuestra DAO

## 🎯 Lo que aprenderemos hoy

- ✅ Qué son los objetos en Sui
- ✅ UID vs ID - Identificadores únicos
- ✅ Ownership y transferencias
- ✅ Object wrapping y dynamic fields
- ✅ Aplicarlo a nuestra DAO

---

## 🧱 1. ¿QUÉ SON LOS OBJETOS EN SUI?

En Sui, **TODO son objetos**. A diferencia de Ethereum donde tienes "contratos" y "cuentas", en Sui tienes objetos únicos que:

- Tienen un **identificador único** (UID)
- Pertenecen a alguien (**ownership**)
- Pueden **transferirse** entre usuarios
- Contienen **datos y lógica**

### 🏗️ Anatomía de un objeto:
```move
struct MiObjeto has key {
    id: UID,           // ← Identificador ÚNICO en todo Sui
    datos: u64,        // ← Información que guarda
    owner: address,    // ← A quién pertenece (opcional)
}
```

### 🎯 Para nuestra DAO:
```move
// Nuestra DAO es UN OBJETO único en el mundo
struct DAO has key {
    id: UID,                    // Identificador único de esta DAO
    name: String,               // Nombre de la DAO
    treasury: Balance<SUI>,     // Dinero de la DAO
    proposal_count: u64,        // Contador de propuestas
    min_voting_power: u64,      // Mínimo poder para votar
}

// Cada propuesta es UN OBJETO independiente
struct Proposal has key {
    id: UID,                    // Su propio ID único
    dao_id: ID,                 // Referencia a qué DAO pertenece
    title: String,
    // ... más campos
}
```

---

## 🆔 2. UID vs ID - IDENTIFICADORES

### UID (Unique Identifier)
- **Para el objeto que POSEE el ID**
- Se crea con `object::new(ctx)`
- Solo el objeto actual puede tenerlo

### ID (Identifier)  
- **Para REFERENCIAR otros objetos**
- Se obtiene con `object::id(&objeto)`
- Para crear relaciones entre objetos

```move
// Ejemplo práctico en nuestra DAO:
public fun create_proposal(
    dao: &mut DAO,
    title: String,
    ctx: &mut TxContext
): Proposal {
    let dao_id = object::id(dao);  // ← Obtenemos ID de la DAO
    
    Proposal {
        id: object::new(ctx),       // ← Nuevo UID para la propuesta
        dao_id,                     // ← Guardamos referencia a la DAO
        title,
        votes: table::new(ctx),     // ← Tabla de votos
    }
}
```

### 🔍 **¿Por qué es genial esto?**
- Cada propuesta **sabe** a qué DAO pertenece
- Podemos verificar relaciones fácilmente
- Los objetos son **independientes** pero **conectados**

---

## 👑 3. OWNERSHIP (PROPIEDAD)

En Sui, cada objeto tiene un **dueño**. Hay 4 tipos:

### 🏠 **Owned Objects** - Pertenecen a una dirección
```move
// Un token de gobernanza pertenece a un usuario
struct GovernanceToken has key, store {
    id: UID,
    voting_power: u64,
    // owner está implícito - Sui lo maneja
}

// Se transfiere así:
public fun transfer_token(token: GovernanceToken, to: address) {
    transfer::transfer(token, to);
}
```

### 🌍 **Shared Objects** - Pertenecen a todos (pueden modificar varios)
```move
// La DAO debe ser compartida para que todos puedan votar
public fun create_dao_shared(ctx: &mut TxContext) {
    let dao = DAO {
        id: object::new(ctx),
        // ... campos
    };
    
    transfer::share_object(dao);  // ← ¡Ahora todos pueden usarla!
}
```

### 🔒 **Immutable Objects** - Nadie los puede cambiar
```move
// Configuración de la DAO que nunca cambia
public fun freeze_dao_config(config: DAOConfig) {
    transfer::freeze_object(config);  // ← Ya no se puede modificar
}
```

### 🎁 **Dynamic Objects** - Propiedad dentro de otros objetos
```move
// Los votos se pueden guardar DENTRO de la propuesta
public fun add_vote_to_proposal(
    proposal: &mut Proposal,
    vote: Vote,
) {
    // Agregar voto como objeto dinámico
    ofield::add(&mut proposal.id, voter_address, vote);
}
```

---

## 🔄 4. TRANSFERENCIAS Y WRAPPING

### Transferencia simple:
```move
// Dar un token de gobernanza a alguien
public fun give_governance_token(token: GovernanceToken, to: address) {
    transfer::transfer(token, to);
}
```

### Object Wrapping (guardar objeto dentro de otro):
```move
struct ProposalContainer has key {
    id: UID,
    proposal: Proposal,        // ← Propuesta guardada adentro
    metadata: String,
}

public fun wrap_proposal(proposal: Proposal, ctx: &mut TxContext): ProposalContainer {
    ProposalContainer {
        id: object::new(ctx),
        proposal,
        metadata: string::utf8(b"Wrapped proposal"),
    }
}
```

---

## 🏗️ 5. DYNAMIC FIELDS - CAMPOS DINÁMICOS

Para agregar datos a objetos **después** de crearlos:

```move
use sui::dynamic_object_field as ofield;

// Agregar votos a una propuesta dinámicamente
public fun cast_vote(
    proposal: &mut Proposal,
    voter: address,
    support: bool,
    voting_power: u64,
    ctx: &mut TxContext
) {
    // Crear objeto de voto
    let vote = Vote {
        id: object::new(ctx),
        support,
        voting_power,
        timestamp: 1234567890, // TODO: tiempo real
    };
    
    // Agregarlo como campo dinámico usando la dirección del votante como key
    ofield::add(&mut proposal.id, voter, vote);
}

// Verificar si alguien ya votó
public fun has_voted(proposal: &Proposal, voter: address): bool {
    ofield::exists_(&proposal.id, voter)
}

// Obtener el voto de alguien
public fun get_vote(proposal: &Proposal, voter: address): &Vote {
    ofield::borrow(&proposal.id, voter)
}
```

### 🎯 **Para nuestra DAO esto es PERFECTO porque:**
- Podemos agregar votos sin saber cuántos serán
- Cada voto está identificado por el votante
- Podemos verificar fácilmente si alguien ya votó
- Los votos están "dentro" de la propuesta pero son objetos independientes

---

## 💡 6. APLICANDO TODO A NUESTRA DAO

### Estructura completa con objetos:

```move
module dao_financing::dao {
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_object_field as ofield;
    use std::string::String;

    // === OBJETOS PRINCIPALES ===

    // DAO compartida - todos pueden interactuar
    struct DAO has key {
        id: UID,
        name: String,
        treasury: Balance<SUI>,
        proposal_count: u64,
        min_voting_power: u64,
    }

    // Propuesta individual - también compartida para que todos voten
    struct Proposal has key {
        id: UID,
        dao_id: ID,                    // ← Referencia a la DAO
        title: String,
        description: String,
        amount_requested: u64,
        proposer: address,
        deadline: u64,
        executed: bool,
        // Los votos se agregarán como dynamic fields
    }

    // Token personal de cada usuario
    struct GovernanceToken has key, store {
        id: UID,
        dao_id: ID,                    // ← Referencia a la DAO
        voting_power: u64,
    }

    // Voto individual (se guarda en dynamic fields)
    struct Vote has key, store {
        id: UID,
        support: bool,                 // true = a favor, false = en contra
        voting_power: u64,
        timestamp: u64,
    }

    // === FUNCIONES DE CREACIÓN ===

    // Crear DAO y compartirla
    public fun create_dao(
        name: String,
        min_voting_power: u64,
        ctx: &mut TxContext
    ) {
        let dao = DAO {
            id: object::new(ctx),
            name,
            treasury: balance::zero(),
            proposal_count: 0,
            min_voting_power,
        };
        
        transfer::share_object(dao);  // ← Compartida para todos
    }

    // Crear propuesta y compartirla
    public fun create_proposal(
        dao: &mut DAO,
        title: String,
        description: String,
        amount: u64,
        ctx: &mut TxContext
    ) {
        dao.proposal_count = dao.proposal_count + 1;
        
        let proposal = Proposal {
            id: object::new(ctx),
            dao_id: object::id(dao),   // ← Guardamos referencia a la DAO
            title,
            description,
            amount_requested: amount,
            proposer: tx_context::sender(ctx),
            deadline: 0, // TODO: implementar
            executed: false,
        };
        
        transfer::share_object(proposal);  // ← Compartida para votar
    }

    // Crear token de gobernanza personal
    public fun mint_governance_token(
        dao: &DAO,
        to: address,
        voting_power: u64,
        ctx: &mut TxContext
    ) {
        let token = GovernanceToken {
            id: object::new(ctx),
            dao_id: object::id(dao),   // ← Referencia a la DAO
            voting_power,
        };
        
        transfer::transfer(token, to);  // ← Personal del usuario
    }

    // === FUNCIONES DE VOTACIÓN ===

    // Votar usando dynamic fields
    public fun cast_vote(
        proposal: &mut Proposal,
        token: &GovernanceToken,
        support: bool,
        ctx: &mut TxContext
    ) {
        let voter = tx_context::sender(ctx);
        
        // Verificar que el token pertenece a la misma DAO
        assert!(token.dao_id == proposal.dao_id, 0);
        
        // Verificar que no haya votado antes
        assert!(!ofield::exists_(&proposal.id, voter), 1);
        
        // Crear voto
        let vote = Vote {
            id: object::new(ctx),
            support,
            voting_power: token.voting_power,
            timestamp: 0, // TODO: tiempo real
        };
        
        // Agregar como dynamic field
        ofield::add(&mut proposal.id, voter, vote);
    }

    // Verificar si alguien votó
    public fun has_voted(proposal: &Proposal, voter: address): bool {
        ofield::exists_(&proposal.id, voter)
    }
}
```

---

## 🤔 DUDAS Y PREGUNTAS

### ❓ Resueltas:
1. **¿Cuándo usar shared vs owned?** → Shared para objetos que muchos modifican, owned para personales
2. **¿Cómo conectar objetos?** → Con ID references y dynamic fields
3. **¿Los dynamic fields cuestan gas?** → Sí, pero es eficiente para datos variables

### ❓ Pendientes:
1. ¿Cómo contar votos de todos los dynamic fields?
2. ¿Hay límite de dynamic fields por objeto?
3. ¿Cómo manejar la eliminación de votos?

---

## ✅ RESUMEN DEL DÍA

**Lo que dominamos:**
- ✅ Sistema de objetos de Sui
- ✅ UID vs ID para identificadores y referencias
- ✅ Tipos de ownership (owned, shared, immutable, dynamic)
- ✅ Dynamic fields para datos variables
- ✅ Arquitectura completa de objetos para nuestra DAO

**Descubrimientos clave:**
- Los dynamic fields son PERFECTOS para votos variables
- Shared objects permiten interacción colaborativa
- Las referencias ID mantienen relaciones entre objetos
- El ownership es automático y seguro

**Próximos pasos:**
- [ ] Funciones de conteo y agregación de votos
- [ ] Manejo de tiempo y deadlines  
- [ ] Ejecución automática de propuestas
- [ ] Testing del sistema completo

---

## 📝 NOTAS PERSONALES

- El sistema de objetos es MUY poderoso
- Dynamic fields resuelven el problema de datos variables
- Las referencias ID son elegantes para conectar objetos
- Shared objects son clave para DAOs colaborativas

**Tiempo invertido:** 2.5 horas  
**Dificultad:** ⭐⭐⭐⚪⚪ (3/5)  
**Siguiente sesión:** Arquitectura completa de la DAO
