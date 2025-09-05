# Sui DAO Frontend

Frontend moderno y minimalista para interactuar con el DAO en la red Sui.

## 🚀 Tecnologías

- **React 18** con TypeScript
- **Vite** para desarrollo rápido  
- **Tailwind CSS** para estilos
- **Shadcn/ui** para componentes
- **Zustand** para manejo de estado
- **Lucide React** para iconos
- **@mysten/sui.js** para interacción con Sui
- **React Query** para fetching de datos

## ✨ Características

- 🌓 **Cambio de tema** (claro/oscuro)
- 🌍 **Soporte multiidioma** (inglés/español)
- 📱 **Diseño responsivo**
- 🔗 **Integración con Sui Testnet**
- 📊 **Dashboard con estadísticas del DAO**
- 🗳️ **Interfaz para propuestas y votación**

## 🛠️ Instalación

1. **Instalar dependencias:**
   ```bash
   cd front
   npm install
   ```

2. **Iniciar servidor de desarrollo:**
   ```bash
   npm run dev
   ```

3. **Abrir en el navegador:**
   ```
   http://localhost:3000
   ```

## 📋 Scripts disponibles

- `npm run dev` - Servidor de desarrollo
- `npm run build` - Build para producción
- `npm run preview` - Preview del build
- `npm run lint` - Linter de código

## 🔧 Configuración

### Datos del DAO
Los datos del DAO están configurados en `src/utils/sui-config.ts`:

```typescript
export const DAO_CONFIG = {
  PACKAGE_ID: '0x8d2d28a417c0faf3bc176d0972c462e14376c6ec9c446ccb818724c182545b6e',
  DAO_ID: '0xb4a0c7f7d32db18e232c3b8ad7ab77b034cc86cfa2bdcea757f40eb7e409997c',
  NETWORK: 'testnet',
  RPC_URL: 'https://fullnode.testnet.sui.io:443'
}
```

### Temas y idiomas
El estado global se maneja con Zustand en `src/store/app-store.ts`:
- **Temas**: `light` | `dark`
- **Idiomas**: `en` | `es`

## 🎨 Componentes

### Componentes UI
- `Button` - Botones con variantes
- `Card` - Tarjetas de contenido
- `DropdownMenu` - Menús desplegables

### Componentes principales
- `Header` - Barra superior con controles
- `Dashboard` - Panel principal con estadísticas
- `App` - Componente raíz

## 🌐 Enlaces útiles

- **Package v3**: [SuiVision](https://testnet.suivision.xyz/object/0x8d2d28a417c0faf3bc176d0972c462e14376c6ec9c446ccb818724c182545b6e)
- **DAO**: [SuiVision](https://testnet.suivision.xyz/object/0xb4a0c7f7d32db18e232c3b8ad7ab77b034cc86cfa2bdcea757f40eb7e409997c)
- **Sui Docs**: [https://docs.sui.io](https://docs.sui.io)

## 📁 Estructura del proyecto

```
front/
├── public/
│   └── index.html
├── src/
│   ├── components/
│   │   ├── ui/           # Componentes UI base
│   │   ├── Header.tsx    # Barra superior
│   │   └── Dashboard.tsx # Panel principal
│   ├── hooks/
│   │   └── use-translation.ts
│   ├── lib/
│   │   ├── utils.ts      # Utilidades
│   │   └── translations.ts
│   ├── store/
│   │   └── app-store.ts  # Estado global
│   ├── utils/
│   │   └── sui-config.ts # Configuración Sui
│   ├── App.tsx
│   ├── main.tsx
│   └── index.css
├── package.json
├── vite.config.ts
├── tailwind.config.js
└── tsconfig.json
```

## 🔄 Próximas funcionalidades

- [ ] Conexión de wallet
- [ ] Creación de propuestas
- [ ] Sistema de votación
- [ ] Visualización de historial
- [ ] Notificaciones en tiempo real

---

**Desarrollado para el DAO de financiamiento en Sui Testnet** 🚀
