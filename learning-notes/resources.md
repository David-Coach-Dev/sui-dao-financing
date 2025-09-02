# 📚 Recursos y Referencias

> **Compilación completa de recursos útiles para desarrollo en Move y Sui**

## 📖 **Documentación Oficial**

### 🌟 **Imprescindibles**
- [**Sui Documentation**](https://docs.sui.io/) - Documentación oficial completa
- [**Move Book**](https://move-book.com/) - Tutorial completo del lenguaje Move
- [**Sui by Example**](https://examples.sui.io/) - Ejemplos prácticos paso a paso
- [**Move Reference**](https://move-language.github.io/) - Referencia oficial del lenguaje

### 🔧 **Herramientas de Desarrollo**
- [**Sui CLI**](https://docs.sui.io/references/cli) - Herramienta de línea de comandos
- [**Move Analyzer**](https://marketplace.visualstudio.com/items?itemName=move.move-analyzer) - Extensión VSCode
- [**Sui Explorer**](https://suiexplorer.com/) - Explorador de blockchain
- [**Move Registry**](https://www.moveregistry.com/) - Registro de paquetes Move

---

## 🎓 **Tutoriales y Cursos**

### 📚 **Fundamentos**
- [**Sui Developer Portal**](https://sui.io/developers) - Portal oficial de desarrolladores
- [**Move Tutorial by Sui**](https://docs.sui.io/guides/developer/first-app) - Primera app en Sui
- [**Smart Contract Programming in Move**](https://github.com/move-language/move/tree/main/language/documentation/tutorial) - Tutorial oficial

### 🎯 **Específicos para DAOs**
- [**Building DAOs on Sui**](https://blog.sui.io/decentralization-autonomous-organizations-explained/) - Artículo oficial
- [**Governance Patterns in Move**](https://github.com/MystenLabs/sui/tree/main/sui_programmability/examples) - Ejemplos de gobernanza
- [**Vote Aggregation Patterns**](https://move-book.com/advanced-topics/vote-token.html) - Patrones de votación

---

## 💻 **Códigos de Ejemplo**

### 🏛️ **DAOs y Gobernanza**
```move
// Ejemplo básico de DAO encontrado en:
// https://github.com/MystenLabs/sui/blob/main/sui_programmability/examples/governance
module governance::dao {
    struct DAO has key {
        id: UID,
        proposals: vector<ID>,
    }
}
```

### 🗳️ **Sistemas de Votación**
- [**Sui Governance Example**](https://github.com/MystenLabs/sui/tree/main/sui_programmability/examples/governance)
- [**Vote Token Pattern**](https://examples.sui.io/samples/coin.html)
- [**Multi-sig Wallet**](https://github.com/MystenLabs/sui/tree/main/sui_programmability/examples/utils)

### 💰 **Manejo de Tokens**
- [**Coin Standard**](https://examples.sui.io/samples/coin.html)  
- [**Treasury Management**](https://docs.sui.io/guides/developer/sui-101/create-coin)
- [**Balance Operations**](https://docs.sui.io/references/framework/coin)

---

## 🛠️ **Herramientas de Desarrollo**

### 🔧 **Setup y Configuración**
```bash
# Instalar Sui CLI
curl -fLsS https://sui.io/install.sh | sh

# Crear nuevo proyecto
sui move new my_project

# Compilar proyecto
sui move build

# Ejecutar tests
sui move test
```

### 📝 **Templates Útiles**
- **Move.toml básico:**
```toml
[package]
name = "mi_proyecto"
version = "1.0.0"
edition = "2024.beta"

[dependencies]
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/mainnet" }

[addresses]
mi_proyecto = "0x0"
```

### 🧪 **Testing Framework**
```move
#[test_only]
use sui::test_scenario;

#[test]
fun test_example() {
    let scenario_val = test_scenario::begin(@0x1);
    let scenario = &mut scenario_val;
    // Test logic...
    test_scenario::end(scenario_val);
}
```

---

## 🌐 **Comunidad y Soporte**

### 💬 **Discord Servers**
- [**Sui Official Discord**](https://discord.com/invite/sui) - Comunidad oficial
- [**Sui Latam Devs**](https://discord.com/invite/QpdfBHgD6m) - Comunidad Latina
- [**Zona Tres**](https://discord.com/invite/aUUCHa96Ja) - Programa Sui Developer
- [**Move Language Discord**](https://discord.com/invite/cPUmhe24mf) - Comunidad Move

### 🐦 **Social Media**
- [**@SuiNetwork**](https://twitter.com/SuiNetwork) - Twitter oficial
- [**@Move_Language**](https://twitter.com/Move_Language) - Move updates
- [**Sui Blog**](https://blog.sui.io/) - Artículos técnicos

### 📺 **YouTube Channels**
- [**Sui Network**](https://www.youtube.com/@SuiNetwork) - Canal oficial
- [**Move Language Tutorials**](https://www.youtube.com/results?search_query=move+language+tutorial)

---

## 🔍 **Referencias Técnicas**

### 📋 **Cheat Sheets**

#### **Tipos de Datos Básicos:**
```move
u8, u16, u32, u64, u128, u256  // Enteros sin signo
bool                           // Boolean
address                        // Dirección de cuenta
vector<T>                      // Vector de tipo T
```

#### **Abilities Importantes:**
```move
copy    // Se puede copiar
drop    // Se puede descartar
store   // Se puede guardar en storage
key     // Puede ser objeto global (tener UID)
```

#### **Imports Comunes:**
```move
use sui::object::{Self, UID, ID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
use sui::coin::{Self, Coin};
use sui::balance::{Self, Balance};
use std::string::{Self, String};
```

### 🎯 **Patrones Comunes**

#### **Crear Objeto:**
```move
public fun create_object(ctx: &mut TxContext): MyObject {
    MyObject {
        id: object::new(ctx),
        // ... otros campos
    }
}
```

#### **Transferir Objeto:**
```move
transfer::transfer(object, recipient);          // Owned
transfer::share_object(object);                 // Shared  
transfer::freeze_object(object);                // Immutable
transfer::public_transfer(coin, recipient);     // Public
```

#### **Dynamic Fields:**
```move
use sui::dynamic_object_field as ofield;

// Agregar
ofield::add(&mut object.id, key, value);

// Verificar existencia
ofield::exists_(&object.id, key);

// Acceder
ofield::borrow(&object.id, key);
ofield::borrow_mut(&mut object.id, key);

// Eliminar
ofield::remove(&mut object.id, key);
```

---

## 🐛 **Problemas Comunes y Soluciones**

### ⚠️ **Errores Comunes**

#### **1. Import Errors**
```move
// ❌ Incorrecto
use sui::dynamic_field as ofield;

// ✅ Correcto para objetos
use sui::dynamic_object_field as ofield;
```

#### **2. Transfer Functions**
```move
// ❌ Error común
transfer::transfer(coin, recipient);

// ✅ Correcto para Coins
transfer::public_transfer(coin, recipient);
```

#### **3. String Creation**
```move
// ❌ No existe
let s = String::new("text");

// ✅ Correcto
let s = string::utf8(b"text");
```

#### **4. Balance vs Coin**
```move
// ❌ Confundir tipos
let amount: u64 = coin;

// ✅ Correcto
let amount: u64 = coin::value(&coin);
let balance = coin::into_balance(coin);
```

### 🔧 **Debugging Tips**

#### **Compilación:**
```bash
# Compilar con detalles
sui move build --verbose

# Solo verificar sintaxis
sui move build --check

# Compilar con dependencias actualizadas
sui move build --fetch-deps
```

#### **Testing:**
```bash
# Ejecutar tests específicos
sui move test test_name

# Tests con output detallado
sui move test --verbose

# Tests con gas tracking
sui move test --gas-limit 1000000
```

---

## 🎯 **Recursos Específicos para Nuestro Proyecto**

### 📚 **DAO Patterns**
- [**Multi-signature Pattern**](https://github.com/MystenLabs/sui/blob/main/sui_programmability/examples/utils/sources/multisig.move)
- [**Vote Aggregation**](https://examples.sui.io/samples/governance.html)
- [**Treasury Management**](https://docs.sui.io/guides/developer/coin)

### 🗳️ **Voting Systems**
- [**Weighted Voting**](https://move-book.com/advanced-topics/vote-token.html)
- [**Quadratic Voting**](https://github.com/MystenLabs/sui/discussions/3856)
- [**Time-based Proposals**](https://docs.sui.io/guides/developer/sui-101/using-events)

### 💰 **Treasury Patterns**
```move
// Pattern para manejo seguro de tesorería
public fun withdraw_from_treasury(
    dao: &mut DAO,
    amount: u64,
    recipient: address,
    admin_cap: &AdminCap,
    ctx: &mut TxContext
) {
    assert!(balance::value(&dao.treasury) >= amount, E_INSUFFICIENT_FUNDS);
    let coin = coin::from_balance(
        balance::split(&mut dao.treasury, amount), 
        ctx
    );
    transfer::public_transfer(coin, recipient);
}
```

---

## 📈 **Optimización y Gas**

### ⛽ **Gas Optimization Tips**

#### **1. Evitar Iteraciones Costosas:**
```move
// ❌ Costoso - iterar dynamic fields
fun count_votes_expensive(proposal: &Proposal): u64 {
    // Iteración sobre todos los dynamic fields
}

// ✅ Eficiente - contadores incrementales
struct Proposal {
    votes_for: u64,     // Contador directo
    votes_against: u64, // Más eficiente
}
```

#### **2. Batch Operations:**
```move
// ❌ Múltiples transacciones
public fun mint_multiple_tokens(...) {
    mint_token(addr1, power);
    mint_token(addr2, power);  
    // Cada una cuesta gas separadamente
}

// ✅ Una sola transacción
public fun mint_batch_tokens(
    addresses: vector<address>,
    powers: vector<u64>
) {
    // Procesar todo en una TX
}
```

#### **3. Shared Object Usage:**
```move
// ⚠️ Cuidado con shared objects
// Cada modificación requiere consenso global
// Usar solo cuando realmente necesario

// ✅ Mejor: owned objects cuando sea posible
```

### 📊 **Gas Cost References**
- **Crear objeto:** ~1,000 gas units
- **Transfer owned:** ~100 gas units  
- **Modificar shared:** ~500 gas units
- **Dynamic field add:** ~200 gas units
- **Function call:** ~50-200 gas units

---

## 🔐 **Seguridad y Mejores Prácticas**

### 🛡️ **Security Checklist**

#### **Validaciones Críticas:**
```move
// ✅ Siempre verificar ownership
assert!(token.dao_id == proposal.dao_id, E_WRONG_DAO);

// ✅ Prevenir double-spending
assert!(!already_used, E_ALREADY_USED);

// ✅ Verificar balances suficientes
assert!(balance::value(&treasury) >= amount, E_INSUFFICIENT);

// ✅ Validar rangos numéricos
assert!(power > 0 && power <= MAX_POWER, E_INVALID_POWER);
```

#### **Patterns Seguros:**
```move
// ✅ Capability-based access control
struct AdminCap has key, store { id: UID }

// ✅ Immutable configuration
public fun freeze_config(config: DAOConfig) {
    transfer::freeze_object(config);
}

// ✅ Event logging para transparency
public fun sensitive_operation(...) {
    // ... lógica ...
    event::emit(SensitiveOperationPerformed { ... });
}
```

### 🔍 **Audit Checklist**
- [ ] Validaciones en todas las funciones públicas
- [ ] Prevención de overflow/underflow
- [ ] Access control apropiado
- [ ] Event logging para operaciones críticas
- [ ] Tests para todos los edge cases
- [ ] Gas optimization review

---

## 📱 **Herramientas de Terceros**

### 🔧 **Development Tools**
- [**Sui TypeScript SDK**](https://github.com/MystenLabs/sui/tree/main/sdk/typescript) - Para frontends
- [**Sui Rust SDK**](https://github.com/MystenLabs/sui/tree/main/crates/sui-sdk) - Para servicios backend
- [**Move Prover**](https://github.com/move-language/move/tree/main/language/move-prover) - Verificación formal

### 📊 **Analytics y Monitoring**
- [**Sui Vision**](https://suivision.xyz/) - Analytics de red
- [**MoveBit Scanner**](https://movetool.xyz/) - Análisis de contratos
- [**Sui Stats**](https://suistats.xyz/) - Estadísticas de red

### 💼 **Wallets para Testing**
- [**Sui Wallet**](https://chrome.google.com/webstore/detail/sui-wallet/opcgpfmipidbgpenhmajoajpbobppdil) - Wallet oficial
- [**Ethos Wallet**](https://ethoswallet.xyz/) - Alternativa popular
- [**Suiet**](https://suiet.app/) - Wallet para desarrollo

---

## 📝 **Templates de Documentación**

### 📋 **README Template**
```markdown
# Proyecto DAO Sui

## Descripción
[Descripción del proyecto]

## Instalación
```bash
sui move build
sui move test
```

## Uso
```bash
sui client call --package $PACKAGE --module dao --function create_dao
```

## Funciones Principales
- `create_dao()` - Crear nueva DAO
- `create_proposal()` - Crear propuesta
- `cast_vote()` - Votar en propuesta

## Testing
```bash
sui move test
```
```

### 📄 **Function Documentation Template**
```move
/// Crea una nueva propuesta en la DAO
/// 
/// # Argumentos
/// * `dao` - Referencia mutable a la DAO
/// * `title` - Título de la propuesta
/// * `amount` - Cantidad solicitada en SUI
/// * `ctx` - Contexto de transacción
/// 
/// # Errores
/// * `E_DAO_NOT_ACTIVE` - Si la DAO está pausada
/// * `E_INVALID_AMOUNT` - Si el monto es inválido
/// 
/// # Eventos
/// Emite `ProposalCreated` con detalles de la propuesta
public fun create_proposal(
    dao: &mut DAO,
    title: String,
    amount: u64,
    ctx: &mut TxContext
) {
    // Implementation...
}
```

---

## 🎓 **Para Seguir Aprendiendo**

### 📚 **Próximos Temas**
1. **Move Advanced Patterns**
   - Capability-based security
   - Witness pattern
   - Hot potato pattern

2. **Sui Advanced Features**
   - Sponsored transactions
   - Programmable transaction blocks
   - Dynamic fields advanced usage

3. **DeFi Patterns**
   - AMM implementation
   - Lending protocols
   - Yield farming

### 🚀 **Proyectos Siguientes**
1. **NFT Marketplace** con royalties
2. **DEX simple** con pools de liquidez
3. **Lending Protocol** básico
4. **Gaming items** con progression

---

## 🤝 **Contribuir a la Comunidad**

### 📝 **Formas de Contribuir**
- Escribir tutoriales en español
- Traducir documentación oficial
- Crear ejemplos de código
- Responder preguntas en Discord
- Reportar bugs en GitHub

### 🌟 **Recursos para Contribuidores**
- [**Sui Contributing Guide**](https://github.com/MystenLabs/sui/blob/main/CONTRIBUTING.md)
- [**Move Language Contributing**](https://github.com/move-language/move/blob/main/CONTRIBUTING.md)
- [**Community Guidelines**](https://sui.io/community)

---

**📝 Mantenido por:** [Tu nombre]  
**📅 Última actualización:** Septiembre 2024  
**🔄 Frecuencia de actualización:** Semanal durante el programa  

> 💡 **Tip:** Marca esta página para referencia rápida durante el desarrollo