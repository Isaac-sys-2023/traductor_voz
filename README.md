# traductor_voz

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
#Traductor de Voz a Voz

# Estructura de Archivos inicial
```plaintext
/lib
│
├── main.dart                     # Punto de entrada de la app
├── app/
│   ├── app.dart                  # Configuración principal de la app (rutas, tema)
│   └── routes.dart               # Definición de rutas nombradas
│
├── core/
│   ├── services/                 # Servicios generales (APIs de Google, Firebase, etc.)
│   ├── utils/                    # Funciones utilitarias, helpers
│   ├── constants/                # Constantes como idiomas, colores, keys
│   └── models/                   # Clases de modelo (User, TranslationData, etc.)
│
├── data/
│   ├── datasources/             # Fuente de datos (APIs, Firebase, local)
│   └── repositories/            # Repositorios que combinan lógica de negocio y datos
│
├── presentation/
│   ├── screens/
│   │   └── home/
│   │       ├── home_screen.dart
│   │       ├── home_viewmodel.dart
│   │       └── widgets/
│   └── shared/                  # Componentes reutilizables
│
├── state/
│   └── app_state.dart           # Control global del estado (provider o riverpod)
│
├── l10n/                         # Archivos para internacionalización si lo necesitas
└── test/                         # Carpeta de pruebas unitarias y de integración
```