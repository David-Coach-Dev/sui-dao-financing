```bash
sui-dao-financing/
├── README.md                          # Descripción principal del proyecto
├── LICENSE                            # Licencia del proyecto
├── .gitignore                        # Archivos a ignorar
│
├── 📚 docs/                          # Documentación del proyecto
│   ├── README.md                     # Índice de documentación
│   ├── project-overview.md           # Resumen del proyecto
│   ├── technical-specs.md            # Especificaciones técnicas
│   ├── deployment-guide.md           # Guía de despliegue
│   └── api-reference.md              # Referencia de funciones
│
├── 📖 learning-notes/                # Notas del proceso de aprendizaje
│   ├── README.md                     # Índice de notas
│   ├── 01-move-concepts.md           # Conceptos básicos de Move
│   ├── 02-sui-objects.md             # Objetos en Sui
│   ├── 03-dao-architecture.md        # Arquitectura de la DAO
│   ├── 04-implementation-log.md      # Log del proceso de desarrollo
│   └── resources.md                  # Enlaces y recursos útiles
│
├── 🔧 contracts/                     # Código Move del smart contract
│   ├── Move.toml                     # Configuración del paquete Move
│   ├── sources/                      # Código fuente
│   │   ├── dao.move                  # Contrato principal de la DAO
│   │   ├── proposal.move             # Lógica de propuestas
│   │   ├── governance.move           # Tokens de gobernanza
│   │   └── voting.move               # Sistema de votación
│   └── tests/                        # Tests del contrato
│       ├── dao_tests.move
│       ├── proposal_tests.move
│       └── integration_tests.move
│
├── 📋 examples/                      # Ejemplos de uso
│   ├── create-dao.md                 # Cómo crear una DAO
│   ├── submit-proposal.md            # Cómo enviar propuesta
│   ├── voting-example.md             # Cómo votar
│   └── execute-proposal.md           # Cómo ejecutar propuesta
│
└── 🚀 deployment/                    # Scripts y configuración de despliegue
    ├── mainnet-deploy.md             # Instrucciones para mainnet
    ├── testnet-deploy.md             # Instrucciones para testnet
    └── deployment-log.md             # Registro de despliegues
```