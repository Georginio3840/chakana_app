# 🍽️ Restaurante App

Una aplicación Flutter moderna para gestionar platos y órdenes de un restaurante, con base de datos SQLite local.

## ✨ Características

### 📋 Gestión de Órdenes
- **Crear órdenes**: Selecciona platos y cantidades
- **Ver historial**: Lista todas las órdenes con su estado
- **Cambiar estados**: Alterna entre "En Preparación" y "Entregado"
- **Cálculo automático**: Total automático basado en platos seleccionados
- **Detalles completos**: Vista detallada de cada orden

### 🍕 Gestión de Platos
- **Agregar platos**: Nombre y precio
- **Editar platos**: Actualiza información existente
- **Eliminar platos**: Con confirmación de seguridad
- **Búsqueda**: Encuentra platos rápidamente
- **Validación**: Controles de entrada de datos

### 💾 Base de Datos Local
- **SQLite**: Almacenamiento local persistente
- **Relaciones**: Órdenes con múltiples platos
- **Transacciones**: Operaciones seguras
- **Migración**: Actualización automática de esquema

## 🚀 Tecnologías

- **Flutter**: Framework multiplataforma
- **SQLite**: Base de datos local (`sqflite`)
- **Material Design 3**: UI moderna
- **Dart**: Lenguaje de programación

## 📱 Pantallas

1. **🏠 Inicio**: Navegación principal con tabs
2. **📜 Órdenes**: Lista y gestión de órdenes
3. **➕ Nueva Orden**: Selección de platos
4. **🔍 Detalle Orden**: Vista completa de una orden
5. **🍽️ Platos**: Gestión del menú
6. **📝 Agregar Plato**: Formulario de platos

## 🎨 Diseño

- **Colores**: Esquema Deep Orange
- **Tarjetas**: Bordes redondeados y elevación
- **Iconografía**: Material Icons
- **Estados visuales**: Chips de color para estados
- **Responsive**: Adaptativo a diferentes tamaños

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── models/                      # Modelos de datos
│   ├── plato.dart              # Modelo Plato
│   └── orden.dart              # Modelo Orden y PlatoOrden
├── database/                    # Capa de datos
│   └── database_helper.dart    # Helper SQLite
└── screens/                     # Pantallas
    ├── home_screen.dart        # Pantalla principal
    ├── ordenes_screen.dart     # Lista de órdenes
    ├── crear_orden_screen.dart # Crear nueva orden
    ├── detalle_orden_screen.dart # Detalle de orden
    ├── platos_screen.dart      # Lista de platos
    └── agregar_plato_screen.dart # Agregar/editar plato
```

## 📋 Instalación y Uso

1. **Instala dependencias**
   ```bash
   flutter pub get
   ```

2. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

## 📖 Cómo Usar

### Gestionar Platos
1. Ve a la pestaña "Platos"
2. Toca ➕ para agregar un nuevo plato
3. Completa nombre y precio
4. Edita o elimina platos existentes

### Crear Órdenes
1. Ve a la pestaña "Órdenes"
2. Toca ➕ para nueva orden
3. Selecciona platos y cantidades
4. Confirma la orden

### Gestionar Estados
1. En la lista de órdenes, toca el ícono de estado
2. O entra al detalle y cambia el estado
3. Estados: 🟠 En Preparación → 🟢 Entregado
