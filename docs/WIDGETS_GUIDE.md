# 🎨 Guía de Widgets y Responsive - GeoKids

Sistema de widgets reutilizables y manejo responsivo para el proyecto.

---

## 📐 Clase Responsive (Mejorada)

### Características:

- ✅ **Breakpoints**: `isMobile`, `isTablet`, `isDesktop`
- ✅ **Orientación**: `isPortrait`, `isLandscape`
- ✅ **Métodos helper**: `wp()`, `hp()`, `dp()`
- ✅ **Extensión en BuildContext**: `context.responsive`

### Uso Básico:

```dart
// Opción 1: Factory pattern (original)
final responsive = Responsive.of(context);

// Opción 2: Extension (nuevo - más corto)
final r = context.responsive;

// Ejemplos de uso:
Container(
  width: r.wp(80),        // 80% del ancho
  height: r.hp(40),       // 40% del alto
  padding: EdgeInsets.all(r.wp(4)),  // 4% del ancho
  child: Text(
    'Hola',
    style: TextStyle(fontSize: r.dp(2)), // 2% de diagonal
  ),
);

// Detectar dispositivo
if (r.isMobile) {
  // Layout para móvil
} else if (r.isTablet) {
  // Layout para tablet (como las del colegio)
} else {
  // Layout para desktop
}

// Detectar orientación
if (r.isPortrait) {
  // Layout vertical
} else {
  // Layout horizontal
}
```

---

## 🧩 Widgets Reutilizables

### 1. GeofenceScaffold

Scaffold base con AppBar personalizable y toggle de tema integrado.

```dart
GeofenceScaffold(
  title: 'Mis Hijos',
  showThemeToggle: true,  // Muestra botón de tema claro/oscuro
  actions: [
    IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () {},
    ),
  ],
  body: Column(
    children: [
      // Tu contenido
    ],
  ),
  bottomNavigationBar: BottomNavigationBar(...),
);
```

### 2. GeofenceCard

Card responsiva con bordes redondeados y padding automático.

```dart
GeofenceCard(
  onTap: () {
    // Acción al hacer tap
  },
  child: Column(
    children: [
      Text('Contenido de la card'),
      // Más widgets...
    ],
  ),
);

// Card personalizada
GeofenceCard(
  elevation: 4,
  color: Colors.blue.shade50,
  padding: EdgeInsets.all(context.responsive.wp(6)),
  child: Text('Card custom'),
);
```

### 3. GeofenceButton

Botón responsivo con loading state y soporte para iconos.

```dart
// Botón básico (full width por defecto)
GeofenceButton(
  text: 'Iniciar Sesión',
  onPressed: () {
    // Acción
  },
);

// Botón con icono
GeofenceButton(
  text: 'Ver Mapa',
  icon: Icons.map,
  onPressed: () {},
);

// Botón con loading
GeofenceButton(
  text: 'Guardando...',
  isLoading: true,
  onPressed: null,
);

// Botón sin full width
GeofenceButton(
  text: 'Cancelar',
  isFullWidth: false,
  onPressed: () {},
);

// Botón con color personalizado
GeofenceButton(
  text: 'Alerta',
  backgroundColor: Colors.red,
  onPressed: () {},
);
```

### 4. GeofenceTextField

Input field con estilo consistente y validación.

```dart
GeofenceTextField(
  controller: _emailController,
  labelText: 'Correo electrónico',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Campo requerido';
    }
    return null;
  },
);

// Password field
GeofenceTextField(
  controller: _passwordController,
  labelText: 'Contraseña',
  obscureText: true,
  prefixIcon: Icons.lock,
  suffixIcon: IconButton(
    icon: Icon(Icons.visibility),
    onPressed: () {
      // Toggle visibility
    },
  ),
);
```

### 5. StatusBadge

Badge para mostrar estado dentro/fuera del geofence.

```dart
// Badge de "dentro"
StatusBadge(isInside: true);

// Badge de "fuera"
StatusBadge(isInside: false);

// Badge con texto personalizado
StatusBadge(
  isInside: true,
  text: 'En la escuela',
);
```

---

## 🎯 Ejemplo Completo: Pantalla de Login Responsiva

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/geofence_widgets.dart';
import '../../../shared/utils/responsive.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const String name = 'login';
  
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return GeofenceScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(r.wp(6)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo o icono
                Icon(
                  Icons.location_on,
                  size: r.dp(10),
                  color: Theme.of(context).primaryColor,
                ),
                
                SizedBox(height: r.hp(3)),
                
                Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: r.dp(3.5),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: r.hp(5)),
                
                // Email
                GeofenceTextField(
                  controller: _emailController,
                  labelText: 'Correo',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu correo';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: r.hp(2)),
                
                // Password
                GeofenceTextField(
                  controller: _passwordController,
                  labelText: 'Contraseña',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: r.hp(4)),
                
                // Botón de login
                GeofenceButton(
                  text: 'Iniciar Sesión',
                  isLoading: _isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Login logic
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 🏠 Ejemplo: Lista de Hijos con Cards

```dart
ListView.builder(
  padding: EdgeInsets.all(context.responsive.wp(4)),
  itemCount: children.length,
  itemBuilder: (context, index) {
    final child = children[index];
    
    return GeofenceCard(
      onTap: () {
        // Ver detalles del hijo
      },
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: context.responsive.dp(3),
            child: Text(child.name[0]),
          ),
          
          SizedBox(width: context.responsive.wp(3)),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: TextStyle(
                    fontSize: context.responsive.dp(2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.responsive.hp(0.5)),
                StatusBadge(isInside: child.isInside),
              ],
            ),
          ),
          
          // Batería
          Column(
            children: [
              Icon(
                Icons.battery_std,
                color: child.battery > 20 ? Colors.green : Colors.red,
              ),
              Text('${child.battery}%'),
            ],
          ),
        ],
      ),
    );
  },
);
```

---

## 💡 Tips de Uso

### 1. Layouts Adaptativos Móvil/Tablet

```dart
Widget build(BuildContext context) {
  final r = context.responsive;
  
  return r.isMobile
      ? _buildMobileLayout()
      : _buildTabletLayout();
}
```

### 2. Tamaños de Fuente Responsivos

```dart
Text(
  'Título',
  style: TextStyle(
    fontSize: context.responsive.dp(2.5), // 2.5% de diagonal
  ),
)
```

### 3. Espaciado Consistente

```dart
Column(
  children: [
    Widget1(),
    SizedBox(height: context.responsive.hp(2)), // 2% de altura
    Widget2(),
  ],
)
```

### 4. Cards con Ancho Máximo en Tablets

```dart
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: context.responsive.isTablet ? 600 : double.infinity,
    ),
    child: GeofenceCard(...),
  ),
)
```

---

## ✨ Beneficios

1. **Código más limpio**: Widgets reutilizables reducen duplicación
2. **UI consistente**: Mismo estilo en toda la app
3. **Responsivo automático**: Se adapta a móvil, tablet y desktop
4. **Mantenible**: Cambios en un lugar afectan toda la app
5. **Legible**: `context.responsive.wp(80)` es más claro que cálculos manuales

---

¡Con esto tu app está lista para verse increíble en cualquier dispositivo! 🚀📱💻
