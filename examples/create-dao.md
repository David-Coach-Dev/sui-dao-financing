# 🏛️ Crear Nueva DAO - Tutorial Completo

> **Guía paso a paso para crear tu primera DAO de financiamiento en Sui Network**

## 🎯 **¿Qué vamos a hacer?**

En este tutorial aprenderás a:
1. ✅ Crear una nueva DAO desde cero
2. ✅ Verificar que la DAO fue creada correctamente  
3. ✅ Financiar la tesorería de la DAO
4. ✅ Crear tokens de gobernanza para votar
5. ✅ Consultar información de la DAO

**⏱️ Tiempo estimado:** 10-15 minutos  
**💰 Costo aproximado:** ~0.05 SUI en gas fees

---

## 🔧 **Preparación**

### **1. Verificar Prerequisites**
```bash
# Verificar Sui CLI instalado
sui --version
# Esperado: sui 1.x.x-xxxxx

# Verificar red activa (usar testnet para práctica)
sui client active-env
# Esperado: testnet

# Verificar balance suficiente
sui client balance
# Esperado: > 100000000 MIST (0.1 SUI)

# Ver tu address actual
sui client active-address
```

### **2. Configurar Variables del Tutorial**
```bash
# Package ID del contrato DAO (cuando esté deployado)
export PACKAGE_ID="0x..." # Reemplazar con el Package ID real

# Configuración de nuestra DAO de ejemplo
export DAO_NAME="Mi Primera DAO"
export MIN_VOTING_POWER=100
export INITIAL_FUNDING=2000000000  # 2 SUI en unidades MIST
export YOUR_ADDRESS=$(sui client active-address)
```

---

## 🏗️ **Paso 1: Crear la DAO**

### **📝 Comando para Crear DAO**
```bash
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "$DAO_NAME" $MIN_VOTING_POWER \
  --gas-budget 10000000
```

### **📊 Output Esperado**
```bash
╭──────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                  │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: HyQoKhaoL5TQ7xMKnSGEH3aBFbDHQ5Nf9nKYZ8mJrXzv                             │
│ Status: Success                                                                      │
│ Executed Epoch: 120                                                                 │
│ Gas Used: 2500000                                                                   │
│                                                                                      │
│ Created Objects                                                                      │
│  ┌──                                                                                │
│  │ ObjectID: 0xabc123...def789                                                     │
│  │ Sender: 0x123...abc                                                             │
│  │ Owner: Shared                                                                    │
│  │ ObjectType: 0x...::dao::DAO                                                     │
│  │ Version: 1                                                                       │
│  │ Digest: xyz789...                                                               │
│  └──                                                                                │
│                                                                                      │
│ Events                                                                               │
│  ┌──                                                                                │
│  │ PackageID: 0x...                                                                │
│  │ Transaction Module: dao                                                          │
│  │ Sender: 0x123...abc                                                             │
│  │ EventType: 0x...::dao::DAOCreated                                               │
│  │ ParsedJSON:                                                                      │
│  │   ┌─────────────────────────────────────────────────────────────────────────   │
│  │   │ {                                                                           │
│  │   │   "creator": "0x123...abc",                                                 │
│  │   │   "dao_id": "0xabc123...def789",                                            │
│  │   │   "min_voting_power": "100",                                                │
│  │   │   "name": "Mi Primera DAO"                                                  │
│  │   │ }                                                                           │
│  │   └─────────────────────────────────────────────────────────────────────────   │
│  └──                                                                                │
╰──────────────────────────────────────────────────────────────────────────────────────╯
```

### **🔍 ¿Qué pasó aquí?**
1. **Se creó un objeto DAO compartido** que cualquiera puede ver y usar
2. **Se emitió un evento DAOCreated** con la información de la nueva DAO
3. **El objeto tiene Owner: Shared** lo que significa que es accesible globalmente
4. **Se generó un ObjectID único** que usaremos para referenciar esta DAO

### **💾 Guardar Object ID**
```bash
# IMPORTANTE: Guardar el Object ID de la DAO creada
export DAO_ID="0xabc123...def789"  # Reemplazar con el ID real del output
echo "DAO creada con ID: $DAO_ID"
```

---

## 💰 **Paso 2: Financiar la DAO**

### **📝 Comando para Añadir Fondos**
```bash
# Crear una moneda SUI para financiar la DAO
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function fund_dao \
  --args $DAO_ID \
  --type-args 0x2::sui::SUI \
  --gas-budget 10000000 \
  --gas $INITIAL_FUNDING
```

### **🔍 Explicación del Comando**
- **`--args $DAO_ID`**: Referencia a nuestra DAO
- **`--type-args 0x2::sui::SUI`**: Especifica que usamos monedas SUI
- **`--gas $INITIAL_FUNDING`**: Usa SUI del gas para financiar la DAO

### **📊 Output Esperado**
```bash
╭──────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                  │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ Status: Success                                                                      │
│ Gas Used: 1500000                                                                   │
│                                                                                      │
│ Mutated Objects                                                                      │
│  ┌──                                                                                │
│  │ ObjectID: 0xabc123...def789                                                     │
│  │ Sender: 0x123...abc                                                             │
│  │ Owner: Shared                                                                    │
│  │ ObjectType: 0x...::dao::DAO                                                     │
│  │ Version: 2                                                                       │
│  └──                                                                                │
╰──────────────────────────────────────────────────────────────────────────────────────╯
```

---

## 🎫 **Paso 3: Crear Tokens de Gobernanza**

### **📝 Comando para Crear Token**
```bash
# Crear token de gobernanza para ti mismo
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function mint_governance_token \
  --args $DAO_ID $YOUR_ADDRESS 1000 \
  --gas-budget 10000000
```

### **🔍 Explicación del Comando**
- **`$DAO_ID`**: ID de nuestra DAO
- **`$YOUR_ADDRESS`**: Tu address recibirá el token
- **`1000`**: Poder de voto del token (puedes ajustar este valor)

### **📊 Output Esperado**
```bash
╭──────────────────────────────────────────────────────────────────────────────────────╮
│ Created Objects                                                                      │
│  ┌──                                                                                │
│  │ ObjectID: 0xtoken123...abc789                                                   │
│  │ Sender: 0x123...abc                                                             │
│  │ Owner: Account Address ( 0x123...abc )                                          │
│  │ ObjectType: 0x...::dao::GovernanceToken                                         │
│  │ Version: 1                                                                       │
│  └──                                                                                │
╰──────────────────────────────────────────────────────────────────────────────────────╯
```

### **💾 Guardar Token ID**
```bash
export TOKEN_ID="0xtoken123...abc789"  # Reemplazar con el ID real
echo "Token de gobernanza creado: $TOKEN_ID"
```

---

## 🔍 **Paso 4: Verificar la DAO Creada**

### **📝 Consultar Información de la DAO**
```bash
# Ver información básica de la DAO
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_dao_info \
  --args $DAO_ID
```

### **📝 Ver Objetos en tu Wallet**
```bash
# Ver todos tus objetos (incluirá el token de gobernanza)
sui client objects

# Ver específicamente tokens de gobernanza
sui client objects --filter StructType:$PACKAGE_ID::dao::GovernanceToken
```

### **📝 Consultar Información del Token**
```bash
# Ver detalles del token de gobernanza
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_token_info \
  --args $TOKEN_ID
```

---

## ✅ **Verificar que Todo Funciona**

### **🎯 Checklist de Verificación**

1. **✅ DAO Creada**
   ```bash
   # La DAO debe existir y ser consultable
   sui client object $DAO_ID
   ```

2. **✅ DAO Financiada**
   ```bash
   # El balance de la DAO debe mostrar los fondos
   # (esto se verifica con get_dao_info)
   ```

3. **✅ Token Creado**
   ```bash
   # Debes tener un token de gobernanza en tu wallet
   sui client objects | grep GovernanceToken
   ```

4. **✅ Token Configurado**
   ```bash
   # El token debe estar asociado a tu DAO
   # (verificar con get_token_info)
   ```

---

## 🎉 **¡Felicitaciones! Tu DAO está Lista**

### **📋 Lo que tienes ahora:**
- ✅ **Una DAO funcional** con nombre "Mi Primera DAO"
- ✅ **Tesorería financiada** con 2 SUI
- ✅ **Token de gobernanza** con 1000 puntos de votación
- ✅ **Configuración mínima** de 100 puntos para votar

### **🚀 Próximos Pasos:**
1. **📝 Crear una propuesta** - Ve a [`submit-proposal.md`](submit-proposal.md)
2. **🗳️ Votar en propuestas** - Sigue el tutorial de votación
3. **👥 Invitar miembros** - Crea más tokens de gobernanza para otros
4. **💰 Financiar más** - Añadir más fondos cuando sea necesario

---

## 🛠️ **Comandos de Utilidad**

### **📊 Ver Estado de la DAO**
```bash
# Estado completo
sui client object $DAO_ID --json

# Solo información básica
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function get_dao_info \
  --args $DAO_ID
```

### **🎫 Gestionar Tokens**
```bash
# Ver todos tus tokens
sui client objects --filter StructType:$PACKAGE_ID::dao::GovernanceToken

# Crear token para otro usuario
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function mint_governance_token \
  --args $DAO_ID 0x[ADDRESS_DEL_USUARIO] 500 \
  --gas-budget 10000000
```

### **💰 Añadir Más Fondos**
```bash
# Financiar con más SUI
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function fund_dao \
  --args $DAO_ID \
  --type-args 0x2::sui::SUI \
  --gas-budget 10000000 \
  --gas 1000000000  # 1 SUI adicional
```

---

## ⚠️ **Troubleshooting**

### **❌ "Insufficient gas"**
```bash
# Solución: Aumentar gas budget
--gas-budget 20000000  # Doblar el gas budget
```

### **❌ "Object not found"**
```bash
# Solución: Verificar Object ID
sui client object $DAO_ID
# Si no existe, verificar el transaction digest de creación
```

### **❌ "Package not found"**
```bash
# Solución: Verificar Package ID
echo $PACKAGE_ID
# Si está incorrecto, obtener el correcto del deployment
```

### **❌ "Invalid address format"**
```bash
# Solución: Verificar formato de address
echo $YOUR_ADDRESS
# Debe empezar con 0x y tener 64 caracteres hexadecimales
```

---

## 📚 **Recursos Adicionales**

- **📖 Documentación del contrato**: [`../docs/esplicacion-dao.md`](../docs/esplicacion-dao.md)
- **🧪 Ver tests como ejemplos**: [`../contracts/tests/dao_tests.move`](../contracts/tests/dao_tests.move)
- **📋 Próximo tutorial**: [`submit-proposal.md`](submit-proposal.md)
- **🏗️ Estructura del proyecto**: [`../docs/project-structure-updated.md`](../docs/project-structure-updated.md)

---

**🎊 ¡Excelente trabajo! Has creado tu primera DAO en Sui Network. Ahora puedes crear propuestas y comenzar la gobernanza descentralizada.**
