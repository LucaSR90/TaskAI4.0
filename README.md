# TaskAI v4.0

Aplicación Flutter de gestión de tareas con Material Design 3, Riverpod y go_router.

## Requisitos

- Flutter **3.38+** y Dart **3.x**
- Android Studio / VS Code con extensiones de Flutter, o Cursor con SDK configurado

## Estructura del proyecto

```
lib/
├── models/          # Task, TaskCategory, TaskPriority
├── providers/       # Estado (tareas, tema, ajustes)
├── router/          # go_router + ShellRoute (barra inferior)
├── screens/         # Home, Voz, Detalle, Perfil
├── theme/           # AppTheme (MD3 oscuro/claro)
├── widgets/         # Componentes reutilizables
└── main.dart
```

## Cómo ejecutar

1. **Instalar Flutter** (si no está en PATH): [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

2. Abrir terminal en la carpeta del proyecto:

```bash
cd "ubicacion del programa"
```

3. Si faltan carpetas `android/` e `ios/`, generar el proyecto de plataforma:

```bash
flutter create . --project-name taskai
```

4. Instalar dependencias y ejecutar:

```bash
flutter pub get
flutter run
```

5. Para un dispositivo concreto:

```bash
flutter devices
flutter run -d chrome
# o: flutter run -d windows
```

## Funcionalidades v1.0

- Lista de tareas con filtros (Todas, Trabajo, Personal, Urgente)
- Swipe para eliminar, tap para editar, checkbox para completar
- Crear/editar tarea con fecha, hora, prioridad y categoría
- Pantalla de voz (solo UI + onda animada)
- Perfil con estadísticas dinámicas y toggle de modo oscuro
- Persistencia **en memoria** (Riverpod)

## Dependencias principales

- `flutter_riverpod`
- `go_router`
- `intl`
- `uuid`
