# SafeCity 🛡️

App móvil para monitoreo de densidad poblacional y alertas ciudadanas en Bogotá.

---

## Estructura del proyecto

```
safecity/
├── lib/
│   ├── main.dart                    # Entry point + rutas
│   ├── core/
│   │   ├── theme.dart               # Paleta de colores y tema oscuro
│   │   └── constants.dart           # API keys, URLs, constantes
│   ├── models/
│   │   └── alert_model.dart         # Modelo de alerta + enum Severity
│   ├── screens/
│   │   ├── login_screen.dart        # Pantalla de login
│   │   ├── map_screen.dart          # Mapa principal con marcadores
│   │   ├── alerts_screen.dart       # Feed de alertas activas
│   │   ├── report_screen.dart       # Formulario de reporte
│   │   └── search_screen.dart       # Buscador de ubicaciones
│   ├── widgets/
│   │   ├── bottom_nav.dart          # Barra de navegación inferior
│   │   └── alert_card.dart          # Tarjeta de alerta
│   └── services/
│       ├── firebase_service.dart    # Auth con Firebase
│       └── api_service.dart         # Comunicación con backend Flask
├── backend/
│   ├── app.py                       # API Flask (densidad poblacional)
│   └── requirements.txt
└── pubspec.yaml
```

---

## Configuración paso a paso

### 1. Firebase

1. Crear proyecto en [Firebase Console](https://console.firebase.google.com)
2. Habilitar **Authentication** (Email/Password)
3. Crear base de datos **Firestore** en modo producción
4. Descargar `google-services.json` → colocar en `android/app/`
5. Descargar `GoogleService-Info.plist` → colocar en `ios/Runner/`

#### Reglas de Firestore recomendadas:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /alerts/{alertId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

### 2. Google Maps

1. Obtener API Key en [Google Cloud Console](https://console.cloud.google.com)
2. Habilitar: **Maps SDK for Android**, **Maps SDK for iOS**
3. En `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="TU_API_KEY"/>
```
4. En `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("TU_API_KEY")
```
5. Actualizar `lib/core/constants.dart` con tu API Key

### 3. Flutter

```bash
flutter pub get
flutter run
```

### 4. Backend Flask

```bash
cd backend
pip install -r requirements.txt
python app.py
# Producción:
# gunicorn app:app --bind 0.0.0.0:5000
```

Actualizar `backendBaseUrl` en `lib/core/constants.dart` con la IP de tu servidor.

---

## Endpoints del Backend

| Método | Endpoint          | Descripción                              |
|--------|-------------------|------------------------------------------|
| POST   | `/ping`           | Registra ubicación activa del usuario    |
| GET    | `/density`        | Densidad en un radio (lat, lng, radius)  |
| GET    | `/density/heatmap`| Todos los puntos activos para heatmap    |
| GET    | `/health`         | Estado del servidor                      |

---

## Colección Firestore: `alerts`

```json
{
  "type": "Robo",
  "description": "Descripción del incidente",
  "location": "Ubicación actual",
  "severity": "high",
  "coordinates": { "lat": 4.6097, "lng": -74.0817 },
  "timestamp": "2024-01-01T12:00:00Z",
  "userId": "uid_del_usuario",
  "imageUrl": null
}
```

---

## Stack tecnológico

- **Frontend**: Flutter (Dart) + google_maps_flutter + firebase_auth + cloud_firestore
- **Backend**: Flask (Python) + flask-cors
- **Base de datos**: Firebase Firestore
- **Autenticación**: Firebase Authentication
- **Mapas**: Google Maps API
