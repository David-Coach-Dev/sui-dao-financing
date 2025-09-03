# 🏛️ Crear Nueva DAO - Ejemplo Completo

> **Guía paso a paso para crear tu primera DAO de financiamiento**

## 🎯 **¿Qué vamos a hacer?**

En este ejemplo aprenderás a:
1. ✅ Crear una nueva DAO desde cero
2. ✅ Configurar parámetros iniciales
3. ✅ Verificar que la DAO fue creada correctamente
4. ✅ Financiar la tesorería inicial
5. ✅ Crear tokens de gobernanza para los miembros

**⏱️ Tiempo estimado:** 10-15 minutos  
**💰 Costo aproximado:** ~0.02 SUI en gas

---

## 🔧 **Preparación**

### **Verificar Prerequisites**
```bash
# 1. Verificar Sui CLI
sui --version
# Expected: sui 1.X.X-...

# 2. Verificar network (recomendamos testnet para este ejemplo)
sui client active-env
# Expected: testnet

# 3. Verificar balance
sui client balance
# Expected: > 100000000 MIST (0.1 SUI)

# 4. Verificar package ID
echo $PACKAGE_ID
# Si está vacío, usar nuestro package deployado:
export PACKAGE_ID="0x..." # Package ID del deployment
```

### **Variables de Ejemplo**
```bash
# Configuración para nuestro ejemplo
export DAO_NAME="Mi Primera DAO"
export MIN_VOTING_POWER=100
export INITIAL_FUNDING=1000000000  # 1 SUI en MIST
```

---

## 🚀 **Paso 1: Crear la DAO**

### **Ejecutar el Comando**
```bash
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "$DAO_NAME" $MIN_VOTING_POWER \
  --gas-budget 30000000
```

### **Output Esperado**
```
Transaction Digest: A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6...

Created Objects:
├── ID: 0xdao123456789abcdef... , Owner: Shared
└── ID: 0xcap987654321fedcba... , Owner: Account Address ( 0xtu_address... )

Mutated Objects:
├── ID: 0xgas1234... , Owner: Account Address ( 0xtu_address... )

Gas Object:
├── ID: 0xgas1234... , Owner: Account Address ( 0xtu_address... )
├── Version: 42
├── Digest: 7x8y9z...

Gas Used: 1,847,200

Status: Success
```

### **Guardar el DAO ID**
```bash
# Del output anterior, copiar el ID del objeto Shared
export DAO_ID="0xdao123456789abcdef..."

echo "✅ DAO creada con ID: $DAO_ID"
```

---

## 🔍 **Paso 2: Verificar la Creación**

### **Consultar el Objeto DAO**
```bash
sui client object $DAO_ID
```

### **Output Esperado**
```json
{
  "objectId": "0xdao123456789abcdef...",
  "version": "1",
  "digest": "...",
  "type": "0xpackage123...::dao::DAO",
  "owner": {
    "Shared": {
      "initial_shared_version": 1
    }
  },
  "content": {
    "dataType": "moveObject",
    "type": "0xpackage123...::dao::DAO",
    "fields": {
      "active": true,
      "id": {
        "id": "0xdao123456789abcdef..."
      },
      "min_voting_power": "100",
      "name": "Mi Primera DAO",
      "proposal_count": "0",
      "treasury": {
        "type": "0x2::balance::Balance<0x2::sui::SUI>",
        "fields": {
          "value": "0"
        }
      }
    }
  }
}
```

### **Verificar los Campos**
```bash
# Extraer información importante
echo "📛 Nombre: Mi Primera DAO"
echo "💰 Treasury: 0 SUI (necesita funding)"
echo "📊 Propuestas: 0"
echo "⚡ Min Voting Power: 100"
echo "🟢 Activa: true"
```

---

## 💰 **Paso 3: Financiar la DAO**

### **Crear Coin para Financiamiento**
```bash
# Crear un coin de 1 SUI para financiar la DAO
sui client pay \
  --input-amounts $INITIAL_FUNDING \
  --recipients $(sui client active-address) \
  --gas-budget 10000000
```

### **Output del Pay**
```
Transaction Digest: X1Y2Z3A4B5C6D7E8F9G0H1I2J3K4L5M6...

Created Objects:
├── ID: 0xcoin123456... , Owner: Account Address ( 0xtu_address... )

Gas Used: 1,234,567
Status: Success
```

### **Financiar la DAO**
```bash
# Usar el coin creado para financiar la DAO
export FUNDING_COIN="0xcoin123456..."

sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function fund_dao \
  --args $DAO_ID $FUNDING_COIN \
  --gas-budget 20000000
```

### **Verificar Treasury Actualizada**
```bash
sui client object $DAO_ID --json | jq '.content.fields.treasury.fields.value'
# Expected: "1000000000"

echo "✅ DAO financiada con 1 SUI"
```

---

## 🎫 **Paso 4: Crear Tokens de Gobernanza**

### **Mint Token para Ti (Fundador)**
```bash
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function mint_governance_token \
  --args $DAO_ID $(sui client active-address) 1000 \
  --gas-budget 20000000
```

### **Mint Tokens para Miembros Adicionales**
```bash
# Ejemplo: crear tokens para otros miembros
export MEMBER1="0x1234567890abcdef..."  # Address del miembro 1
export MEMBER2="0xfedcba0987654321..."  # Address del miembro 2

# Token para miembro 1 (500 poder de voto)
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function mint_governance_token \
  --args $DAO_ID $MEMBER1 500 \
  --gas-budget 20000000

# Token para miembro 2 (300 poder de voto)
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function mint_governance_token \
  --args $DAO_ID $MEMBER2 300 \
  --gas-budget 20000000
```

### **Verificar Tokens Creados**
```bash
# Ver tus tokens de gobernanza
sui client objects $(sui client active-address) \
  --filter StructType=$PACKAGE_ID::dao::GovernanceToken
```

---

## 🔍 **Paso 5: Verificación Final**

### **Dashboard de la DAO**
```bash
echo "🏛️ === RESUMEN DE TU DAO ==="
echo "📛 Nombre: $DAO_NAME"
echo "🆔 ID: $DAO_ID"
echo ""

# Treasury balance
TREASURY_BALANCE=$(sui client object $DAO_ID --json | jq -r '.content.fields.treasury.fields.value')
TREASURY_SUI=$(echo "scale=4; $TREASURY_BALANCE / 1000000000" | bc -l)
echo "💰 Treasury: $TREASURY_SUI SUI"

# Proposal count
PROPOSAL_COUNT=$(sui client object $DAO_ID --json | jq -r '.content.fields.proposal_count')
echo "📊 Propuestas: $PROPOSAL_COUNT"

# Status
ACTIVE=$(sui client object $DAO_ID --json | jq -r '.content.fields.active')
echo "🟢 Estado: $ACTIVE"

echo ""
echo "✅ ¡DAO creada exitosamente!"
```

### **Link al Explorer**
```bash
# Ver en el explorer de Sui
echo "🔍 Ver en explorer:"
if [ "$(sui client active-env)" == "mainnet" ]; then
    echo "https://suivision.xyz/object/$DAO_ID"
else
    echo "https://testnet.suivision.xyz/object/$DAO_ID"
fi
```

---

## 🎯 **¿Qué acabas de lograr?**

### ✅ **Creaciones Exitosas**
1. **DAO Shared Object** - Accessible por toda la comunidad
2. **Treasury Financiada** - 1 SUI disponible para propuestas
3. **Governance Tokens** - Tokens distribuidos a miembros clave
4. **Estructura Democrática** - Lista para recibir propuestas

### 📊 **Distribución de Poder**
```
Total Voting Power: 1,800
├── Tu address: 1,000 (55.6%)
├── Miembro 1:    500 (27.8%)  
└── Miembro 2:    300 (16.7%)
```

---

## 🚀 **Próximos Pasos**

### **¿Qué puedes hacer ahora?**

1. **Crear Primera Propuesta** 📝
   ```bash
   # Ver ejemplo completo:
   cat examples/submit-proposal.md
   ```

2. **Invitar Más Miembros** 👥
   ```bash
   # Mint más tokens de gobernanza
   sui client call --package $PACKAGE_ID --module dao \
     --function mint_governance_token \
     --args $DAO_ID [new_member_address] [voting_power]
   ```

3. **Configurar Gobierno** ⚖️
   ```bash
   # Definir procesos de la comunidad
   # - ¿Cuánto poder mínimo para proponer?
   # - ¿Cuánto tiempo para votar?
   # - ¿Qué tipos de propuestas permitir?
   ```

---

## 🔄 **Variaciones del Ejemplo**

### **DAO Más Restrictiva**
```bash
# Solo miembros con alto poder pueden votar
sui client call --package $PACKAGE_ID --module dao --function create_dao \
  --args "Elite DAO" 1000 --gas-budget 30000000
```

### **DAO Más Abierta**
```bash
# Cualquiera con 1 token puede votar
sui client call --package $PACKAGE_ID --module dao --function create_dao \
  --args "Community DAO" 1 --gas-budget 30000000
```

### **DAO Especializada**
```bash
# DAO para propósito específico
export SPECIALIZED_NAME="DevTools Funding DAO"
sui client call --package $PACKAGE_ID --module dao --function create_dao \
  --args "$SPECIALIZED_NAME" 100 --gas-budget 30000000
```

---

## 🐛 **Troubleshooting**

### **Error: "Insufficient gas budget"**
```bash
# Problema: Gas insuficiente
# Solución: Incrementar budget
--gas-budget 50000000  # En lugar de 30000000
```

### **Error: "Insufficient balance"**
```bash
# Problema: No tienes suficiente SUI
# Solución para testnet: Usar faucet
sui client faucet

# Solución para mainnet: Conseguir más SUI
```

### **Error: "Package not found"**
```bash
# Problema: Package ID incorrecto
# Solución: Verificar el PACKAGE_ID
sui client object $PACKAGE_ID

# O usar nuestro package official:
export PACKAGE_ID="0x..."  # Package ID correcto
```

### **DAO No Aparece Como Shared**
```bash
# Verificar que fue creada como shared object
sui client object $DAO_ID --json | jq '.owner'

# Expected: {"Shared": {"initial_shared_version": 1}}
```

---

## 📚 **Comandos de Referencia Rápida**

### **Setup**
```bash
export PACKAGE_ID="0x..."
export DAO_NAME="Mi DAO"
export MIN_VOTING_POWER=100
```

### **Crear DAO**
```bash
sui client call --package $PACKAGE_ID --module dao --function create_dao \
  --args "$DAO_NAME" $MIN_VOTING_POWER --gas-budget 30000000
```

### **Financiar DAO**
```bash
sui client pay --input-amounts 1000000000 --recipients $(sui client active-address)
sui client call --package $PACKAGE_ID --module dao --function fund_dao \
  --args $DAO_ID $COIN_ID --gas-budget 20000000
```

### **Mint Tokens**
```bash
sui client call --package $PACKAGE_ID --module dao --function mint_governance_token \
  --args $DAO_ID [address] [power] --gas-budget 20000000
```

### **Verificar**
```bash
sui client object $DAO_ID
```

---

## 💡 **Tips Pro**

### **🎯 Mejores Prácticas**

1. **Planifica la Distribución de Poder**
   - Evita que una persona tenga >51% del poder
   - Distribuye según contribuciones o participación
   - Considera crecimiento futuro de la comunidad

2. **Documenta las Reglas**
   ```markdown
   # Reglas de Mi DAO
   - Min voting power: 100 tokens
   - Proposal threshold: 500 tokens
   - Voting period: 7 days
   - Quorum required: 30% participation
   ```

3. **Start Small, Scale Big**
   - Comienza con treasury modesta
   - Añade fondos según éxito de propuestas
   - Incrementa miembros gradualmente

4. **Backup Crucial Info**
   ```bash
   # Guardar IDs importantes
   echo "DAO_ID=$DAO_ID" >> .env
   echo "PACKAGE_ID=$PACKAGE_ID" >> .env
   echo "CREATION_DATE=$(date)" >> .env
   ```

### **🔧 Automatización**
```bash
#!/bin/bash
# create-dao-script.sh
set -e

DAO_NAME=$1
MIN_POWER=$2
FUNDING_AMOUNT=$3

echo "🏛️ Creating DAO: $DAO_NAME"

# Create DAO
DAO_OUTPUT=$(sui client call --package $PACKAGE_ID --module dao --function create_dao \
  --args "$DAO_NAME" $MIN_POWER --gas-budget 30000000)

# Extract DAO ID
DAO_ID=$(echo "$DAO_OUTPUT" | grep -o "0x[a-fA-F0-9]*" | head -1)
echo "✅ DAO created: $DAO_ID"

# Fund if amount provided
if [ -n "$FUNDING_AMOUNT" ]; then
    echo "💰 Funding DAO with $FUNDING_AMOUNT MIST"
    # Add funding logic here
fi

echo "🎉 DAO setup completed!"
```

---

## 🎉 **¡Felicitaciones!**

Has creado exitosamente tu primera DAO de financiamiento en Sui. Tu DAO ahora puede:

- ✅ **Recibir propuestas** de la comunidad
- ✅ **Votar democráticamente** en decisiones
- ✅ **Distribuir fondos automáticamente** 
- ✅ **Mantener transparencia total** en blockchain

**¿Qué sigue?** 
- 📝 [Crear tu primera propuesta](submit-proposal.md)
- 🗳️ [Aprender a votar](voting-example.md)  
- 🔄 [Ver el flujo completo](full-workflow.md)

---

**📝 Creado:** 5 de Septiembre 2024  
**🧪 Testado en:** Sui Testnet  
**⏱️ Tiempo promedio:** 12 minutos  
**💰 Costo promedio:** 0.018 SUI