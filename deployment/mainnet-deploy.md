# Guía de Deployment en Mainnet

## Información General

Esta guía proporciona instrucciones detalladas para desplegar el sistema DAO en la red principal de Sui (Mainnet).

## Prerrequisitos

### Software Requerido
- Sui CLI instalado y configurado
- Gas suficiente en SUI para el deployment
- Acceso a una wallet configurada para Mainnet

### Configuración de Red
```bash
# Configurar Sui CLI para Mainnet
sui client new-env --alias mainnet --rpc https://fullnode.mainnet.sui.io:443
sui client switch --env mainnet
```

### Verificación de Balance
```bash
# Verificar balance actual
sui client gas

# Si necesitas gas, puedes obtenerlo desde:
# - Exchanges centralizados
# - Bridges desde otras redes
# - Faucets de testnet (solo para testing)
```

## Proceso de Deployment

### 1. Preparación del Código

Antes del deployment, asegúrate de que todos los tests pasen:

```bash
# Ejecutar todos los tests
cd contracts
sui move test

# Verificar compilación
sui move build
```

### 2. Estimación de Gas

```bash
# Estimar costo de deployment
sui client publish --dry-run --gas-budget 100000000
```

### 3. Deployment Principal

```bash
# Desplegar el paquete completo
sui client publish --gas-budget 100000000

# Guardar el output para referencia
# El comando mostrará:
# - Package ID
# - Object IDs de los objetos creados
# - Gas usado
```

### 4. Verificación del Deployment

```bash
# Verificar que el paquete fue desplegado
sui client object <PACKAGE_ID>

# Verificar módulos disponibles
sui client call --package <PACKAGE_ID> --module dao --function create_dao --dry-run
```

## Configuración Post-Deployment

### 1. Crear DAO Principal

```bash
# Crear la primera DAO
sui client call \
  --package <PACKAGE_ID> \
  --module dao \
  --function create_dao \
  --args "\"DAO Principal\"" "\"DAO para financiación de proyectos\"" \
  --gas-budget 10000000
```

### 2. Configurar Tokens de Gobernanza

```bash
# Crear tokens iniciales para fundadores
sui client call \
  --package <PACKAGE_ID> \
  --module governance \
  --function mint_token \
  --args <DAO_ID> <RECIPIENT_ADDRESS> 1000 \
  --gas-budget 10000000
```

### 3. Verificar Funcionalidad

```bash
# Crear una propuesta de prueba
sui client call \
  --package <PACKAGE_ID> \
  --module proposal \
  --function create_proposal \
  --args <DAO_ID> "\"Propuesta de Prueba\"" "\"Descripción de prueba\"" 604800000 \
  --gas-budget 10000000
```

## Monitoreo y Mantenimiento

### 1. Monitoreo de Eventos

```bash
# Monitorear eventos de la DAO
sui client events --package <PACKAGE_ID>

# Filtrar eventos específicos
sui client events --package <PACKAGE_ID> --module dao
```

### 2. Verificación de Estado

```bash
# Verificar estado de DAOs
sui client object <DAO_ID>

# Verificar propuestas activas
sui client objects --owner <DAO_ADDRESS>
```

### 3. Backup de Información

```bash
# Exportar información crítica
echo "Package ID: <PACKAGE_ID>" > deployment_info.txt
echo "DAO ID: <DAO_ID>" >> deployment_info.txt
echo "Deployment Date: $(date)" >> deployment_info.txt
```

## Costos Estimados

### Gas para Deployment
- **Deployment del paquete**: ~50-100M gas units
- **Crear DAO**: ~5-10M gas units
- **Crear propuesta**: ~3-5M gas units
- **Votar**: ~2-3M gas units

### Cálculo de Costos en SUI
```
Costo en SUI = (Gas Units * Gas Price) / 1_000_000_000
```

## Mejores Prácticas

### Seguridad
1. **Verificar direcciones**: Siempre verificar las direcciones antes de enviar transacciones
2. **Gas límites**: Usar límites de gas apropiados para evitar fallos
3. **Testing previo**: Probar todas las funciones en testnet primero

### Optimización
1. **Batch operations**: Agrupar operaciones similares para ahorrar gas
2. **Timing**: Desplegar durante períodos de baja congestión
3. **Monitoring**: Configurar alertas para eventos críticos

### Documentación
1. **Registrar IDs**: Mantener un registro de todos los IDs importantes
2. **Versioning**: Usar tags de git para marcar deployments
3. **Changelog**: Documentar cambios entre versiones

## Troubleshooting

### Errores Comunes

1. **Gas insuficiente**
   ```bash
   # Error: Insufficient gas
   # Solución: Incrementar gas-budget
   ```

2. **Objetos no encontrados**
   ```bash
   # Error: Object not found
   # Solución: Verificar IDs y ownership
   ```

3. **Fallas de compilación**
   ```bash
   # Error: Compilation failed
   # Solución: Verificar sintaxis y dependencias
   ```

### Comandos de Diagnóstico

```bash
# Verificar configuración de red
sui client active-env

# Verificar objetos owned
sui client objects

# Verificar transacciones recientes
sui client transactions
```

## Actualizaciones

### Proceso de Upgrade

```bash
# Para actualizaciones de código
sui client upgrade --package <PACKAGE_ID> --gas-budget 100000000

# Verificar compatibilidad
sui move build --check-compatibility
```

### Migración de Datos

Si se requiere migración de datos:

1. Pausar operaciones críticas
2. Exportar estado actual
3. Desplegar nueva versión
4. Migrar datos
5. Reanudar operaciones

## Contacto y Soporte

Para soporte durante el deployment:
- Documentación oficial de Sui
- Discord de la comunidad Sui
- GitHub issues del proyecto

---

**Nota**: Esta guía asume familiaridad con Sui CLI y conceptos básicos de blockchain. Siempre probar en testnet antes de mainnet.
