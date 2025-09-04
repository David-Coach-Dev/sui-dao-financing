# 🗳️ Tutorial de Votación - Participar en la Gobernanza de la DAO

> **Guía paso a paso para votar en propuestas y participar en la toma de decisiones**

## 🎯 **¿Qué vamos a hacer?**

En este tutorial aprenderás a:
1. ✅ Identificar propuestas disponibles para votar
2. ✅ Revisar detalles de una propuesta específica
3. ✅ Usar tu token de gobernanza para votar
4. ✅ Verificar que tu voto fue registrado correctamente
5. ✅ Entender el proceso de conteo y decisión

**⏱️ Tiempo estimado:** 10-15 minutos  
**💰 Costo aproximado:** ~0.02 SUI en gas fees  
**📋 Prerequisito:** Tener un token de gobernanza de la DAO

---

## 🔧 **Preparación**

### **1. Verificar Prerequisites**
```bash
# IDs necesarios del tutorial anterior
export DAO_ID="0x..."        # ID de la DAO
export PROPOSAL_ID="0x..."   # ID de la propuesta a votar
export PACKAGE_ID="0x..."    # Package ID del contrato

# Verificar que tienes tokens de gobernanza
sui client objects --filter StructType:$PACKAGE_ID::dao::GovernanceToken
```

### **2. Obtener tu Token ID**
```bash
# Listar tus tokens de gobernanza y guardar uno
export TOKEN_ID="0x..."  # ID de tu token de gobernanza

# Verificar información del token
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_token_info \
  --args $TOKEN_ID
```

### **3. Verificar Estado de la Propuesta**
```bash
# Ver información actual de la propuesta
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_proposal_info \
  --args $PROPOSAL_ID
```

---

## 📋 **Paso 1: Analizar la Propuesta**

### **🔍 Revisar Detalles Completos**
```bash
# Información básica de la propuesta
echo "=== DETALLES DE LA PROPUESTA ==="
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_proposal_info \
  --args $PROPOSAL_ID

# Votos actuales
echo "=== VOTOS ACTUALES ==="
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_proposal_votes \
  --args $PROPOSAL_ID

# Ver si ya votaste
echo "=== TU ESTADO DE VOTO ==="
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function has_voted \
  --args $PROPOSAL_ID $(sui client active-address)
```

### **📊 Interpretar la Información**
```bash
# Script para mostrar resumen legible
show_proposal_summary() {
    echo "=================================="
    echo "📋 RESUMEN DE LA PROPUESTA"
    echo "=================================="
    echo "ID: $PROPOSAL_ID"
    
    # Los datos vienen en el orden: title, amount, proposer, executed, status
    echo "Título: [Ver en output de get_proposal_info]"
    echo "Cantidad: [Ver amount] MIST"
    echo "Proposer: [Ver proposer address]"
    echo "Estado: [0=Activa, 1=Aprobada, 2=Rechazada, 3=Ejecutada]"
    echo "Ejecutada: [Ver executed: true/false]"
    echo "=================================="
}

show_proposal_summary
```

---

## 🗳️ **Paso 2: Decidir tu Voto**

### **🤔 Consideraciones para tu Decisión**

**✅ Votar SÍ (true) si:**
- El proyecto beneficia a la comunidad
- La cantidad solicitada es razonable
- El proposer es confiable
- El proyecto es factible

**❌ Votar NO (false) si:**
- El proyecto no aporta valor
- La cantidad es excesiva
- Hay dudas sobre la ejecución
- Hay mejores alternativas

### **💪 Verificar tu Poder de Voto**
```bash
# Ver cuánto poder de voto tienes
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_token_info \
  --args $TOKEN_ID

# El output mostrará: [dao_id, voting_power]
echo "Tu poder de voto: [Ver voting_power en el output]"
```

---

## ✅ **Paso 3: Votar SÍ (A Favor)**

### **📝 Comando para Votar A Favor**
```bash
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function cast_vote \
  --args $PROPOSAL_ID $TOKEN_ID true \
  --gas-budget 10000000
```

### **📊 Output Esperado**
```bash
╭──────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                  │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: VoGpF8xK2qLN7mR9tBzYwX5VhJaQzPrKiMnLc6vBnSdE                             │
│ Status: Success                                                                      │
│ Executed Epoch: 128                                                                 │
│ Gas Used: 2800000                                                                   │
│                                                                                      │
│ Mutated Objects                                                                      │
│  ┌──                                                                                │
│  │ ObjectID: 0xproposal123...def456   [Propuesta - votos actualizados]            │
│  │ Owner: Shared                                                                    │
│  │ ObjectType: 0x...::dao::Proposal                                                │
│  │ Version: 2                                                                       │
│  └──                                                                                │
│                                                                                      │
│ Events                                                                               │
│  ┌──                                                                                │
│  │ PackageID: 0x...                                                                │
│  │ Transaction Module: dao                                                          │
│  │ Sender: 0x123...abc                                                             │
│  │ EventType: 0x...::dao::VoteCast                                                 │
│  │ ParsedJSON:                                                                      │
│  │   ┌─────────────────────────────────────────────────────────────────────────   │
│  │   │ {                                                                           │
│  │   │   "proposal_id": "0xproposal123...def456",                                  │
│  │   │   "support": true,                                                          │
│  │   │   "voter": "0x123...abc",                                                   │
│  │   │   "voting_power": "1000"                                                    │
│  │   │ }                                                                           │
│  │   └─────────────────────────────────────────────────────────────────────────   │
│  └──                                                                                │
╰──────────────────────────────────────────────────────────────────────────────────────╯
```

### **🔍 ¿Qué pasó?**
- ✅ Tu voto fue registrado con `support: true` (a favor)
- ✅ Tu `voting_power` se añadió a los votos a favor
- ✅ Se emitió evento `VoteCast` público
- ✅ La propuesta fue actualizada (Version incrementada)

---

## ❌ **Alternativa: Votar NO (En Contra)**

### **📝 Comando para Votar En Contra**
```bash
# Si prefieres votar NO, usa false en lugar de true
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function cast_vote \
  --args $PROPOSAL_ID $TOKEN_ID false \
  --gas-budget 10000000
```

**🔍 La diferencia:** `support: false` y tu poder se añade a `votes_against`

---

## 🔍 **Paso 4: Verificar tu Voto**

### **✅ Confirmar que tu Voto fue Registrado**
```bash
# Verificar que ya votaste
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function has_voted \
  --args $PROPOSAL_ID $(sui client active-address)
# Debería retornar: true
```

### **📊 Ver Conteo Actualizado**
```bash
# Ver votos totales después de tu voto
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_proposal_votes \
  --args $PROPOSAL_ID
# Debería mostrar tu poder de voto añadido al total correspondiente
```

### **🔍 Ver tu Voto Específico**
```bash
# Consultar detalles de tu voto
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_vote \
  --args $PROPOSAL_ID $(sui client active-address)
```

---

## 📊 **Paso 5: Entender el Estado Post-Voto**

### **🎯 Verificar si la Propuesta Puede Ejecutarse**
```bash
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function can_execute \
  --args $PROPOSAL_ID
```

**📋 Interpretación:**
- **`true`**: Propuesta tiene más votos a favor, puede ejecutarse
- **`false`**: Aún no tiene mayoría o tiene más votos en contra

### **📈 Ver Estado Completo Post-Voto**
```bash
echo "=== ESTADO DESPUÉS DE TU VOTO ==="

echo "1. Información de la propuesta:"
sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID

echo "2. Conteo de votos actualizado:"
sui client call --package $PACKAGE_ID --module dao --function get_proposal_votes --args $PROPOSAL_ID

echo "3. ¿Puede ejecutarse ahora?"
sui client call --package $PACKAGE_ID --module dao --function can_execute --args $PROPOSAL_ID

echo "4. ¿Ya votaste?"
sui client call --package $PACKAGE_ID --module dao --function has_voted --args $PROPOSAL_ID $(sui client active-address)
```

---

## 🏆 **Escenarios Post-Votación**

### **✅ Escenario 1: Propuesta Puede Ejecutarse**
```bash
# Si can_execute retorna true, cualquiera puede ejecutar
echo "🎉 ¡Tu voto ayudó a que la propuesta tenga mayoría!"
echo "Ahora cualquier miembro puede ejecutarla para transferir los fondos."
echo ""
echo "Para ejecutar:"
echo "sui client call --package $PACKAGE_ID --module dao --function execute_proposal --args $DAO_ID $PROPOSAL_ID"
```

### **⏳ Escenario 2: Aún Necesita Más Votos**
```bash
# Si can_execute retorna false
echo "⏳ La propuesta aún necesita más votos para ser aprobada."
echo "Otros miembros de la DAO pueden seguir votando."
echo ""
echo "Estado actual: [ver output de get_proposal_votes]"
echo "Necesita: votes_for > votes_against"
```

### **❌ Escenario 3: Propuesta Rechazada**
```bash
# Si tiene más votos en contra que a favor
echo "❌ La propuesta actualmente tiene más votos en contra."
echo "Aún puede cambiar si más miembros votan a favor."
echo ""
echo "Los votos en contra superan a los votos a favor."
```

---

## 👥 **Invitar a Otros a Votar**

### **📢 Notificar a la Comunidad**
```bash
echo "📢 LLAMADO A VOTAR - PROPUESTA ACTIVA"
echo "======================================"
echo "Propuesta ID: $PROPOSAL_ID"
echo "Tu voto: [A favor/En contra]"
echo "Estado actual: [Ver conteo de votos]"
echo ""
echo "Otros miembros pueden votar con:"
echo "sui client call --package $PACKAGE_ID --module dao --function cast_vote --args $PROPOSAL_ID [TOKEN_ID] [true/false]"
echo ""
echo "¡Cada voto cuenta para el futuro de nuestra DAO!"
```

---

## ⚠️ **Troubleshooting**

### **❌ "Already voted"**
```bash
# Error: E_ALREADY_VOTED
# Solución: No puedes votar dos veces con el mismo token
echo "Ya votaste en esta propuesta. Un token solo puede votar una vez."
```

### **❌ "Wrong DAO token"**
```bash
# Error: E_WRONG_DAO_TOKEN  
# Solución: Verificar que el token pertenece a la DAO correcta
sui client call --package $PACKAGE_ID --module dao --function get_token_info --args $TOKEN_ID
# El dao_id del token debe coincidir con el dao_id de la propuesta
```

### **❌ "Proposal not active"**
```bash
# Error: E_PROPOSAL_NOT_ACTIVE
# Solución: La propuesta ya fue ejecutada o está en estado inválido
sui client call --package $PACKAGE_ID --module dao --function get_proposal_info --args $PROPOSAL_ID
# Verificar que status = 0 (PROPOSAL_ACTIVE)
```

### **❌ "Zero voting power"**
```bash
# Error: E_ZERO_VOTING_POWER
# Solución: Tu token debe tener poder de voto > 0
sui client call --package $PACKAGE_ID --module dao --function get_token_info --args $TOKEN_ID
# Verificar que voting_power > 0
```

---

## 📚 **Recursos Adicionales**

- **⚡ Tutorial de ejecución**: [`execute-proposal.md`](execute-proposal.md) (próximamente)
- **🏛️ Crear DAO**: [`create-dao-updated.md`](create-dao-updated.md)
- **📝 Crear propuesta**: [`submit-proposal-updated.md`](submit-proposal-updated.md)
- **📖 Documentación del contrato**: [`../docs/esplicacion-dao.md`](../docs/esplicacion-dao.md)
- **🧪 Ver tests de votación**: [`../contracts/tests/dao_tests.move`](../contracts/tests/dao_tests.move)

---

## 🎉 **¡Felicitaciones!**

### **✅ Has participado exitosamente en la gobernanza:**
- ✅ Evaluaste una propuesta de la comunidad
- ✅ Usaste tu token de gobernanza para votar
- ✅ Contribuiste al proceso democrático de decisión
- ✅ Tu voto está registrado de forma transparente e inmutable

### **🌟 Impacto de tu Participación:**
- 🗳️ **Democracia**: Participaste en la toma de decisiones colectiva
- 🔍 **Transparencia**: Tu voto es público y auditable
- 🏛️ **Gobernanza**: Ayudaste a dirigir el futuro de la DAO
- 💪 **Comunidad**: Fortaleciste la participación descentralizada

---

**🎊 ¡Excelente trabajo! Has ejercido tu derecho de voto en la DAO y contribuido al proceso democrático descentralizado. Tu participación es fundamental para el éxito de la gobernanza comunitaria.**
