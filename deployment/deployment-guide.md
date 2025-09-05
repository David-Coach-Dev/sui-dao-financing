# 🚀 Guía Completa de Deployment - Sui DAO Financing

## 📋 Pre-requisitos

### 1. Verificar Configuración Actual
```bash
# Ver red activa (debería ser testnet)
sui client active-env

# Ver redes disponibles
sui client envs

# Ver dirección activa
sui client active-address

# Verificar balance de gas
sui client gas
```

### 2. Estado de tu Proyecto ✅
- **Red actual**: testnet
- **Tests**: 34/34 pasando
- **Build**: Exitoso
- **Código**: Listo para producción

---

## 🔧 Paso 1: Preparación del Deployment

### A. Verificar que el proyecto compile
```bash
cd contracts
sui move build
```

### B. Ejecutar todos los tests
```bash
sui move test
```

### C. Verificar configuración de gas
```bash
# Si necesitas más gas para testnet
sui client faucet
```

---

## 🚀 Paso 2: Deployment a Testnet

### A. Publicar el paquete
```bash
cd contracts
sui client publish --gas-budget 100000000
```

### B. Guardar información del deployment
Después del deployment, guarda:
- **Package ID**: El ID del paquete publicado
- **Transaction Hash**: Hash de la transacción
- **Gas Used**: Gas consumido

### C. Ejemplo de comando completo
```bash
# Deployment con más gas si es necesario
sui client publish --gas-budget 200000000 --skip-dependency-verification
```

---

## 📝 Paso 3: Verificar el Deployment

### A. Verificar el paquete publicado
```bash
# Reemplaza PACKAGE_ID con tu ID real
sui client object PACKAGE_ID
```

### B. Revisar en Sui Explorer
- Ve a: https://testnet.suivision.xyz/
- Busca tu Package ID
- Verifica que todos los módulos estén publicados

---

## 🎯 Paso 4: Interacción Inicial

### A. Crear tu primera DAO
```bash
# Ejemplo de llamada a función (ajustar parámetros)
sui client call \
  --package PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "Mi Primera DAO" "Descripción de la DAO" 1000000000 \
  --gas-budget 10000000
```

### B. Verificar la creación
```bash
# Ver objetos creados
sui client objects
```

---

## 🔄 Paso 5: Testing Post-Deployment

### A. Crear tokens de gobernanza
```bash
sui client call \
  --package PACKAGE_ID \
  --module governance \
  --function create_governance_token \
  --args DAO_ID "Token Name" 100 \
  --gas-budget 10000000
```

### B. Crear una propuesta
```bash
sui client call \
  --package PACKAGE_ID \
  --module proposal \
  --function create_proposal \
  --args DAO_ID "Título de Propuesta" "Descripción" 500000000 RECIPIENT_ADDRESS \
  --gas-budget 10000000
```

---

## 📊 Paso 6: Monitoreo y Logs

### A. Ver transacciones recientes
```bash
sui client transactions --limit 10
```

### B. Ver eventos emitidos
```bash
sui client events --package PACKAGE_ID
```

---

## 🛡️ Paso 7: Seguridad Post-Deployment

### A. Verificar funciones administrativas
- Confirma que solo el owner puede pausar
- Verifica que las validaciones funcionan
- Testea los límites de gas

### B. Documentar direcciones importantes
```
Package ID: [TU_PACKAGE_ID]
DAO Admin: [TU_DIRECCIÓN]
Network: testnet
Deployment Date: [FECHA]
Gas Used: [CANTIDAD]
```

---

## 📋 Comandos de Referencia Rápida

```bash
# Deployment básico
sui client publish --gas-budget 100000000

# Ver gas disponible
sui client gas

# Obtener más gas (testnet)
sui client faucet

# Ver objetos
sui client objects

# Ver información de red
sui client active-env

# Cambiar de red (si necesario)
sui client switch --env mainnet  # ¡CUIDADO! Solo para producción

# Ver balance
sui client balance
```

---

## 🚨 Troubleshooting Común

### Error: Insufficient gas
```bash
# Solicitar más gas
sui client faucet
# O aumentar gas-budget
--gas-budget 200000000
```

### Error: Package already exists
```bash
# Si ya publicaste, usa el Package ID existente
# No necesitas republicar
```

### Error: Module not found
```bash
# Verificar que el build fue exitoso
sui move build
sui move test
```

---

## 🎯 Próximos Pasos

1. **Testear en testnet** completamente
2. **Documentar casos de uso** reales
3. **Preparar para mainnet** cuando esté listo
4. **Crear frontend** para interacción fácil
5. **Establecer gobernanza** inicial

---

## 📚 Recursos Adicionales

- [Sui Documentation](https://docs.sui.io/)
- [Sui Explorer - Testnet](https://testnet.suivision.xyz/)
- [Move Language Guide](https://move-language.github.io/move/)
- [Sui SDK](https://github.com/MystenLabs/sui)

---

**⚠️ Importante**: Este es deployment en **testnet**. Para **mainnet**:
1. Testea extensivamente en testnet primero
2. Audita el código
3. Prepara gas real (SUI)
4. Usa `--env mainnet` con extrema precaución
