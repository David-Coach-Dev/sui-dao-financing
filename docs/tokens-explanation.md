# 🎫 Tokens de Gobernanza - Explicación Detallada

> **Comprende cómo funcionan los tokens que otorgan poder de voto y participación en la DAO**

## 🎯 **¿Qué son los Tokens de Gobernanza?**

Los **tokens de gobernanza** son objetos NFT únicos que otorgan a sus poseedores el derecho a participar en la toma de decisiones de la DAO. Cada token tiene un `voting_power` específico que determina el peso de su voto en las propuestas.

---

## 🏗️ **Estructura del Token**

### 🎫 **GovernanceToken Struct**
```move
public struct GovernanceToken has key, store {
    id: UID,                // Identificador único del token
    dao_id: ID,             // ID de la DAO a la que pertenece
    voting_power: u64,      // Poder de voto del token
}
```

### 🔍 **Campos Explicados**

#### **🆔 Identificación**
- **`id`**: Identificador único generado automáticamente
- **`dao_id`**: Vincula el token a una DAO específica

#### **⚖️ Poder de Voto**
- **`voting_power`**: Determina el peso del voto (debe ser > 0)
- **Rango**: Cualquier valor de 1 a 18,446,744,073,709,551,615 (u64::MAX)

---

## 🏭 **Creación de Tokens**

### ⚡ **Función mint_governance_token**
```move
public fun mint_governance_token(
    dao: &mut DAO,
    recipient: address,
    voting_power: u64,
    ctx: &mut TxContext
): ID
```

### ✅ **Validaciones de Creación**
```move
// 1. Verificar que el poder de voto es válido
assert!(voting_power > 0, E_ZERO_VOTING_POWER);

// Nota: No hay validación de ownership de DAO
// Cualquiera puede mint tokens (diseño intencional para flexibilidad)
```

### 🔧 **Proceso de Mint**
```move
// 1. Crear nuevo token
let token = GovernanceToken {
    id: object::new(ctx),
    dao_id: object::id(dao),
    voting_power,
};

// 2. Incrementar contador de tokens en DAO
dao.token_count = dao.token_count + 1;

// 3. Transferir al destinatario
let token_id = object::id(&token);
transfer::public_transfer(token, recipient);

// 4. Emitir evento
event::emit(GovernanceTokenMinted {
    token_id,
    dao_id: object::id(dao),
    recipient,
    voting_power,
});
```

---

## 🎯 **Distribución de Tokens**

### 🌟 **Estrategias de Distribución**

#### **🏛️ Modelo Igualitario**
```
Todos los miembros reciben tokens con igual voting_power
Ejemplo:
- Fundador: 1000 voting_power
- Miembro A: 1000 voting_power  
- Miembro B: 1000 voting_power
- Miembro C: 1000 voting_power
Total: 4000 voting_power distribuido equitativamente
```

#### **💰 Modelo por Contribución**
```
Tokens proporcionales a la contribución
Ejemplo:
- Inversor Principal: 5000 voting_power (50%)
- Desarrollador Lead: 3000 voting_power (30%)
- Designer: 1500 voting_power (15%)
- Community Manager: 500 voting_power (5%)
Total: 10000 voting_power basado en aporte
```

#### **🏢 Modelo Jerárquico**
```
Tokens basados en roles y responsabilidades
Ejemplo:
- CEO/Fundador: 4000 voting_power
- CTO: 2500 voting_power
- Developers Senior: 1500 voting_power c/u
- Developers Junior: 800 voting_power c/u
- Contributors: 300 voting_power c/u
```

#### **⏱️ Modelo Temporal**
```
Tokens que aumentan con el tiempo y participación
Ejemplo:
- Miembros nuevos: 500 voting_power inicial
- Después de 1 mes: +200 voting_power
- Después de 6 meses: +500 voting_power
- Después de 1 año: +1000 voting_power
```

---

## 🔍 **Consultas de Tokens**

### 📊 **get_token_info**
```move
public fun get_token_info(token: &GovernanceToken): (ID, u64) {
    (token.dao_id, token.voting_power)
}
```

**Retorna**: `(dao_id, voting_power)`

### 🏛️ **get_dao_info** (incluye token count)
```move
public fun get_dao_info(dao: &DAO): (String, u64, u64, u64) {
    (dao.name, balance::value(&dao.balance), dao.proposal_count, dao.token_count)
}
```

**Retorna**: `(name, balance, proposal_count, token_count)`

---

## ⚖️ **Poder de Voto en Acción**

### 🗳️ **Uso en Votación**
```move
// El voting_power del token se suma al conteo correspondiente
if (support) {
    proposal.votes_for = proposal.votes_for + token.voting_power;
} else {
    proposal.votes_against = proposal.votes_against + token.voting_power;
}
```

### 📊 **Ejemplo de Votación**
```
Propuesta: "Financiar desarrollo de DApp"

Votantes:
- Alice (token: 2000 voting_power) → A FAVOR
- Bob (token: 1500 voting_power) → A FAVOR
- Charlie (token: 800 voting_power) → EN CONTRA
- Diana (token: 700 voting_power) → EN CONTRA

Resultado:
votes_for = 2000 + 1500 = 3500
votes_against = 800 + 700 = 1500
Decision: 3500 > 1500 → PROPUESTA APROBADA ✅
```

---

## 🛡️ **Seguridad y Validaciones**

### 🔒 **Protecciones Implementadas**

#### **🎫 Verificación de Ownership**
```move
// En cast_vote: verificar que el token pertenece a la DAO correcta
assert!(token.dao_id == proposal.dao_id, E_WRONG_DAO_TOKEN);
```

#### **⚡ Verificación de Poder**
```move
// No permitir votos con tokens sin poder
assert!(token.voting_power > 0, E_ZERO_VOTING_POWER);
```

#### **🚫 Prevención de Doble Voto**
```move
// Un token solo puede votar una vez por propuesta
let voter = tx_context::sender(ctx);
assert!(!df::exists_<address>(&proposal.id, voter), E_ALREADY_VOTED);
```

### 🔐 **Modelo de Seguridad**

#### **✅ Protecciones Actuales**
- Token debe pertenecer a la DAO correcta
- Token debe tener voting_power > 0
- Un address solo puede votar una vez por propuesta
- Estados de propuesta validados

#### **⚠️ Consideraciones de Diseño**
```
🎯 Minting Abierto: Cualquiera puede crear tokens
   Pros: Flexibilidad máxima para diferentes modelos de DAO
   Cons: Requiere gestión externa de distribución

🔄 Transferibilidad: Tokens pueden transferirse libremente
   Pros: Permite mercados secundarios y delegación
   Cons: Riesgo de concentración de poder

🎫 Un Token = Un Voto: Cada address puede votar una vez por propuesta
   Pros: Previene spam de votos
   Cons: Usuarios con múltiples tokens votan con el último usado
```

---

## 📊 **Distribución y Gestión**

### 🎯 **Estrategias de Mint Inicial**

#### **🏗️ Fundación de DAO**
```bash
# 1. Crear DAO
sui client call --function create_dao --args "Tech DAO" 5000000000

# 2. Mint token para fundador (poder alto)
sui client call --function mint_governance_token \
  --args $DAO_ID $FOUNDER_ADDRESS 5000

# 3. Mint tokens para miembros fundadores
sui client call --function mint_governance_token \
  --args $DAO_ID $MEMBER1_ADDRESS 2000

sui client call --function mint_governance_token \
  --args $DAO_ID $MEMBER2_ADDRESS 2000

# 4. Mint tokens para comunidad (poder menor)
sui client call --function mint_governance_token \
  --args $DAO_ID $COMMUNITY1_ADDRESS 500
```

#### **🌱 Expansión Gradual**
```bash
# Añadir nuevos miembros gradualmente
add_new_member() {
    local address=$1
    local power=$2
    
    sui client call --function mint_governance_token \
      --args $DAO_ID $address $power
    
    echo "✅ Token creado para $address con $power voting_power"
}

# Ejemplos de uso
add_new_member "0xnew_developer123...abc" 1200
add_new_member "0xnew_designer456...def" 800
add_new_member "0xnew_community789...ghi" 400
```

---

## 📈 **Métricas de Tokens**

### 📊 **Distribución de Poder**
```bash
# Script para analizar distribución de poder
analyze_voting_power() {
    echo "📊 ANÁLISIS DE DISTRIBUCIÓN DE VOTING POWER"
    echo "=========================================="
    
    # Total de tokens (obtener de DAO)
    local total_tokens=$(sui client call --function get_dao_info --args $DAO_ID | grep token_count)
    echo "Total de tokens: $total_tokens"
    
    # Poder total distribuido (sumar todos los voting_power)
    # Esto requeriría iterar sobre todos los tokens
    
    echo "Distribución por rangos:"
    echo "- Mega holders (>5000): X tokens"
    echo "- Large holders (1000-5000): Y tokens"  
    echo "- Medium holders (500-1000): Z tokens"
    echo "- Small holders (<500): W tokens"
}
```

### 🎯 **Concentración de Poder**
```
Coeficiente de Gini = Medida de desigualdad en distribución
0 = Distribución perfectamente igualitaria
1 = Todo el poder concentrado en una persona

Índice Herfindahl = Suma de cuadrados de proporciones
Bajo = Poder distribuido
Alto = Poder concentrado
```

### 📊 **Participación**
```
Tasa de participación = Tokens que votan / Total de tokens
Poder activo = Voting power usado / Total voting power
Frecuencia de voto = Promedio de propuestas votadas por token
```

---

## 🚨 **Códigos de Error**

### ❌ **Errores Relacionados con Tokens**
```move
const E_WRONG_DAO_TOKEN: u64 = 2;         // Token no pertenece a la DAO
const E_ZERO_VOTING_POWER: u64 = 7;       // Token sin poder de voto
const E_ALREADY_VOTED: u64 = 1;           // Address ya votó en esta propuesta
```

### 🔧 **Soluciones Comunes**

#### **E_WRONG_DAO_TOKEN**
```bash
# Verificar que el token pertenece a la DAO correcta
sui client call --function get_token_info --args $TOKEN_ID
# El dao_id debe coincidir con el dao_id de la propuesta

sui client call --function get_proposal_info --args $PROPOSAL_ID
# Comparar los dao_id de ambos objetos
```

#### **E_ZERO_VOTING_POWER**
```bash
# Verificar el poder de voto del token
sui client call --function get_token_info --args $TOKEN_ID
# El voting_power debe ser > 0

# Si es 0, necesitas un token diferente con poder de voto válido
```

#### **E_ALREADY_VOTED**
```bash
# Verificar si ya votaste
sui client call --function has_voted --args $PROPOSAL_ID $(sui client active-address)
# Si retorna true, ya votaste con algún token desde esta address

# Solución: Cada address puede votar solo una vez por propuesta
```

---

## 📡 **Eventos de Tokens**

### 🎫 **GovernanceTokenMinted**
```move
public struct GovernanceTokenMinted has copy, drop {
    token_id: ID,           // ID del token creado
    dao_id: ID,             // ID de la DAO
    recipient: address,     // Quien recibió el token
    voting_power: u64,      // Poder de voto asignado
}
```

### 📊 **Utilidad del Evento**
```
🔍 Auditoría: Rastrear distribución de tokens
📈 Analytics: Analizar patrones de distribución
🎯 Governance: Verificar equidad en distribución
📱 UIs: Actualizar listas de token holders
🤖 Bots: Automatizar respuestas a nuevos miembros
```

---

## 🔮 **Evolución de Tokens**

### 🚀 **V1.1 - Mejoras Planificadas**
```
⏰ Time-based power: Voting power que aumenta con tiempo
🏆 Reputation system: Poder basado en participación histórica
🔄 Delegación: Permitir delegar voting power a otros
📊 Categorías: Tokens especializados por área (dev, marketing, etc.)
```

### 🌟 **V2.0 - Características Avanzadas**
```
🎨 NFT Governance: Tokens con metadata visual
💰 Staking rewards: Recompensas por participar en votaciones
🔥 Burn mechanisms: Reducir supply por inactividad
⚡ Dynamic power: Poder que cambia según condiciones del mercado
```

### 🏗️ **V3.0 - Integración DeFi**
```
🌊 Liquidity pools: Pools de liquidez para tokens de gobernanza
📈 Yield farming: Farming con tokens de diferentes DAOs
🔀 Cross-DAO voting: Usar tokens de una DAO en otra
🌐 Interoperabilidad: Tokens que funcionan cross-chain
```

---

## 🎓 **Casos de Estudio**

### 🏛️ **DAO Tecnológica**
```
Distribución:
- CTO: 3000 voting_power (líder técnico)
- Senior Devs: 1500 c/u (expertise técnico)
- Junior Devs: 800 c/u (contribución creciente)
- Community: 300 c/u (participación básica)

Resultado: Decisiones técnicas bien informadas
```

### 💰 **DAO de Inversión**
```
Distribución:
- Inversores principales: Poder proporcional a inversión
- Gestores de fondos: Poder fijo alto
- Asesores: Poder moderado
- Comunidad: Poder mínimo

Resultado: Decisiones de inversión profesionales
```

### 🌍 **DAO Comunitaria**
```
Distribución:
- Todos los miembros: 1000 voting_power igual
- Moderadores: +500 voting_power adicional
- Fundadores: +1000 voting_power adicional

Resultado: Máxima democracia y participación
```

---

## 🎯 **Mejores Prácticas**

### ✅ **Para Administradores de DAO**
```
📊 Planificar distribución: Diseñar modelo antes de empezar
⚖️ Balancear poder: Evitar concentración excesiva
📈 Monitorear participación: Ajustar poder según actividad
🔄 Revisar regularmente: Rebalancear según crecimiento
```

### ✅ **Para Poseedores de Tokens**
```
🗳️ Votar responsablemente: Considerar impacto de decisiones
🤝 Participar activamente: No solo votar, también proponer
📚 Mantenerse informado: Entender propuestas antes de votar
💎 Valorar el token: Entender que representa participación real
```

### ✅ **Para Desarrolladores**
```
🔐 Validar ownership: Verificar que tokens pertenecen a DAO correcta
⚡ Optimizar gas: Minimizar operaciones costosas
📊 Implementar métricas: Rastrear distribución y uso
🧪 Testing exhaustivo: Probar edge cases de voting power
```

---

## 📚 **Recursos Relacionados**

- **🏛️ DAO Principal**: [`dao-explanation.md`](dao-explanation.md)
- **📝 Propuestas**: [`proposal-explanation.md`](proposal-explanation.md)
- **🗳️ Votación**: [`voting-explanation.md`](voting-explanation.md)
- **⚡ Ejecución**: [`execution-explanation.md`](execution-explanation.md)
- **🧪 Tests**: [`tests-explanation.md`](tests-explanation.md)

---

**🎫 Los tokens de gobernanza son la materialización digital del derecho a participar en la democracia descentralizada. Cada token representa una voz en el futuro colectivo de la organización.**
