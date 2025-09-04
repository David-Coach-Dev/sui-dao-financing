# Guía de Deployment en Testnet

## Información General

Esta guía proporciona instrucciones para desplegar y probar el sistema DAO en la red de pruebas de Sui (Testnet).

## Configuración Inicial

### 1. Configurar Sui CLI para Testnet

```bash
# Agregar environment de testnet
sui client new-env --alias testnet --rpc https://fullnode.testnet.sui.io:443

# Cambiar a testnet
sui client switch --env testnet

# Verificar configuración
sui client active-env
```

### 2. Obtener Gas de Testnet

```bash
# Solicitar SUI de testnet desde el faucet
sui client faucet

# Verificar balance
sui client balance

# Si necesitas más gas
curl --location --request POST 'https://faucet.testnet.sui.io/gas' \
--header 'Content-Type: application/json' \
--data-raw '{
    "FixedAmountRequest": {
        "recipient": "<YOUR_ADDRESS>"
    }
}'
```

## Proceso de Deployment

### 1. Preparación y Testing

```bash
# Navegar al directorio del proyecto
cd contracts

# Ejecutar todos los tests
sui move test

# Verificar que no hay errores de compilación
sui move build

# Ver estructura del paquete
sui move build --dump-bytecode-as-base64
```

### 2. Deployment del Paquete

```bash
# Desplegar en testnet
sui client publish --gas-budget 100000000

# El output incluirá información importante:
# - Package ID: Guárdalo para interacciones futuras
# - Created Objects: IDs de objetos iniciales
# - Gas Used: Cantidad real de gas consumido
```

**Ejemplo de output:**
```
Successfully verified dependencies on-chain against source.
----- Transaction Digest ----
ABC123...

----- Transaction Data ----
Package ID: 0x1234567890abcdef...
Created Objects:
  - ID: 0xabc123..., Owner: Immutable
  - ID: 0xdef456..., Owner: Shared

----- Events ----
No events emitted.

----- Object Changes ----
Created Objects:
  - Package (0x1234567890abcdef...)
Gas Object:
  - objectId: 0x789..., version: 1, digest: GHI789...
```

### 3. Verificación del Deployment

```bash
# Verificar que el paquete existe
sui client object <PACKAGE_ID>

# Listar objetos creados
sui client objects --owned-by <YOUR_ADDRESS>
```

## Testing en Testnet

### 1. Crear DAO de Prueba

```bash
# Usar el Package ID obtenido del deployment
export PACKAGE_ID="0x1234567890abcdef..."

# Crear primera DAO
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "\"DAO de Prueba\"" "\"DAO para testing en testnet\"" \
  --gas-budget 20000000
```

### 2. Configurar Tokens de Gobernanza

```bash
# Guardar el DAO ID del output anterior
export DAO_ID="0xabc123..."

# Crear tokens para diferentes direcciones de prueba
sui client call \
  --package $PACKAGE_ID \
  --module governance \
  --function mint_token \
  --args $DAO_ID @0x123... 1000 \
  --gas-budget 10000000

# Repetir para más direcciones si es necesario
```

### 3. Pruebas de Propuestas

```bash
# Crear propuesta de prueba
sui client call \
  --package $PACKAGE_ID \
  --module proposal \
  --function create_proposal \
  --args $DAO_ID "\"Propuesta de Testing\"" "\"Una propuesta para probar funcionalidad\"" 604800000 \
  --gas-budget 15000000

# Guardar PROPOSAL_ID del output
export PROPOSAL_ID="0xdef456..."
```

### 4. Pruebas de Votación

```bash
# Crear registro de votación
sui client call \
  --package $PACKAGE_ID \
  --module voting \
  --function create_voting_record \
  --args $PROPOSAL_ID \
  --gas-budget 10000000

# Si tienes un token de gobernanza, puedes votar
# (requiere tener el token en tu dirección)
```

## Monitoreo y Debugging

### 1. Verificar Eventos

```bash
# Ver todos los eventos del paquete
sui client events --package $PACKAGE_ID

# Filtrar eventos por módulo
sui client events --package $PACKAGE_ID --module dao

# Ver eventos específicos de transacción
sui client events --tx-digest <TRANSACTION_DIGEST>
```

### 2. Inspeccionar Objetos

```bash
# Ver detalles de la DAO
sui client object $DAO_ID

# Ver detalles de propuesta
sui client object $PROPOSAL_ID

# Ver objetos owned por tu dirección
sui client objects
```

### 3. Verificar Transacciones

```bash
# Ver transacciones recientes
sui client transactions

# Ver detalles de transacción específica
sui client transaction <TRANSACTION_DIGEST>
```

## Casos de Prueba Recomendados

### 1. Flujo Completo Básico

```bash
# Script para testing completo
#!/bin/bash

# Variables
PACKAGE_ID="0x..."
DAO_NAME="DAO Testnet $(date +%s)"
DAO_DESC="DAO creada para testing automatizado"

echo "=== Creando DAO ==="
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "\"$DAO_NAME\"" "\"$DAO_DESC\"" \
  --gas-budget 20000000

echo "=== Verificar creación ==="
sui client objects --owned-by $(sui client active-address)
```

### 2. Testing de Errores

```bash
# Probar con gas insuficiente
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "\"DAO Error\"" "\"Testing error\"" \
  --gas-budget 1000

# Probar con parámetros inválidos
sui client call \
  --package $PACKAGE_ID \
  --module proposal \
  --function create_proposal \
  --args "0x0" "\"\"" "\"\"" 0 \
  --gas-budget 10000000
```

### 3. Testing de Performance

```bash
# Medir tiempo de ejecución
time sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "\"Performance Test\"" "\"Midiendo performance\"" \
  --gas-budget 20000000
```

## Troubleshooting

### Errores Comunes

1. **"Package not found"**
   ```bash
   # Verificar que el Package ID es correcto
   sui client object <PACKAGE_ID>
   ```

2. **"Insufficient gas"**
   ```bash
   # Obtener más gas del faucet
   sui client faucet
   
   # Incrementar gas-budget
   --gas-budget 50000000
   ```

3. **"Object not found"**
   ```bash
   # Verificar ownership
   sui client objects
   
   # Verificar que el objeto existe
   sui client object <OBJECT_ID>
   ```

### Debugging Avanzado

```bash
# Ver logs detallados
sui client call --help

# Usar dry-run para testing sin gas
sui client call --dry-run \
  --package $PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "\"Test\"" "\"Test\"" \
  --gas-budget 20000000

# Verificar estado de red
sui client chain-id
```

## Limpieza y Reset

### Limpiar Objetos de Testing

```bash
# Ver todos los objetos
sui client objects

# Los objetos shared no se pueden eliminar
# Los objetos owned se pueden transferir o destruir según la lógica del contrato
```

### Reset de Environment

```bash
# Cambiar a nuevo environment si es necesario
sui client new-env --alias testnet-fresh --rpc https://fullnode.testnet.sui.io:443
sui client switch --env testnet-fresh

# Solicitar nuevo gas
sui client faucet
```

## Automatización

### Script de Deployment Automatizado

```bash
#!/bin/bash
# deploy-testnet.sh

set -e

echo "=== Configurando Testnet ==="
sui client switch --env testnet

echo "=== Obteniendo Gas ==="
sui client faucet

echo "=== Building y Testing ==="
cd contracts
sui move test
sui move build

echo "=== Deploying ==="
DEPLOY_OUTPUT=$(sui client publish --gas-budget 100000000)
echo "$DEPLOY_OUTPUT"

# Extraer Package ID (esto requiere parsing del output)
PACKAGE_ID=$(echo "$DEPLOY_OUTPUT" | grep "Package ID" | cut -d' ' -f3)
echo "Package ID: $PACKAGE_ID"

echo "=== Testing Básico ==="
sui client call \
  --package $PACKAGE_ID \
  --module dao \
  --function create_dao \
  --args "\"Auto Deploy DAO\"" "\"DAO creada automáticamente\"" \
  --gas-budget 20000000

echo "=== Deployment Completado ==="
```

### Hacer el Script Ejecutable

```bash
chmod +x deploy-testnet.sh
./deploy-testnet.sh
```

## Próximos Pasos

Después de un deployment exitoso en testnet:

1. **Documentar resultados**: Guardar Package IDs y Object IDs importantes
2. **Probar edge cases**: Casos límite y condiciones de error
3. **Performance testing**: Medir gas usage y tiempos de respuesta
4. **Preparar mainnet**: Usar la experiencia de testnet para planificar mainnet
5. **Actualizar documentación**: Reflejar cualquier cambio necesario

---

**Nota**: Testnet se resetea periódicamente, así que no uses testnet para almacenar datos importantes a largo plazo.
