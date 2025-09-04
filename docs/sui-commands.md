# Sui DAO Financing - Comandos y Configuraciones

## Comandos Básicos de Sui Move

### Testing
sui move test                    # Ejecutar todos los tests
sui move test --filter dao       # Ejecutar tests específicos
sui move test --coverage        # Ejecutar con cobertura

### Build
sui move build                   # Compilar el proyecto
sui move build --skip-fetch-latest-git-deps  # Build sin actualizar dependencias

### Deployment
sui client publish .             # Publicar en mainnet
sui client publish --gas-budget 30000000 .  # Con presupuesto de gas específico

### Red de Desarrollo
sui start                        # Iniciar red local
sui client envs                  # Ver entornos configurados
sui client active-env            # Ver entorno activo
sui client switch --env testnet  # Cambiar a testnet

## Configuración del Proyecto

### Move.toml
[package]
name = "dao_financing"
version = "1.0.0"
edition = "2024.beta"

[dependencies]
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/testnet" }

[addresses]
dao_financing = "0x0"

### Estructura de Archivos
contracts/
├── Move.toml
├── sources/
│   ├── dao.move
│   ├── proposal.move
│   ├── governance.move
│   └── voting.move
└── tests/
    ├── dao_tests.move
    ├── proposal_tests.move
    ├── governance_tests.move
    ├── voting_tests.move
    └── integration_tests.move

## Estado Actual del Proyecto
- ✅ 34/34 tests pasando
- ✅ 4 módulos principales funcionando
- ✅ Sistema de governance tokens implementado
- ✅ Propuestas de financiamiento funcionales
- ✅ Sistema de votación modular

## Comandos Útiles para Desarrollo

### Verificar Estado
git status                       # Estado de git
sui --version                    # Versión de Sui
sui move --help                  # Ayuda de comandos Move

### Debugging
sui move test --verbose          # Tests con output detallado
sui move build --lint            # Build con linting

### Limpieza
rm -rf contracts/build/          # Limpiar build cache
git clean -fd                    # Limpiar archivos no tracked

## URLs Útiles
- Sui Explorer: https://explorer.sui.io/
- Sui Documentation: https://docs.sui.io/
- Move Language: https://move-book.com/
- Framework Source: https://github.com/MystenLabs/sui

## Notas de Desarrollo
- Usar test_scenario para tests complejos
- Implementar entry functions para interacción externa
- Validar permisos en todas las funciones públicas
- Documentar módulos con comentarios /// 
