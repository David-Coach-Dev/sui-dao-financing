# 🚀 Deployment Guide - DAO de Financiamiento

> **Guía paso a paso para desplegar el contrato en Sui Network**

## 📋 **Pre-requisitos**

### 🛠️ **Herramientas Necesarias**
- **Sui CLI** >= 1.0.0
- **Git** para clonar el repositorio
- **Node.js** >= 16 (opcional, para scripts)
- **Wallet** con fondos SUI para gas

### 💰 **Fondos Requeridos**
| Network | Gas Estimate | Recommendation |
|---------|--------------|----------------|
| **Localnet** | 0 SUI | Testing gratuito |
| **Testnet** | ~0.05 SUI | Solicitar via faucet |
| **Mainnet** | ~0.05 SUI | Comprar SUI real |

---

## ⚙️ **Setup Inicial**

### 1. **Instalar Sui CLI**
```bash
# Instalar la versión más reciente
curl -fLsS https://sui.io/install.sh | sh

# Verificar instalación
sui --version
# Expected: sui 1.X.X-...

# Añadir a PATH si es necesario
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 2. **Clonar Repositorio**
```bash
git clone https://github.com/tu-usuario/sui-dao-financing.git
cd sui-dao-financing/contracts
```

### 3. **Verificar Estructura**
```bash
tree .
# contracts/
# ├── Move.toml
# ├── sources/
# │   └── dao.move
# └── tests/
#     └── dao_tests.move
```

---

## 🏠 **Deployment en Localnet**

### **Setup Localnet**
```bash
# Iniciar red local
sui start --with-faucet

# En otra terminal, configurar cliente
sui client new-env --alias localnet --rpc http://127.0.0.1:9000
sui client switch --env localnet

# Crear nueva dirección
sui client new-address ed25519
sui client switch --address [nueva-dirección]

# Obtener fondos del faucet local
sui client faucet
```

### **Build y Test**
```bash
cd contracts

# Compilar contrato
sui move build

# Ejecutar tests
sui move test

# Verificar que todo funciona
# Expected: All tests pass
```

### **Deploy Local**
```bash
# Publicar contrato
sui client publish --gas-budget 100000000

# Guardar el Package ID del output
# Example output:
# Package published at: 0x1a2b3c4d5e6f...
export PACKAGE_ID="0x1a2b3c4d5e6f..."

# Verificar deployment
sui client object $PACKAGE_ID
```

### **Test Básico Post-Deploy**
```bash
# Crear DAO de prueba
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "Test DAO" 100 \
  --gas-budget 20000000

# Guardar DAO Object ID del output
export DAO_ID="0xabcd1234..."
```

---

## 🧪 **Deployment en Testnet**

### **Setup Testnet**
```bash
# Agregar environment testnet
sui client new-env --alias testnet --rpc https://fullnode.testnet.sui.io:443
sui client switch --env testnet

# Crear nueva address o usar existente
sui client addresses

# Si necesitas nueva address:
sui client new-address ed25519
sui client switch --address [address]
```

### **Obtener Fondos de Testnet**
```bash
# Opción 1: CLI Faucet
sui client faucet

# Opción 2: Discord Faucet
# 1. Ir a Discord Sui oficial
# 2. Canal #testnet-faucet  
# 3. Comando: !faucet [tu-address]

# Opción 3: Web Faucet
# Visitar: https://testnet.faucet.sui.io/

# Verificar balance
sui client balance
```

### **Deploy en Testnet**
```bash
cd contracts

# Build final
sui move build

# Run tests una última vez
sui move test --verbose

# Deploy con más gas para testnet
sui client publish --gas-budget 200000000

# Ejemplo de output esperado:
# Transaction Digest: 2E8B7F...
# Package published at: 0x789abc...
# 
# Created Objects:
# ├── ID: 0x789abc... , Owner: Immutable
# └── ID: 0xdef456... , Owner: Account Address ( 0x123... )

# Guardar Package ID
export TESTNET_PACKAGE_ID="0x789abc..."
```

### **Verificación Post-Deploy**
```bash
# Verificar que el package existe
sui client object $TESTNET_PACKAGE_ID

# Ver en explorer
echo "Ver en: https://testnet.suivision.xyz/object/$TESTNET_PACKAGE_ID"

# Crear DAO de prueba
sui client call \
  --package $TESTNET_PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "Testnet DAO" 100 \
  --gas-budget 20000000
```

---

## 🌍 **Deployment en Mainnet**

### ⚠️ **Pre-Deploy Checklist**
- [ ] Todos los tests pasan en localnet
- [ ] Deploy exitoso en testnet  
- [ ] Código auditado y revisado
- [ ] Documentación completa
- [ ] Fondos suficientes para gas (~0.1 SUI)

### **Setup Mainnet**
```bash
# Agregar environment mainnet
sui client new-env --alias mainnet --rpc https://fullnode.mainnet.sui.io:443
sui client switch --env mainnet

# Usar address con fondos reales
sui client addresses
sui client switch --address [tu-address-con-fondos]

# Verificar balance (necesitas SUI real)
sui client balance
```

### **Final Build y Audit**
```bash
cd contracts

# Clean build
rm -rf build/
sui move build

# Final test run
sui move test --verbose

# Verificar que no hay warnings
# Expected: BUILD SUCCESSFUL, all tests pass

# Opcional: Análisis estático
# sui move prove (si tienes Move Prover instalado)
```

### **Mainnet Deployment**
```bash
# ⚠️ IMPORTANTE: Este deployment cuesta SUI real
# Usar gas budget conservador pero suficiente
sui client publish --gas-budget 300000000

# Ejemplo de output exitoso:
# Transaction Digest: A1B2C3D4E5F6...
# Package published at: 0xmainnet123...
# 
# Created Objects:
# ├── ID: 0xmainnet123... , Owner: Immutable
# └── ID: 0xupgrade456... , Owner: Account Address ( 0xmyaddress... )

# 🎉 GUARDAR PACKAGE ID MAINNET
export MAINNET_PACKAGE_ID="0xmainnet123..."

# Verificar en explorer oficial
echo "🔍 Ver en: https://suivision.xyz/object/$MAINNET_PACKAGE_ID"
```

### **Post-Deploy Verification**
```bash
# Verificar package en mainnet
sui client object $MAINNET_PACKAGE_ID --json | jq .

# Crear DAO inicial (opcional)
sui client call \
  --package $MAINNET_PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "Production DAO" 1000 \
  --gas-budget 50000000
```

---

## 📦 **Publicar en Move Registry**

### **Preparar Metadata**
```bash
cd contracts

# Crear metadata file
cat > Move.toml.registry << EOF
[package]
name = "dao_financing"
version = "1.0.0"
edition = "2024.beta"
description = "Decentralized Autonomous Organization for project financing on Sui"
authors = ["Tu Nombre <tu@email.com>"]
license = "MIT"
repository = "https://github.com/tu-usuario/sui-dao-financing"
homepage = "https://github.com/tu-usuario/sui-dao-financing"

[dependencies]
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/mainnet" }

[addresses]
dao_financing = "_"
EOF
```

### **Publish to Registry**
```bash
# Instalar Move Registry CLI (si no lo tienes)
cargo install --git https://github.com/movebit/movey

# Login a Move Registry
movey auth login

# Publish package
movey package publish \
  --package-path . \
  --network mainnet \
  --package-id $MAINNET_PACKAGE_ID

# Verificar publicación
echo "📦 Ver en: https://www.moveregistry.com/package/dao_financing"
```

---

## 📊 **Deployment Log Template**

### **deployment/deployment-log.md**
```markdown
# Deployment Log - DAO Financing

## Localnet Deployment
- **Date:** 2024-09-XX
- **Package ID:** 0x1a2b3c...
- **Status:** ✅ Success
- **Gas Used:** ~50,000 units
- **Test DAO Created:** 0xabcd1234...

## Testnet Deployment  
- **Date:** 2024-09-XX
- **Package ID:** 0x789abc...
- **Status:** ✅ Success
- **Gas Used:** ~150,000 units
- **Transaction:** 0x2E8B7F...
- **Explorer:** https://testnet.suivision.xyz/object/0x789abc...

## Mainnet Deployment
- **Date:** 2024-09-XX
- **Package ID:** 0xmainnet123...
- **Status:** 🎯 Target
- **Gas Budget:** 300,000,000
- **Actual Gas:** TBD
- **Transaction:** TBD
- **Explorer:** https://suivision.xyz/object/0xmainnet123...

## Move Registry
- **Status:** 🎯 Target
- **URL:** https://www.moveregistry.com/package/dao_financing
- **Version:** 1.0.0
```

---

## 🐛 **Troubleshooting**

### **Errores Comunes**

#### **1. "Insufficient gas budget"**
```bash
# Error: Gas budget too low
# Solución: Incrementar gas budget
sui client publish --gas-budget 500000000
```

#### **2. "Package dependencies resolution failed"**
```bash
# Error: Dependencies no resueltas
# Solución: Actualizar Move.toml
[dependencies]
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/mainnet" }
```

#### **3. "Address not found"**
```bash
# Error: No hay addresses configuradas
# Solución: Crear nueva address
sui client new-address ed25519
sui client switch --address [nueva-address]
```

#### **4. "RPC connection failed"**
```bash
# Error: No se puede conectar a RPC
# Solución: Verificar environment
sui client envs
sui client switch --env [correct-env]

# O agregar environment manualmente
sui client new-env --alias mainnet --rpc https://fullnode.mainnet.sui.io:443
```

#### **5. "Compilation failed"**
```bash
# Error: Move compilation errors
# Solución: Verificar sintaxis y dependencias
sui move build --verbose

# Verificar que Move.toml es correcto
cat Move.toml
```

#### **6. "Insufficient balance"**
```bash
# Error: No hay fondos suficientes
# Solución testnet: Usar faucet
sui client faucet

# Solución mainnet: Transferir SUI real
# Verificar balance actual
sui client balance
```

---

## 📋 **Scripts de Automatización**

### **deploy.sh**
```bash
#!/bin/bash
# Automated deployment script

set -e

NETWORK=${1:-testnet}
GAS_BUDGET=${2:-200000000}

echo "🚀 Deploying to $NETWORK with gas budget $GAS_BUDGET"

# Switch to correct network
sui client switch --env $NETWORK

# Verify balance
echo "💰 Current balance:"
sui client balance

# Build contract
echo "🔨 Building contract..."
sui move build

# Run tests
echo "🧪 Running tests..."
sui move test

# Deploy
echo "📦 Deploying to $NETWORK..."
DEPLOY_OUTPUT=$(sui client publish --gas-budget $GAS_BUDGET)

# Extract package ID
PACKAGE_ID=$(echo "$DEPLOY_OUTPUT" | grep -o "Package published at: 0x[a-fA-F0-9]*" | cut -d' ' -f4)

if [ -n "$PACKAGE_ID" ]; then
    echo "✅ Deployment successful!"
    echo "📦 Package ID: $PACKAGE_ID"
    echo "🔍 Explorer: https://$([ $NETWORK = "mainnet" ] && echo "" || echo "testnet.")suivision.xyz/object/$PACKAGE_ID"
    
    # Save to env file
    echo "export ${NETWORK^^}_PACKAGE_ID=\"$PACKAGE_ID\"" >> .env
    
    # Test deployment with sample DAO creation
    echo "🧪 Testing deployment..."
    sui client call \
      --package $PACKAGE_ID \
      --module dao \
      --function create_dao \
      --args "Test DAO" 100 \
      --gas-budget 20000000
    
    echo "🎉 Deployment and test completed successfully!"
else
    echo "❌ Deployment failed!"
    exit 1
fi
```

### **verify.sh**  
```bash
#!/bin/bash
# Verification script

PACKAGE_ID=$1
NETWORK=${2:-testnet}

if [ -z "$PACKAGE_ID" ]; then
    echo "Usage: ./verify.sh <package_id> [network]"
    exit 1
fi

echo "🔍 Verifying package $PACKAGE_ID on $NETWORK"

# Switch to network
sui client switch --env $NETWORK

# Verify package exists
echo "📦 Package info:"
sui client object $PACKAGE_ID

# Test basic functionality
echo "🧪 Testing create_dao function..."
DAO_OUTPUT=$(sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "Verification DAO" 100 \
  --gas-budget 20000000)

# Extract DAO ID
DAO_ID=$(echo "$DAO_OUTPUT" | grep -o "0x[a-fA-F0-9]*" | head -1)

if [ -n "$DAO_ID" ]; then
    echo "✅ Basic functionality verified!"
    echo "🏛️ Test DAO created: $DAO_ID"
else
    echo "❌ Verification failed!"
    exit 1
fi
```

### **setup-env.sh**
```bash
#!/bin/bash
# Environment setup script

echo "🛠️ Setting up Sui development environment"

# Install Sui CLI if not present
if ! command -v sui &> /dev/null; then
    echo "Installing Sui CLI..."
    curl -fLsS https://sui.io/install.sh | sh
    
    # Add to PATH
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
fi

# Verify installation
echo "✅ Sui CLI version:"
sui --version

# Setup environments
echo "🌐 Setting up network environments..."

# Localnet
sui client new-env --alias localnet --rpc http://127.0.0.1:9000 2>/dev/null || echo "Localnet already exists"

# Testnet  
sui client new-env --alias testnet --rpc https://fullnode.testnet.sui.io:443 2>/dev/null || echo "Testnet already exists"

# Mainnet
sui client new-env --alias mainnet --rpc https://fullnode.mainnet.sui.io:443 2>/dev/null || echo "Mainnet already exists"

# Show available environments
echo "📋 Available environments:"
sui client envs

# Create address if none exist
if [ -z "$(sui client addresses)" ]; then
    echo "🔑 Creating new address..."
    sui client new-address ed25519
fi

echo "💰 Current addresses and balances:"
sui client addresses

echo "🎉 Environment setup completed!"
```

---

## 🔄 **CI/CD Integration**

### **GitHub Actions Workflow**
```yaml
# .github/workflows/deploy.yml
name: Deploy to Sui

on:
  push:
    branches: [main]
    paths: ['contracts/**']
  workflow_dispatch:
    inputs:
      network:
        description: 'Network to deploy to'
        required: true
        default: 'testnet'
        type: choice
        options:
        - testnet
        - mainnet

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Install Sui CLI
      run: curl -fLsS https://sui.io/install.sh | sh
      
    - name: Add Sui to PATH
      run: echo "$HOME/.cargo/bin" >> $GITHUB_PATH
      
    - name: Verify installation
      run: sui --version
      
    - name: Build contract
      run: |
        cd contracts
        sui move build
        
    - name: Run tests
      run: |
        cd contracts
        sui move test

  deploy-testnet:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.event.inputs.network == 'testnet'
    steps:
    - uses: actions/checkout@v3
    
    - name: Install Sui CLI
      run: curl -fLsS https://sui.io/install.sh | sh
      
    - name: Add Sui to PATH
      run: echo "$HOME/.cargo/bin" >> $GITHUB_PATH
      
    - name: Setup testnet environment
      run: |
        sui client new-env --alias testnet --rpc https://fullnode.testnet.sui.io:443
        sui client switch --env testnet
        
    - name: Import private key
      run: |
        echo "${{ secrets.SUI_PRIVATE_KEY }}" | sui keytool import ed25519
        
    - name: Deploy to testnet
      run: |
        cd contracts
        sui client publish --gas-budget 200000000

  deploy-mainnet:
    needs: [test, deploy-testnet]
    runs-on: ubuntu-latest
    if: github.event.inputs.network == 'mainnet'
    environment: production
    steps:
    - uses: actions/checkout@v3
    
    - name: Install Sui CLI
      run: curl -fLsS https://sui.io/install.sh | sh
      
    - name: Add Sui to PATH
      run: echo "$HOME/.cargo/bin" >> $GITHUB_PATH
      
    - name: Setup mainnet environment
      run: |
        sui client new-env --alias mainnet --rpc https://fullnode.mainnet.sui.io:443
        sui client switch --env mainnet
        
    - name: Import private key
      run: |
        echo "${{ secrets.MAINNET_PRIVATE_KEY }}" | sui keytool import ed25519
        
    - name: Deploy to mainnet
      run: |
        cd contracts
        sui client publish --gas-budget 300000000
```

---

## 📊 **Monitoring Post-Deploy**

### **Health Check Script**
```bash
#!/bin/bash
# health-check.sh - Monitor deployed contract health

PACKAGE_ID=$1
NETWORK=${2:-mainnet}

if [ -z "$PACKAGE_ID" ]; then
    echo "Usage: ./health-check.sh <package_id> [network]"
    exit 1
fi

echo "🏥 Health check for $PACKAGE_ID on $NETWORK"

# Switch to network
sui client switch --env $NETWORK

# Check package exists and is accessible
echo "1. 📦 Package accessibility..."
if sui client object $PACKAGE_ID > /dev/null 2>&1; then
    echo "   ✅ Package accessible"
else
    echo "   ❌ Package not accessible"
    exit 1
fi

# Test basic function call
echo "2. 🧪 Function call test..."
if sui client call \
    --package $PACKAGE_ID \
    --module dao \
    --function create_dao \
    --args "Health Check DAO" 100 \
    --gas-budget 20000000 \
    --dry-run > /dev/null 2>&1; then
    echo "   ✅ Functions callable"
else
    echo "   ❌ Function call failed"
    exit 1
fi

# Check network status
echo "3. 🌐 Network status..."
if sui client balance > /dev/null 2>&1; then
    echo "   ✅ Network connection healthy"
else
    echo "   ❌ Network connection issues"
    exit 1
fi

echo "🎉 All health checks passed!"
```

### **Usage Analytics Script**
```bash
#!/bin/bash
# analytics.sh - Get deployment usage statistics

PACKAGE_ID=$1
NETWORK=${2:-mainnet}

echo "📊 Usage analytics for $PACKAGE_ID"

# Note: This would require additional RPC calls or indexer access
# For now, showing structure of what you'd monitor:

echo "Metrics to track:"
echo "- Number of DAOs created"
echo "- Total proposals submitted" 
echo "- Total votes cast"
echo "- Total value locked in treasuries"
echo "- Gas usage patterns"
echo "- Error rates"

# Example: Query all DAOs created from this package
echo "🏛️ Finding DAOs created from this package..."
# This would require querying events or objects created by the package
```

---

## 🎯 **Deployment Checklist Completo**

### **Pre-Deploy**
- [ ] **Code Review**: Revisado por al menos 1 persona
- [ ] **Tests**: Todos los tests pasan (localnet)
- [ ] **Build**: Compilación exitosa sin warnings
- [ ] **Dependencies**: Dependencias actualizadas y seguras
- [ ] **Gas Estimation**: Budget calculado correctamente
- [ ] **Funds**: Balance suficiente para deployment
- [ ] **Documentation**: README y docs actualizados

### **Deploy Process**
- [ ] **Testnet Deploy**: Exitoso en testnet primero
- [ ] **Testnet Testing**: Funcionalidad básica verificada
- [ ] **Mainnet Deploy**: Package publicado en mainnet  
- [ ] **Verification**: Funciones básicas probadas
- [ ] **Explorer**: Package visible en explorer
- [ ] **Registry**: Publicado en Move Registry

### **Post-Deploy**
- [ ] **Health Check**: Script de monitoreo ejecutado
- [ ] **Documentation**: Package IDs actualizados en docs
- [ ] **Announcement**: Comunidad notificada
- [ ] **Backup**: Claves privadas respaldadas seguramente
- [ ] **Monitoring**: Sistema de alertas configurado
- [ ] **Support**: Canales de soporte preparados

---

## 🎉 **Celebración del Deploy**

### **Announcement Template**
```markdown
🎉 **DAO de Financiamiento - Now Live on Sui Mainnet!**

After weeks of development and testing, I'm excited to announce that the DAO financing smart contract is now deployed and ready to use!

**📦 Package ID:** `0xMAINNET123...`
**🔍 Explorer:** https://suivision.xyz/object/0xMAINNET123...
**📚 Documentation:** [Link to docs]
**💻 GitHub:** [Link to repo]

**Features:**
✅ Democratic proposal voting
✅ Automatic fund distribution  
✅ Transparent governance
✅ Secure treasury management

Ready to create your own DAO and start funding projects democratically? Check out the documentation to get started!

#Sui #Move #DAO #DeFi #SuiDeveloperProgram
```

### **Social Media Posts**
```markdown
🚀 Just deployed my first Move smart contract on @SuiNetwork! 

A fully functional DAO for democratic project financing with:
• Governance token voting
• Automatic execution
• Treasury management  
• Full transparency

Built during the #SuiDeveloperProgram 🔥

Package: 0xMAINNET123...
```

---

## 📞 **Support y Mantenimiento**

### **Post-Deploy Support Plan**
1. **Week 1**: Monitor daily for issues
2. **Month 1**: Weekly health checks
3. **Ongoing**: Monthly analytics review
4. **Community**: Respond to Discord/GitHub issues

### **Emergency Procedures**
```bash
# If deployment fails:
1. Check gas budget and increase if needed
2. Verify network connectivity  
3. Check for compilation errors
4. Review dependencies

# If functions fail post-deploy:
1. Run health check script
2. Test in dry-run mode first
3. Check network status
4. Review transaction logs
```

---

**📝 Última actualización:** 5 de Septiembre 2024  
**🚀 Status:** Ready for mainnet deployment  
**🎯 Target deployment:** 10 de Septiembre 2024