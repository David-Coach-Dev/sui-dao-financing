# 💡 Ejemplos de Uso - DAO de Financiamiento

> **Ejemplos prácticos paso a paso para usar la DAO**

## 🎯 **Información General**

Esta carpeta contiene ejemplos completos de cómo interactuar con nuestra DAO de financiamiento. Cada archivo muestra un flujo específico con comandos reales y explicaciones detalladas.

### 📋 **Ejemplos Disponibles**

| Archivo | Descripción | Dificultad | Tiempo |
|---------|-------------|------------|--------|
| [**create-dao.md**](create-dao.md) | Crear nueva DAO desde cero | ⭐⚪⚪ | 5 min |
| [**submit-proposal.md**](submit-proposal.md) | Enviar propuesta de financiamiento | ⭐⭐⚪ | 10 min |
| [**voting-example.md**](voting-example.md) | Votar en propuestas existentes | ⭐⭐⚪ | 8 min |
| [**execute-proposal.md**](execute-proposal.md) | Ejecutar propuesta aprobada | ⭐⭐⭐ | 15 min |
| [**full-workflow.md**](full-workflow.md) | Flujo completo de principio a fin | ⭐⭐⭐ | 30 min |

---

## 🔧 **Prerequisitos**

### **Antes de empezar necesitas:**

1. **Sui CLI instalado**
   ```bash
   curl -fLsS https://sui.io/install.sh | sh
   sui --version
   ```

2. **Address con fondos**
   ```bash
   # Ver addresses disponibles
   sui client addresses
   
   # Para testnet: obtener fondos del faucet
   sui client faucet
   
   # Verificar balance
   sui client balance
   ```

3. **Package ID del contrato**
   ```bash
   # Usar nuestro package deployado
   export PACKAGE_ID="0x..." # Obtener del deployment
   ```

4. **Environment correcto**
   ```bash
   # Para testnet (recomendado para ejemplos)
   sui client switch --env testnet
   
   # Para mainnet (usar con cuidado)
   sui client switch --env mainnet
   ```

---

## 🎮 **Guía Rápida**

### **🚀 Para empezar rápidamente:**

1. **Elegir ejemplo según tu objetivo:**
   - **Primera vez usando DAOs** → [create-dao.md](create-dao.md)
   - **Quiero proponer un proyecto** → [submit-proposal.md](submit-proposal.md)
   - **Quiero votar en propuestas** → [voting-example.md](voting-example.md)
   - **Administrar una DAO** → [execute-proposal.md](execute-proposal.md)

2. **Seguir el ejemplo paso a paso**
   - Cada comando está explicado
   - Outputs esperados incluidos
   - Troubleshooting para errores comunes

3. **Experimentar con variaciones**
   - Cambiar parámetros
   - Probar diferentes escenarios
   - Entender qué pasa en cada caso

---

## 🎯 **Escenarios de Uso**

### 🏢 **Organizaciones**
```bash
# Ejemplo: DAO para una startup
./create-dao.md "Mi Startup DAO" 1000

# Financiar desarrollo de producto
./submit-proposal.md "Desarrollo MVP" "1000000000" 

# Team members votan
./voting-example.md [proposal-id] true
```

### 🎓 **Comunidades Educativas**
```bash
# DAO para financiar cursos
./create-dao.md "Comunidad Educativa" 100

# Proponer nuevo curso
./submit-proposal.md "Curso de Blockchain" "500000000"

# Estudiantes votan por cursos de interés
./voting-example.md [proposal-id] true
```

### 🌱 **Proyectos de Impacto**
```bash
# DAO para proyectos ambientales
./create-dao.md "Green Impact DAO" 500

# Proponer proyecto de reforestación
./submit-proposal.md "Plantar 1000 árboles" "2000000000"

# Comunidad evalúa impacto y vota
./voting-example.md [proposal-id] true
```

---

## 📊 **Datos de Ejemplo**

### **DAOs de Prueba**
Para practicar, puedes usar estas DAOs ya creadas en testnet:

| DAO Name | Object ID | Description |
|----------|-----------|-------------|
| Demo DAO | `0xdemo123...` | DAO de demostración |
| Test Community | `0xtest456...` | Para testing de propuestas |
| Example Gov | `0xexample789...` | Governance examples |

### **Propuestas de Ejemplo**
```bash
# Propuestas típicas para practicar
"Website Development" - 1 SUI
"Marketing Campaign" - 0.5 SUI  
"Community Event" - 2 SUI
"Educational Content" - 0.8 SUI
"Bug Bounty Program" - 1.5 SUI
```

### **Tokens de Governance**
Si necesitas tokens para votar, algunos están disponibles para testing:
```bash
# Solicitar tokens de prueba (solo testnet)
# Contactar en Discord: tu-usuario#1234
```

---

## 🔍 **Patrones Comunes**

### **Pattern 1: Crear y Financiar DAO**
```bash
# 1. Crear DAO
sui client call --package $PACKAGE_ID --module dao --function create_dao \
  --args "Mi DAO" 100 --gas-budget 20000000

# 2. Obtener DAO ID del output
export DAO_ID="0x..."

# 3. Financiar DAO
sui client pay --input-amounts 1000000000 --recipients $DAO_ID
```

### **Pattern 2: Propuesta → Votación → Ejecución**
```bash
# 1. Crear propuesta
sui client call --package $PACKAGE_ID --module dao --function create_proposal \
  --args $DAO_ID "Título" "Descripción" 500000000 --gas-budget 20000000

# 2. Obtener Proposal ID
export PROPOSAL_ID="0x..."

# 3. Votar (necesita governance token)
sui client call --package $PACKAGE_ID --module dao --function cast_vote \
  --args $PROPOSAL_ID $TOKEN_ID true --gas-budget 20000000

# 4. Ejecutar si fue aprobada
sui client call --package $PACKAGE_ID --module dao --function execute_proposal \
  --args $DAO_ID $PROPOSAL_ID --gas-budget 20000000
```

### **Pattern 3: Query y Verificación**
```bash
# Verificar estado de propuesta
sui client object $PROPOSAL_ID

# Ver votaciones actuales
sui client dynamic-fields $PROPOSAL_ID

# Verificar balance de DAO
sui client object $DAO_ID
```

---

## 🐛 **Troubleshooting Common Issues**

### **Error: "Insufficient gas budget"**
```bash
# Solución: Incrementar gas budget
--gas-budget 50000000  # En lugar de 20000000
```

### **Error: "Object not found"**
```bash
# Solución: Verificar que el object ID es correcto
sui client object [OBJECT_ID]

# O que estás en el network correcto
sui client switch --env testnet
```

### **Error: "Already voted"**
```bash
# Verificar si ya votaste
sui client dynamic-fields $PROPOSAL_ID

# Buscar tu address en la lista
```

### **Error: "Wrong DAO token"**
```bash
# Verificar que el token pertenece a la DAO correcta
sui client object $TOKEN_ID

# Verificar el campo dao_id coincide con la DAO
```

---

## 📚 **Recursos Adicionales**

### **Documentación**
- [API Reference](../docs/api-reference.md) - Referencia completa de funciones
- [Technical Specs](../docs/technical-specs.md) - Detalles técnicos
- [Deployment Guide](../docs/deployment-guide.md) - Cómo desplegar tu propia copia

### **Tools Útiles**
- [Sui Explorer](https://suivision.xyz/) - Para verificar transacciones
- [Sui Faucet](https://testnet.faucet.sui.io/) - Obtener SUI para testnet
- [Move Registry](https://www.moveregistry.com/) - Explorar packages

### **Comunidad**
- **Discord Sui Latam:** [discord.com/invite/QpdfBHgD6m](https://discord.com/invite/QpdfBHgD6m)
- **Discord Zona Tres:** [discord.com/invite/aUUCHa96Ja](https://discord.com/invite/aUUCHa96Ja)
- **GitHub Issues:** [Reportar problemas](https://github.com/tu-usuario/sui-dao-financing/issues)

---

## 🎨 **Personalización**

### **Adaptar ejemplos a tu caso:**

1. **Cambiar nombres y descripciones**
   ```bash
   # En lugar de "Demo DAO"
   "Mi Proyecto DAO"
   
   # En lugar de "Test Proposal"  
   "Financiar desarrollo de app móvil"
   ```

2. **Ajustar cantidades**
   ```bash
   # En lugar de 1000000000 (1 SUI)
   500000000    # 0.5 SUI
   2000000000   # 2 SUI
   ```

3. **Modificar parámetros de gobernanza**
   ```bash
   # En lugar de min_voting_power = 100
   --args "Mi DAO" 1000  # Más restrictivo
   --args "Mi DAO" 1     # Más abierto
   ```

---

## 🔄 **Actualizaciones**

### **Versioning de Ejemplos**
| Versión | Fecha | Cambios |
|---------|-------|---------|
| v1.0.0 | 5 Sept 2024 | Ejemplos iniciales completos |
| v0.3.0 | 4 Sept 2024 | Full workflow agregado |
| v0.2.0 | 3 Sept 2024 | Voting y execution examples |
| v0.1.0 | 2 Sept 2024 | Create DAO y submit proposal |

### **Próximas Adiciones**
- [ ] Ejemplo de DAO multi-token
- [ ] Advanced governance patterns
- [ ] Integration with dApps
- [ ] Batch operations examples

---

**📝 Última actualización:** 5 de Septiembre 2024  
**🎯 Ejemplos verificados en:** Sui Testnet  
**💬 Feedback:** [Crear issue en GitHub](https://github.com/tu-usuario/sui-dao-financing/issues)