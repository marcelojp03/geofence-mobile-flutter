# Instrucciones para configurar Firebase

## Paso 1: Crear proyecto en Firebase
1. Ve a https://console.firebase.google.com
2. Click "Agregar proyecto"
3. Nombre: "GeoKids" o similar
4. Desactiva Google Analytics (opcional)
5. Click "Crear proyecto"

## Paso 2: Agregar app Android
1. En el proyecto, click en el ícono de Android
2. Package name: `com.example.geofence_mobile_flutter`
3. Apodo: "GeoKids Android"
4. Click "Registrar app"
5. Descarga `google-services.json`
6. Coloca el archivo en: `android/app/google-services.json`

## Paso 3: Agregar app iOS (opcional)
1. Click en el ícono de iOS
2. Bundle ID: `com.example.geofenceMobileFlutter`
3. Descarga `GoogleService-Info.plist`
4. Coloca en: `ios/Runner/GoogleService-Info.plist`

## Paso 4: Configurar Cloud Messaging
1. En Firebase Console, ve a "Cloud Messaging"
2. Habilita Firebase Cloud Messaging
3. (Opcional) Configura la clave del servidor para el backend

## Paso 5: Probar
1. Ejecuta la app: `flutter run`
2. El token FCM se mostrará en la consola
3. Usa Firebase Console para enviar una notificación de prueba

## Formato de payload esperado del backend:
```json
{
  "notification": {
    "title": "Alerta de salida",
    "body": "Pedrito ha salido del colegio"
  },
  "data": {
    "childId": "123"
  }
}
```

Al tocar la notificación, la app navegará automáticamente a `/children/123`
