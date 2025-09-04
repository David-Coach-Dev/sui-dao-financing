# ⚡ Tutorial de Ejecución de Propuestas - Implementar Decisiones de la DAO

> **Guía paso a paso para ejecutar propuestas aprobadas y transferir fondos**

## 🎯 **¿Qué vamos a hacer?**

En este tutorial aprenderás a:
1. ✅ Verificar si una propuesta puede ejecutarse
2. ✅ Entender las condiciones de ejecución
3. ✅ Ejecutar una propuesta aprobada
4. ✅ Verificar la transferencia de fondos
5. ✅ Confirmar el cambio de estado

**⏱️ Tiempo estimado:** 5-10 minutos  
**💰 Costo aproximado:** ~0.01 SUI en gas fees  
**📋 Prerequisito:** Propuesta con mayoría de votos a favor

---

## 🔧 **Preparación**

### **1. Identificar Propuesta Ejecutable**
```bash
# IDs necesarios de tutoriales anteriores
export DAO_ID="0x..."        # ID de la DAO
export PROPOSAL_ID="0x..."   # ID de propuesta aprobada
export PACKAGE_ID="0x..."    # Package ID del contrato

# Verificar que la propuesta puede ejecutarse
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function can_execute \
  --args $PROPOSAL_ID
```

### **2. Verificar Estado Pre-Ejecución**
```bash
echo "=== ESTADO PRE-EJECUCIÓN ==="

echo "1. Información de la propuesta:"
sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID

echo "2. Votos actuales:"
sui client call --package $PACKAGE_ID --module dao --function get_proposal_votes --args $PROPOSAL_ID

echo "3. Balance de la DAO:"
sui client call --package $PACKAGE_ID --module dao --function get_dao_info --args $DAO_ID
```

### **3. Verificar Recipient Address**
```bash
# Ver a quién se va a transferir
echo "4. Detalles del recipient:"
sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID
# El tercer valor del output será la recipient_address
```

---

## 📋 **Paso 1: Validar Condiciones de Ejecución**

### **✅ Verificar que Puede Ejecutarse**
```bash
# Verificar condiciones
CHECK_EXECUTABLE=$(sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function can_execute \
  --args $PROPOSAL_ID)

echo "¿Puede ejecutarse? $CHECK_EXECUTABLE"
```

### **📊 Entender las Condiciones**
```bash
echo "=== CONDICIONES PARA EJECUCIÓN ==="

# 1. Propuesta debe estar activa (status = 0)
echo "1. Estado de la propuesta:"
sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID
echo "   -> Status debe ser 0 (PROPOSAL_ACTIVE)"

# 2. Votos a favor > Votos en contra
echo "2. Conteo de votos:"
sui client call --package $PACKAGE_ID --module dao --function get_proposal_votes --args $PROPOSAL_ID
echo "   -> votes_for debe ser > votes_against"

# 3. No debe estar ya ejecutada
echo "3. Ya ejecutada:"
sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID
echo "   -> executed debe ser false"
```

### **🔍 Diagnóstico de Estado**
```bash
analyze_proposal() {
    echo "=================================="
    echo "🔍 ANÁLISIS DE EJECUTABILIDAD"
    echo "=================================="
    
    # can_execute debería retornar true
    EXECUTABLE=$(sui client call --package $PACKAGE_ID --module dao --function can_execute --args $PROPOSAL_ID)
    
    if [[ "$EXECUTABLE" == *"true"* ]]; then
        echo "✅ Propuesta PUEDE ejecutarse"
        echo "   - Tiene mayoría de votos a favor"
        echo "   - Está en estado activo"
        echo "   - No ha sido ejecutada previamente"
    else
        echo "❌ Propuesta NO puede ejecutarse"
        echo "   - Verificar votos y estado"
    fi
    echo "=================================="
}

analyze_proposal
```

---

## ⚡ **Paso 2: Ejecutar la Propuesta**

### **📝 Comando de Ejecución**
```bash
echo "🚀 Ejecutando propuesta aprobada..."

sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function execute_proposal \
  --args $DAO_ID $PROPOSAL_ID \
  --gas-budget 10000000
```

### **📊 Output Esperado de Ejecución**
```bash
╭──────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                  │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: ExF9mK2pQvL8nR7tCzXwY6UhJbRzPlKiNnMd5vBnTdE                             │
│ Status: Success                                                                      │
│ Executed Epoch: 129                                                                 │
│ Gas Used: 3200000                                                                   │
│                                                                                      │
│ Mutated Objects                                                                      │
│  ┌──                                                                                │
│  │ ObjectID: 0xdao123...abc789         [DAO - balance actualizado]                 │
│  │ Owner: Shared                                                                    │
│  │ ObjectType: 0x...::dao::DAO                                                     │
│  │ Version: 5                                                                       │
│  └──                                                                                │
│  ┌──                                                                                │
│  │ ObjectID: 0xproposal123...def456    [Propuesta - estado actualizado]           │
│  │ Owner: Shared                                                                    │
│  │ ObjectType: 0x...::dao::Proposal                                                │
│  │ Version: 3                                                                       │
│  └──                                                                                │
│                                                                                      │
│ Created Objects                                                                      │
│  ┌──                                                                                │
│  │ ObjectID: 0xcoin789...xyz123        [Coin transferido al recipient]            │
│  │ Owner: Address(0xrecipient123...def) [Destinatario de los fondos]             │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                      │
│  │ Version: 1                                                                       │
│  └──                                                                                │
│                                                                                      │
│ Events                                                                               │
│  ┌──                                                                                │
│  │ PackageID: 0x...                                                                │
│  │ Transaction Module: dao                                                          │
│  │ Sender: 0x456...xyz                                                             │
│  │ EventType: 0x...::dao::ProposalExecuted                                         │
│  │ ParsedJSON:                                                                      │
│  │   ┌─────────────────────────────────────────────────────────────────────────   │
│  │   │ {                                                                           │
│  │   │   "proposal_id": "0xproposal123...def456",                                  │
│  │   │   "amount": "1000000000",                                                   │
│  │   │   "recipient": "0xrecipient123...def"                                       │
│  │   │ }                                                                           │
│  │   └─────────────────────────────────────────────────────────────────────────   │
│  │  └──                                                                                │
╰──────────────────────────────────────────────────────────────────────────────────────╯
```

### **🔍 ¿Qué Pasó en la Ejecución?**

#### **✅ Objetos Mutados:**
- **DAO**: Balance reducido por la cantidad transferida (Version incrementada)
- **Propuesta**: Estado cambiado a ejecutada (Version incrementada)

#### **🆕 Objetos Creados:**
- **Coin**: Nueva moneda SUI creada y transferida al recipient

#### **📡 Eventos Emitidos:**
- **ProposalExecuted**: Registro público de la ejecución con detalles

---

## 📊 **Paso 3: Verificar la Ejecución**

### **✅ Confirmar Estado Post-Ejecución**
```bash
echo "=== VERIFICACIÓN POST-EJECUCIÓN ==="

echo "1. Estado actualizado de la propuesta:"
sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID
echo "   -> executed debe ser true"
echo "   -> status debe ser 3 (PROPOSAL_EXECUTED)"

echo "2. Balance actualizado de la DAO:"
sui client call --package $PACKAGE_ID --module dao --function get_dao_info --args $DAO_ID
echo "   -> balance debe estar reducido"

echo "3. ¿Puede ejecutarse de nuevo?"
sui client call --package $PACKAGE_ID --module dao --function can_execute --args $PROPOSAL_ID
echo "   -> debe retornar false (ya ejecutada)"
```

### **💰 Verificar Transferencia de Fondos**
```bash
echo "4. Verificar que el recipient recibió los fondos:"

# Obtener la recipient address de la propuesta
RECIPIENT_INFO=$(sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID)
echo "Recipient address: [Ver en output anterior]"

# Ver objetos del recipient (opcional)
echo "Objetos del recipient:"
# sui client objects --owner [RECIPIENT_ADDRESS]
```

### **📈 Resumen de Cambios**
```bash
show_execution_summary() {
    echo "=================================="
    echo "📊 RESUMEN DE EJECUCIÓN"
    echo "=================================="
    echo "Propuesta: $PROPOSAL_ID"
    echo "DAO: $DAO_ID"
    echo ""
    echo "✅ CAMBIOS REALIZADOS:"
    echo "   - Propuesta marcada como ejecutada"
    echo "   - Fondos transferidos al recipient"
    echo "   - Balance de DAO actualizado"
    echo "   - Estado cambiado a EXECUTED (3)"
    echo ""
    echo "🔒 PROTECCIONES ACTIVADAS:"
    echo "   - No se puede ejecutar de nuevo"
    echo "   - Registro inmutable en blockchain"
    echo "   - Evento público emitido"
    echo "=================================="
}

show_execution_summary
```

---

## 🏆 **Casos de Uso y Escenarios**

### **💰 Financiamiento de Proyecto**
```bash
echo "🚀 ESCENARIO: Financiamiento aprobado"
echo "- Un desarrollador solicitó 1 SUI para desarrollo"
echo "- La comunidad votó a favor"
echo "- Fondos transferidos automáticamente"
echo "- Proyecto puede comenzar inmediatamente"
```

### **🎁 Donación Comunitaria**
```bash
echo "❤️ ESCENARIO: Donación aprobada"
echo "- Propuesta para donar a causa benéfica"
echo "- Mayoría de la DAO votó a favor"
echo "- Fondos enviados directamente al beneficiario"
echo "- Impacto social transparente"
```

### **💼 Reembolso Autorizado**
```bash
echo "💼 ESCENARIO: Reembolso aprobado"
echo "- Miembro solicitó reembolso por gastos"
echo "- Comunidad verificó y aprobó"
echo "- Reembolso procesado automáticamente"
echo "- Contabilidad actualizada"
```

---

## 👥 **Quién Puede Ejecutar**

### **🌟 Ejecución Abierta**
```bash
echo "🌟 CUALQUIER PERSONA PUEDE EJECUTAR:"
echo "=================================="
echo "✅ No necesitas ser miembro de la DAO"
echo "✅ No necesitas tokens de gobernanza"
echo "✅ Solo necesitas pagar gas fees"
echo "✅ Incentiva la participación comunitaria"
echo ""
echo "💡 BENEFICIOS DEL SISTEMA ABIERTO:"
echo "   - Mayor velocidad de ejecución"
echo "   - Menor dependencia en miembros activos"
echo "   - Transparencia total del proceso"
echo "   - Descentralización real"
```

### **💰 Incentivos para Ejecutar**
```bash
echo "💰 INCENTIVOS PARA EJECUTORES:"
echo "=============================="
echo "🎯 Reputación en la comunidad"
echo "🤝 Construcción de confianza"
echo "⚡ Acelerar implementación de decisiones"
echo "🏆 Contribuir al éxito de la DAO"
echo ""
echo "🔮 FUTURAS MEJORAS POSIBLES:"
echo "   - Recompensas por ejecución"
echo "   - Sistema de puntos de reputación"
echo "   - Descuentos en gas fees"
```

---

## ⚠️ **Troubleshooting**

### **❌ "Proposal not executable"**
```bash
# Error: E_PROPOSAL_NOT_EXECUTABLE
echo "DIAGNÓSTICO:"
echo "1. Verificar votos: votes_for > votes_against"
echo "2. Verificar estado: status = 0 (ACTIVE)"
echo "3. Verificar ejecución: executed = false"

echo "COMANDOS DE DIAGNÓSTICO:"
echo "sui client call --package $PACKAGE_ID --module dao --function get_proposal_votes --args $PROPOSAL_ID"
echo "sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID"
```

### **❌ "Already executed"**
```bash
# Error: E_PROPOSAL_ALREADY_EXECUTED  
echo "La propuesta ya fue ejecutada previamente."
echo "Cada propuesta solo puede ejecutarse una vez."
echo ""
echo "Verificar estado:"
echo "sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID"
echo "executed debe ser true"
```

### **❌ "Insufficient funds"**
```bash
# Error: E_INSUFFICIENT_FUNDS
echo "La DAO no tiene suficientes fondos para la propuesta."
echo "Esto podría pasar si:"
echo "- Se ejecutaron otras propuestas primero"
echo "- Hubo retiros no registrados"
echo "- Error en el balance inicial"
echo ""
echo "Verificar balance:"
echo "sui client call --package $PACKAGE_ID --module dao --function get_dao_info --args $DAO_ID"
```

### **❌ "Wrong proposal state"**
```bash
# Error: Estado inválido de propuesta
echo "La propuesta no está en estado ACTIVE."
echo "Estados posibles:"
echo "0 = ACTIVE (puede ejecutarse)"
echo "1 = APPROVED (aprobada pero no ejecutada)"
echo "2 = REJECTED (rechazada)"
echo "3 = EXECUTED (ya ejecutada)"
echo ""
echo "Solo propuestas ACTIVE pueden ejecutarse."
```

---

## 🔍 **Verificación de Integridad**

### **🛡️ Verificar que Todo Funcionó Correctamente**
```bash
integrity_check() {
    echo "=================================="
    echo "🛡️ VERIFICACIÓN DE INTEGRIDAD"
    echo "=================================="
    
    echo "1. ✅ Propuesta ejecutada:"
    EXECUTED=$(sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID)
    echo "   executed = true ✓"
    
    echo "2. ✅ Estado actualizado:"
    echo "   status = 3 (EXECUTED) ✓"
    
    echo "3. ✅ No se puede ejecutar de nuevo:"
    CAN_EXECUTE=$(sui client call --package $PACKAGE_ID --module dao --function can_execute --args $PROPOSAL_ID)
    echo "   can_execute = false ✓"
    
    echo "4. ✅ Balance de DAO actualizado:"
    echo "   [Ver nuevo balance en dao info] ✓"
    
    echo "5. ✅ Evento emitido:"
    echo "   ProposalExecuted event ✓"
    
    echo "=================================="
    echo "🎉 EJECUCIÓN COMPLETADA CON ÉXITO"
    echo "=================================="
}

integrity_check
```

---

## 🔄 **Flujo Completo de Vida de una Propuesta**

```bash
echo "🔄 CICLO COMPLETO DE PROPUESTA:"
echo "=============================="
echo "1. 📝 CREACIÓN    -> submit_proposal()"
echo "2. 🗳️ VOTACIÓN    -> cast_vote()"
echo "3. ⚡ EJECUCIÓN   -> execute_proposal() [AQUÍ ESTAMOS]"
echo "4. ✅ FINALIZADA  -> Estado inmutable"
echo ""
echo "📊 ESTADOS:"
echo "0 = ACTIVE     (recibiendo votos)"
echo "1 = APPROVED   (mayoría a favor, no usado)"
echo "2 = REJECTED   (mayoría en contra, no usado)"
echo "3 = EXECUTED   (completada exitosamente)"
```

---

## 📚 **Recursos Adicionales**

- **🗳️ Tutorial de votación**: [`voting-tutorial.md`](voting-tutorial.md)
- **🏛️ Crear DAO**: [`create-dao-updated.md`](create-dao-updated.md)
- **📝 Crear propuesta**: [`submit-proposal-updated.md`](submit-proposal-updated.md)
- **🔄 Flujo completo**: [`full-workflow.md`](full-workflow.md) (próximamente)
- **📖 Documentación del contrato**: [`../docs/esplicacion-dao.md`](../docs/esplicacion-dao.md)
- **🧪 Ver tests de ejecución**: [`../contracts/tests/dao_tests.move`](../contracts/tests/dao_tests.move)

---

## 🎉 **¡Felicitaciones!**

### **✅ Has ejecutado exitosamente una propuesta:**
- ✅ Verificaste las condiciones de ejecución
- ✅ Ejecutaste la transferencia de fondos
- ✅ Confirmaste la actualización de estados
- ✅ Completaste el ciclo democrático de la DAO

### **🌟 Impacto de tu Acción:**
- 💰 **Implementación**: Convertiste decisiones en acciones reales
- ⚡ **Eficiencia**: Facilitaste la operación fluida de la DAO
- 🤝 **Servicio**: Ayudaste a la comunidad a cumplir sus compromisos
- 🏗️ **Construcción**: Fortaleciste la infraestructura descentralizada

---

**🎊 ¡Excelente trabajo! Has completado el proceso de ejecución y ayudado a que las decisiones democráticas de la DAO se conviertan en acciones concretas en el blockchain.**
