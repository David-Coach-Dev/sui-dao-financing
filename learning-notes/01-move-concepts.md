# 📘 Día 1: Conceptos Básicos de Move

> **Fecha:** 1 de Septiembre 2025  
> **Duración:** 2 horas  
> **Objetivo:** Entender los fundamentos del lenguaje Move aplicados a nuestra DAO

## 🎯 Lo que aprenderemos hoy

- ✅ Sintaxis básica de Move
- ✅ Tipos de datos importantes
- ✅ Sistema de habilidades (abilities)
- ✅ Funciones y módulos
- ✅ Cómo aplicar esto a nuestra DAO

---

## 🔤 1. SINTAXIS BÁSICA

### Estructura de un módulo Move
```move
module dao_financing::dao {
    // Importaciones
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    
    // Estructuras
    struct DAO has key {
        id: UID,
        treasury: u64,
    }
    
    // Funciones
    public fun create_dao(ctx: &mut TxContext): DAO {
        DAO {
            id: object::new(ctx),
            treasury: 0,
        }
    }
}
```

### 🔍 Análisis línea por línea:
- **`module dao_financing::dao`** → Nombre del módulo (paquete::módulo)
- **`use sui::object`** → Importa funcionalidades de otros módulos  
- **`struct DAO has key`** → Define una estructura con habilidad `key`
- **`public fun`** → Función que puede llamar cualquiera

---

## 📊 2. TIPOS DE DATOS

### Tipos primitivos útiles para nuestra DAO:

```move
// Números
let proposal_count: u64 = 0;           // Entero sin signo 64 bits
let vote_weight: u128 = 1000000;       // Para tokens grandes
let is_approved: bool = true;          // Boolean

// Texto
let title: vector<u8> = b"Mi Propuesta";  // String como vector de bytes
let description: String = string::utf8(b"Descripción");  // String UTF-8

// Direcciones
let proposer: address = @0x123...;     // Dirección de usuario
```

### Tipos especiales de Sui:
```move
// Identificadores únicos
let dao_id: UID = object::new(ctx);         // Para objetos únicos
let proposal_ref: ID = object::id(&proposal);  // Referencia a objeto

// Contexto de transacción
let sender = tx_context::sender(ctx);       // Quién envía la transacción
```

---

## 🦾 3. HABILIDADES (ABILITIES)

Las "abilities" definen qué se puede hacer con nuestras estructuras:

### Para nuestra DAO necesitaremos:

```move
// DAO principal - Solo key (es un objeto global único)
struct DAO has key {
    id: UID,
    treasury: Balance<SUI>,
}

// Propuesta - key + store (puede ser objeto y guardarse)
struct Proposal has key, store {
    id: UID,
    title: String,
    amount: u64,
}

// Token de gobernanza - key + store (transferible)
struct GovernanceToken has key, store {
    id: UID,
    voting_power: u64,
}

// Voto - key + drop (se puede descartar después de contar)
struct Vote has key, drop {
    id: UID,
    support: bool,
}
```

### 📋 Cheat Sheet de Abilities:
- **`key`** = Puede ser un objeto global (tener UID)
- **`store`** = Se puede guardar dentro de otros objetos  
- **`drop`** = Se puede descartar/eliminar automáticamente
- **`copy`** = Se puede copiar (raro, solo para datos simples)

---

## 🔧 4. FUNCIONES

### Tipos de funciones para nuestra DAO:

```move
// 1. FUNCIÓN PÚBLICA - Cualquiera puede llamar
public fun create_proposal(
    dao: &mut DAO,              // Referencia mutable a DAO
    title: String,              // Parámetros de entrada
    amount: u64,
    ctx: &mut TxContext         // Contexto siempre al final
): Proposal {                   // Tipo de retorno
    // Lógica aquí
    Proposal {
        id: object::new(ctx),
        title,
        amount,
    }
}

// 2. FUNCIÓN DE ENTRY - Punto de entrada para transacciones
public entry fun vote_on_proposal(
    proposal: &mut Proposal,
    token: &GovernanceToken,
    support: bool,
    ctx: &mut TxContext
) {
    // Entry functions no retornan nada
    // Modifican objetos directamente
}

// 3. FUNCIÓN INTERNA - Solo para usar dentro del módulo
fun calculate_votes(proposal: &Proposal): (u64, u64) {
    // Lógica interna
    (proposal.votes_for, proposal.votes_against)
}
```

### 🎯 Patrones importantes:
- **`&mut`** = Referencia mutable (podemos modificar)
- **`&`** = Referencia inmutable (solo leer)
- **`ctx: &mut TxContext`** = Siempre el último parámetro
- **`entry`** = Funciones que se pueden llamar desde transacciones

---

## 🏗️ 5. APLICANDO A NUESTRA DAO

### Estructura básica del módulo:

```move
module dao_financing::dao {
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};
    use std::string::String;
    
    // === ESTRUCTURAS ===
    
    struct DAO has key {
        id: UID,
        treasury: Balance<SUI>,
        proposal_count: u64,
    }
    
    struct Proposal has key {
        id: UID,
        title: String,
        description: String,
        amount_requested: u64,
        proposer: address,
        votes_for: u64,
        votes_against: u64,
        deadline: u64,
        executed: bool,
    }
    
    struct GovernanceToken has key, store {
        id: UID,
        voting_power: u64,
    }
    
    // === FUNCIONES PRINCIPALES ===
    
    // 1. Crear DAO
    public fun create_dao(ctx: &mut TxContext): DAO {
        DAO {
            id: object::new(ctx),
            treasury: balance::zero(),
            proposal_count: 0,
        }
    }
    
    // 2. Crear propuesta
    public fun create_proposal(
        dao: &mut DAO,
        title: String,
        description: String,
        amount: u64,
        ctx: &mut TxContext
    ): Proposal {
        dao.proposal_count = dao.proposal_count + 1;
        
        Proposal {
            id: object::new(ctx),
            title,
            description,
            amount_requested: amount,
            proposer: tx_context::sender(ctx),
            votes_for: 0,
            votes_against: 0,
            deadline: 0, // TODO: Implementar tiempo
            executed: false,
        }
    }
    
    // 3. Votar (básico)
    public fun cast_vote(
        proposal: &mut Proposal,
        token: &GovernanceToken,
        support: bool,
    ) {
        if (support) {
            proposal.votes_for = proposal.votes_for + token.voting_power;
        } else {
            proposal.votes_against = proposal.votes_against + token.voting_power;
        }
    }
}
```

---

## 🤔 DUDAS Y PREGUNTAS

### ❓ Resueltas:
1. **¿Por qué `&mut` vs `&`?** → `&mut` permite modificar, `&` solo leer
2. **¿Cuándo usar `key` vs `store`?** → `key` para objetos principales, `store` para que se puedan guardar en otros

### ❓ Pendientes:
1. ¿Cómo manejar el tiempo para deadlines?
2. ¿Cómo prevenir votos duplicados?
3. ¿Cómo transferir tokens de forma segura?

---

## ✅ RESUMEN DEL DÍA

**Lo que dominamos:**
- ✅ Sintaxis básica de Move
- ✅ Tipos de datos primitivos y especiales
- ✅ Sistema de abilities
- ✅ Estructura básica de funciones
- ✅ Esqueleto inicial de nuestra DAO

**Próximos pasos:**
- [ ] Entender mejor el sistema de objetos de Sui
- [ ] Aprender sobre ownership y transferencias  
- [ ] Implementar validaciones y seguridad
- [ ] Manejar tiempo y deadlines

---

## 📝 NOTAS PERSONALES

- Move se siente similar a Rust pero más simple
- El sistema de abilities es muy inteligente para controlar permisos
- Las referencias son clave para la eficiencia
- `TxContext` parece ser fundamental para todo

**Tiempo invertido:** 2 horas  
**Dificultad:** ⭐⭐⚪⚪⚪ (2/5)  
**Siguiente sesión:** Objetos en Sui
