# 🏔️ Quetame Turismo App

[![Flutter Version](https://img.shields.io/badge/Flutter-v3.24+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-green)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Quetame Turismo** es una solución móvil avanzada diseñada para potenciar el sector turístico de Quetame, Cundinamarca. La aplicación no solo funciona como una guía, sino como un ecosistema digital que conecta a turistas con el patrimonio cultural, gastronómico y natural de la región.

---

## 🛠️ Stack Tecnológico

* **Framework:** [Flutter](https://flutter.dev/) (Multiplataforma iOS/Android).
* **Gestión de Estado:** `flutter_bloc` (BloC Pattern) para una lógica de negocio predecible y testeable.
* **Arquitectura:** Clean Architecture (Separación por capas: Data, Domain, Presentation).
* **Base de Datos Local:** `Isar` o `Hive` para soporte offline en zonas rurales.
* **Inyección de Dependencias:** `GetIt` + `Injectable`.
* **Mapas:** `Maps_flutter` con personalización de marcadores.

---

## 🏗️ Arquitectura del Proyecto

El proyecto sigue los principios de **Solid** y **Clean Architecture** para garantizar que el código sea escalable y fácil de mantener por otros ingenieros.



### Estructura de Capas:
- **Core:** Componentes transversales, temas, constantes y manejo de errores globales.
- **Domain:** La lógica más pura (Entities, Repositories Interfaces, Use Cases).
- **Data:** Implementaciones de repositorios, fuentes de datos (APIs/Firebase) y modelos (Mappers).
- **Presentation:** UI modular, Blocs y gestión de componentes atómicos (Widgets).

---

## 🚀 Características Principales (Roadmap)

- [ ] **Geolocalización en tiempo real:** Navegación guiada hacia sitios de interés.
- [ ] **Modo Offline:** Acceso a mapas e información sin necesidad de datos móviles.
- [ ] **Directorio Comercial:** Sección dedicada a la gastronomía local (puntos de arepas, piqueteaderos, etc.).
- [ ] **Soporte Multi-idioma:** Preparado para el turismo internacional.
- [ ] **Panel de Administración:** Gestión de contenidos desde la nube.

---

## 📦 Instalación y Configuración

1. **Clonar el repositorio:**
   ```bash
   git clone [https://github.com/tu-usuario/quetame_turismo.git](https://github.com/tu-usuario/quetame_turismo.git)
