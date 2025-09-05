// Configuración de objetos Sui desplegados
export const SUI_OBJECTS = {
  // Objetos de monedas/tokens
  coins: [
    {
      objectId: "0x1521fb7afe1d0dc171c962",
      version: 349180531,
      objectType: "0x0000..0002::coin::Coin",
      description: "SUI Coin para transacciones"
    }
  ],
  
  // Capacidades de actualización
  upgradeCaps: [
    {
      objectId: "0xf17bca5583ae3f2bb6802c",
      version: 349180528,
      objectType: "0x0000..0002::package::UpgradeCap",
      description: "Capacidad de actualización del contrato principal"
    },
    {
      objectId: "0x69eb64bc9c0c7696336e56",
      version: 349180518,
      digest: "LxFMoHva6KOIFowccoAIduD46ev3P+gfgMmNtO2lg6k=",
      objectType: "0x0000..0002::package::UpgradeCap",
      description: "Capacidad de actualización secundaria"
    }
  ],

  // Otros objetos desplegados
  packages: [
    {
      objectId: "0x6bfaf6274f1eac939a7c77",
      version: 349180526,
      description: "Package del sistema DAO"
    }
  ]
};

// Configuración de red Sui
export const SUI_CONFIG = {
  network: 'devnet', // o 'testnet', 'mainnet'
  packageId: '0x69eb64bc9c0c7696336e56', // ID del package principal
  rpcUrl: 'https://fullnode.devnet.sui.io:443'
};

// IDs de los DAOs reales (estos tendrías que obtenerlos cuando crees los DAOs)
export const DAO_OBJECT_IDS = {
  'tech-dao': {
    objectId: '0x...', // ID real del DAO Tech cuando lo crees
    packageId: SUI_CONFIG.packageId
  },
  'defi-dao': {
    objectId: '0x...', // ID real del DeFi DAO cuando lo crees  
    packageId: SUI_CONFIG.packageId
  },
  'governance-dao': {
    objectId: '0x...', // ID real del Governance DAO cuando lo crees
    packageId: SUI_CONFIG.packageId
  }
};

export default {
  SUI_OBJECTS,
  SUI_CONFIG,
  DAO_OBJECT_IDS
};
