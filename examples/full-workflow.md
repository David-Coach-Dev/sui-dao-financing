# 🔄 Flujo Completo de DAO - De la Creación a la Ejecución

> **Guía integral que conecta todos los procesos: crear DAO, propuestas, votación y ejecución**

## 🎯 **¿Qué vamos a hacer?**

Este tutorial muestra el **flujo completo end-to-end** de una DAO en acción:

1. 🏗️ **Crear la DAO** y emitir tokens de gobernanza
2. 💰 **Depositar fondos** en la tesorería
3. 📝 **Crear una propuesta** de financiamiento
4. 🗳️ **Votar en la propuesta** con múltiples miembros
5. ⚡ **Ejecutar la propuesta** y transferir fondos
6. 🔍 **Verificar el ciclo completo**

**⏱️ Tiempo estimado:** 30-45 minutos  
**💰 Costo aproximado:** ~0.1 SUI en gas fees  
**👥 Participantes:** 3+ direcciones (fundador + miembros)

---

## 🚀 **Fase 1: Configuración Inicial**

### **📋 Prerequisitos**
```bash
# Verificar conexión a Sui
sui client active-env
sui client gas

# Configurar package ID (reemplaza con tu deployment)
export PACKAGE_ID="0x..."  # Tu package ID después del deployment

# Preparar direcciones de ejemplo (obten estas de tus wallets reales)
export FOUNDER_ADDRESS=$(sui client active-address)
export MEMBER1_ADDRESS="0x..."  # Segunda dirección/wallet
export MEMBER2_ADDRESS="0x..."  # Tercera dirección/wallet

echo "=== CONFIGURACIÓN ==="
echo "Package: $PACKAGE_ID"
echo "Fundador: $FOUNDER_ADDRESS"
echo "Miembro 1: $MEMBER1_ADDRESS"
echo "Miembro 2: $MEMBER2_ADDRESS"
```

---

## 🏗️ **Fase 2: Crear la DAO** 

### **🎯 Paso 1: Crear DAO con Tokens Distribuidos**
```bash
echo "🏗️ CREANDO DAO CON DISTRIBUCIÓN DE TOKENS..."

# Crear la DAO con 5 SUI de balance inicial
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "Community Finance DAO" 5000000000 \
  --gas-budget 10000000

# Capturar los IDs de la transacción anterior
export DAO_ID="0x..."  # ID de la DAO creada
export FOUNDER_TOKEN_ID="0x..."  # Token del fundador
```

### **🎁 Paso 2: Distribuir Tokens a Miembros**
```bash
echo "🎁 DISTRIBUYENDO TOKENS DE GOBERNANZA..."

# Crear token para miembro 1 (poder de voto: 800)
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function mint_governance_token \
  --args $DAO_ID $MEMBER1_ADDRESS 800 \
  --gas-budget 10000000

export MEMBER1_TOKEN_ID="0x..."  # Token del miembro 1

# Crear token para miembro 2 (poder de voto: 500)  
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function mint_governance_token \
  --args $DAO_ID $MEMBER2_ADDRESS 500 \
  --gas-budget 10000000

export MEMBER2_TOKEN_ID="0x..."  # Token del miembro 2
```

### **📊 Paso 3: Verificar Estado Inicial**
```bash
echo "📊 VERIFICANDO ESTADO INICIAL DE LA DAO..."

echo "1. Información de la DAO:"
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_dao_info \
  --args $DAO_ID

echo "2. Tokens distribuidos:"
echo "   Fundador ($FOUNDER_ADDRESS): 1000 votos"
echo "   Miembro 1 ($MEMBER1_ADDRESS): 800 votos"  
echo "   Miembro 2 ($MEMBER2_ADDRESS): 500 votos"
echo "   TOTAL: 2300 votos distribuidos"
```

---

## 📝 **Fase 3: Crear Propuesta de Financiamiento**

### **🎯 Paso 4: Propuesta para Proyecto de Desarrollo**
```bash
echo "📝 CREANDO PROPUESTA DE FINANCIAMIENTO..."

# El fundador propone financiar un proyecto de desarrollo con 2 SUI
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function submit_proposal \
  --args $DAO_ID "Desarrollo de DApp de NFTs" 2000000000 $MEMBER1_ADDRESS $FOUNDER_TOKEN_ID \
  --gas-budget 10000000

export PROPOSAL_ID="0x..."  # ID de la propuesta creada
```

### **📋 Paso 5: Verificar Detalles de la Propuesta**
```bash
echo "📋 DETALLES DE LA PROPUESTA CREADA:"

echo "1. Información básica:"
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_proposal_info \
  --args $PROPOSAL_ID

echo "2. Estado de votos inicial:"
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_proposal_votes \
  --args $PROPOSAL_ID

echo "3. ¿Puede ejecutarse ahora?"
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function can_execute \
  --args $PROPOSAL_ID
```

---

## 🗳️ **Fase 4: Proceso de Votación Comunitaria**

### **✅ Paso 6: Fundador Vota A Favor (1000 votos)**
```bash
echo "✅ FUNDADOR VOTA A FAVOR..."

sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function cast_vote \
  --args $PROPOSAL_ID $FOUNDER_TOKEN_ID true \
  --gas-budget 10000000

echo "Votos después del fundador:"
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_proposal_votes \
  --args $PROPOSAL_ID
```

### **✅ Paso 7: Miembro 1 Vota A Favor (800 votos)**
```bash
echo "✅ MIEMBRO 1 VOTA A FAVOR..."

# Cambiar a la dirección del miembro 1 para votar
# (En práctica, el miembro 1 ejecutaría esto desde su wallet)
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function cast_vote \
  --args $PROPOSAL_ID $MEMBER1_TOKEN_ID true \
  --gas-budget 10000000

echo "Votos después del miembro 1:"
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_proposal_votes \
  --args $PROPOSAL_ID
```

### **❌ Paso 8: Miembro 2 Vota En Contra (500 votos)**
```bash
echo "❌ MIEMBRO 2 VOTA EN CONTRA..."

# El miembro 2 no está de acuerdo con la propuesta
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function cast_vote \
  --args $PROPOSAL_ID $MEMBER2_TOKEN_ID false \
  --gas-budget 10000000

echo "Votos finales después de todos los miembros:"
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_proposal_votes \
  --args $PROPOSAL_ID
```

### **📊 Paso 9: Analizar Resultado de Votación**
```bash
echo "📊 ANÁLISIS DE VOTACIÓN:"
echo "======================="

# Calcular totales
echo "✅ Votos A FAVOR: 1000 + 800 = 1800 votos"
echo "❌ Votos EN CONTRA: 500 votos"
echo "📈 RESULTADO: 1800 > 500 → PROPUESTA APROBADA"

echo "¿Puede ejecutarse?"
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function can_execute \
  --args $PROPOSAL_ID
```

---

## ⚡ **Fase 5: Ejecución de la Propuesta**

### **🚀 Paso 10: Ejecutar Propuesta Aprobada**
```bash
echo "⚡ EJECUTANDO PROPUESTA APROBADA..."

# Cualquier persona puede ejecutar una propuesta aprobada
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function execute_proposal \
  --args $DAO_ID $PROPOSAL_ID \
  --gas-budget 10000000

echo "🎉 ¡PROPUESTA EJECUTADA EXITOSAMENTE!"
```

### **📊 Paso 11: Verificar Ejecución Completa**
```bash
echo "📊 VERIFICANDO EJECUCIÓN..."

echo "1. Estado final de la propuesta:"
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_proposal_info \
  --args $PROPOSAL_ID
echo "   → executed: true ✓"
echo "   → status: 3 (EXECUTED) ✓"

echo "2. Balance actualizado de la DAO:"
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_dao_info \
  --args $DAO_ID
echo "   → balance: 3 SUI (5 - 2 transferidos) ✓"

echo "3. Verificar que no se puede ejecutar de nuevo:"
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function can_execute \
  --args $PROPOSAL_ID
echo "   → can_execute: false ✓"
```

---

## 🔍 **Fase 6: Auditoría y Verificación**

### **📋 Paso 12: Resumen Completo del Ciclo**
```bash
echo "=================================="
echo "🔍 AUDITORÍA DEL CICLO COMPLETO"
echo "=================================="

echo "🏗️ CREACIÓN:"
echo "   ✅ DAO creada con 5 SUI"
echo "   ✅ 3 tokens distribuidos (total: 2300 votos)"

echo "📝 PROPUESTA:"
echo "   ✅ Solicitó 2 SUI para desarrollo"
echo "   ✅ Destinatario: $MEMBER1_ADDRESS"

echo "🗳️ VOTACIÓN:"
echo "   ✅ Fundador: A FAVOR (1000 votos)"
echo "   ✅ Miembro 1: A FAVOR (800 votos)"
echo "   ✅ Miembro 2: EN CONTRA (500 votos)"
echo "   📊 Resultado: 1800 vs 500 = APROBADA"

echo "⚡ EJECUCIÓN:"
echo "   ✅ Propuesta ejecutada"
echo "   ✅ 2 SUI transferidos al destinatario"
echo "   ✅ Balance DAO: 5 → 3 SUI"

echo "🎯 ESTADO FINAL:"
echo "   ✅ Proceso democrático completado"
echo "   ✅ Fondos distribuidos según decisión"
echo "   ✅ Transparencia total mantenida"
echo "=================================="
```

---

## 📊 **Escenarios Alternativos**

### **🔄 Escenario A: Propuesta Rechazada**
```bash
echo "🔄 ¿QUÉ PASA SI LA PROPUESTA ES RECHAZADA?"
echo "=========================================="
echo "Si los votos EN CONTRA > votos A FAVOR:"
echo "   ❌ can_execute() retorna false"
echo "   ❌ execute_proposal() falla"
echo "   ⏳ Propuesta permanece activa"
echo "   🔄 Más miembros pueden seguir votando"
echo "   💡 Nueva propuesta puede crearse"
```

### **💰 Escenario B: Fondos Insuficientes**
```bash
echo "💰 ¿QUÉ PASA SI NO HAY FONDOS SUFICIENTES?"
echo "=========================================="
echo "Si el balance DAO < cantidad solicitada:"
echo "   ✅ can_execute() puede retornar true"
echo "   ❌ execute_proposal() falla por fondos"
echo "   💡 Necesario depositar más fondos"
echo "   🔄 Ejecutar cuando haya suficiente balance"
```

### **🏃‍♂️ Escenario C: Múltiples Propuestas**
```bash
echo "🏃‍♂️ ¿QUÉ PASA CON MÚLTIPLES PROPUESTAS?"
echo "=========================================="
echo "Propuestas simultáneas:"
echo "   ✅ Cada propuesta vota independientemente"
echo "   ⚡ Se ejecutan en orden de aprobación"
echo "   💰 Balance se descuenta secuencialmente"
echo "   🎯 Última propuesta puede fallar por fondos"
```

---

## 🎮 **Ejercicios Prácticos**

### **🎯 Ejercicio 1: Segunda Propuesta**
```bash
echo "🎯 EJERCICIO: Crear segunda propuesta"
echo "===================================="
echo "1. Crear propuesta para 1 SUI adicional"
echo "2. Votar con distribución diferente"
echo "3. Comparar resultados"
echo ""
echo "Comando base:"
echo "sui client call --package $PACKAGE_ID --module dao --function submit_proposal --args $DAO_ID \"Segunda propuesta\" 1000000000 [RECIPIENT] [TOKEN_ID]"
```

### **🎯 Ejercicio 2: Nuevos Miembros**
```bash
echo "🎯 EJERCICIO: Expandir la DAO"
echo "============================="
echo "1. Mint nuevos tokens para más miembros"
echo "2. Crear propuesta con más votantes"
echo "3. Analizar dinámicas de poder"
echo ""
echo "Comando base:"
echo "sui client call --package $PACKAGE_ID --module dao --function mint_governance_token --args $DAO_ID [NEW_ADDRESS] [VOTING_POWER]"
```

### **🎯 Ejercicio 3: Depositar Fondos**
```bash
echo "🎯 EJERCICIO: Recargar tesorería"
echo "==============================="
echo "1. Depositar más SUI en la DAO"
echo "2. Crear propuestas por mayor cantidad"
echo "3. Gestionar tesorería comunitaria"
echo ""
echo "Comando base:"
echo "sui client call --package $PACKAGE_ID --module dao --function deposit --args $DAO_ID [COIN_OBJECT] [AMOUNT]"
```

---

## 🔧 **Comandos de Diagnóstico**

### **🩺 Health Check Completo**
```bash
dao_health_check() {
    echo "🩺 DIAGNÓSTICO COMPLETO DE DAO"
    echo "============================="
    
    echo "1. Estado de la DAO:"
    sui client call --package $PACKAGE_ID --module dao --function get_dao_info --args $DAO_ID
    
    echo "2. Propuestas activas:"
    # Listar propuestas (implementar si es necesario)
    
    echo "3. Distribución de tokens:"
    echo "   Fundador: $FOUNDER_TOKEN_ID"
    echo "   Miembro 1: $MEMBER1_TOKEN_ID"
    echo "   Miembro 2: $MEMBER2_TOKEN_ID"
    
    echo "4. Últimas transacciones:"
    sui client tx-block [RECENT_TX_ID]
    
    echo "============================="
}

# Ejecutar diagnóstico
# dao_health_check
```

---

## 🚨 **Troubleshooting Avanzado**

### **❌ Error de Votación**
```bash
echo "🚨 PROBLEMA: Error al votar"
echo "=========================="
echo "Verificaciones:"
echo "1. ¿El token pertenece a la DAO correcta?"
echo "   sui client call --package $PACKAGE_ID --module dao --function get_token_info --args [TOKEN_ID]"
echo ""
echo "2. ¿Ya votaste con este token?"
echo "   sui client call --package $PACKAGE_ID --module dao --function has_voted --args $PROPOSAL_ID [ADDRESS]"
echo ""
echo "3. ¿La propuesta está activa?"
echo "   sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID"
```

### **❌ Error de Ejecución**
```bash
echo "🚨 PROBLEMA: Error al ejecutar"
echo "============================="
echo "Verificaciones:"
echo "1. ¿Tiene mayoría de votos?"
echo "   sui client call --package $PACKAGE_ID --module dao --function get_proposal_votes --args $PROPOSAL_ID"
echo ""
echo "2. ¿Hay fondos suficientes?"
echo "   sui client call --package $PACKAGE_ID --module dao --function get_dao_info --args $DAO_ID"
echo ""
echo "3. ¿Ya fue ejecutada?"
echo "   sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID"
```

---

## 📚 **Recursos de Referencia**

### **📖 Tutoriales Específicos**
- **🏗️ Crear DAO**: [`create-dao-updated.md`](create-dao-updated.md)
- **📝 Crear propuesta**: [`submit-proposal-updated.md`](submit-proposal-updated.md)
- **🗳️ Votar**: [`voting-tutorial.md`](voting-tutorial.md)
- **⚡ Ejecutar**: [`execute-proposal.md`](execute-proposal.md)

### **📚 Documentación Técnica**
- **🏛️ Arquitectura DAO**: [`../docs/esplicacion-dao.md`](../docs/esplicacion-dao.md)
- **🔧 Especificaciones técnicas**: [`../docs/technical-specs.md`](../docs/technical-specs.md)
- **🧪 Tests completos**: [`../contracts/tests/dao_tests.move`](../contracts/tests/dao_tests.move)

### **🎓 Recursos de Aprendizaje**
- **📝 Conceptos Move**: [`../learning-notes/01-move-concepts.md`](../learning-notes/01-move-concepts.md)
- **🏗️ Arquitectura**: [`../learning-notes/03-dao-architecture.md`](../learning-notes/03-dao-architecture.md)
- **📋 Log de implementación**: [`../learning-notes/05-implementation-log.md`](../learning-notes/05-implementation-log.md)

---

## 🎉 **¡Felicitaciones!**

### **🏆 Has completado el ciclo completo de DAO:**

#### **✅ Lo que lograste:**
- 🏗️ **Creaste** una DAO descentralizada funcional
- 👥 **Distribuiste** tokens de gobernanza equitativamente
- 📝 **Propusiste** un proyecto comunitario
- 🗳️ **Participaste** en proceso democrático de votación
- ⚡ **Ejecutaste** la decisión de la comunidad
- 💰 **Transfirió** fondos según la voluntad colectiva

#### **🌟 Habilidades desarrolladas:**
- 🎓 **Gobernanza descentralizada**: Entiendes cómo funciona la democracia on-chain
- 💻 **Smart contracts**: Dominas la interacción con contratos en Sui
- 🏛️ **DAOs**: Comprendes la arquitectura y operación de organizaciones autónomas
- 🔍 **Transparencia**: Sabes verificar y auditar procesos blockchain
- 👥 **Colaboración**: Experimentaste coordinación descentralizada

#### **🚀 Impacto de tu conocimiento:**
- 🌍 **Descentralización**: Contribuyes al futuro de organizaciones autónomas
- 💡 **Innovación**: Dominas tecnologías de gobernanza de vanguardia
- 🤝 **Comunidad**: Facilitas coordinación sin intermediarios
- 🔮 **Futuro**: Estás preparado para liderar organizaciones Web3

---

**🎊 ¡Has masterizado el ciclo completo de una DAO! Ahora tienes las herramientas para crear, gestionar y participar en organizaciones descentralizadas que pueden cambiar el mundo.**

### **🔮 Próximos Pasos:**
1. **🏗️ Crear tu propia DAO** para un proyecto real
2. **📈 Experimentar** con diferentes modelos de gobernanza
3. **👥 Invitar comunidad** a participar en tu DAO
4. **🔧 Extender funcionalidad** con nuevas características
5. **🌟 Compartir conocimiento** con otros desarrolladores

**¡El futuro descentralizado comienza contigo! 🚀**
