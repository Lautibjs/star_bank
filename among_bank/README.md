# 🏦 Among Bank — Instrucciones de Setup

## Usuarios privilegiados (ya creados automáticamente)
| Usuario | Contraseña | Rol |
|---|---|---|
| LautaroPRIV | Admin2026#SuperSeguro | 👑 Super Admin |
| Itzel | Itzel2026#Lider | ⭐ Líder Supremo |

## Cómo correr en Codespace

```bash
# 1. Copiá esta carpeta a tu proyecto Flutter existente O usala como base
# 2. Asegurate de estar en la carpeta del proyecto
cd among_bank

# 3. Obtener dependencias
flutter pub get

# 4. Correr en web-server
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

## Reglas de Firestore (Firebase Console → Firestore → Reglas)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## Estructura del proyecto
```
lib/
  main.dart                    ← Entry point con Firebase init
  firebase_options.dart        ← Credenciales reales
  models/
    user_model.dart            ← Modelo de usuario con roles
    transaction_model.dart     ← Modelo de transacciones
  services/
    app_state.dart             ← Estado central (ChangeNotifier)
    firebase_service.dart      ← Todas las operaciones Firestore
  screens/
    splash_screen.dart
    login_screen.dart
    home_screen.dart
    transfer_screen.dart
    store_screen.dart          ← Cajas + Premios + Premio Supremo
    loans_screen.dart
    savings_screen.dart
    achievements_screen.dart
    bonuses_screen.dart
    notifications_screen.dart
    nova_screen.dart           ← Chatbot
    admin_screen.dart          ← Panel admin completo
  widgets/
    theme.dart                 ← Colores, botones, helpers
```

## Sistema de roles y permisos
| Rol | Crear usuarios | Cargar SC | Ver admin | Suspender | Eliminar | Recargar banco |
|---|---|---|---|---|---|---|
| super_admin (Lautaro) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| lider_supremo (Itzel) | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| colider | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ |
| admin_elite | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ |
| admin | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| tripulante | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
