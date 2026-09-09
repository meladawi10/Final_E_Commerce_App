# NEXORA - Flutter E-Commerce App

[![Flutter](https://img.shields.io/badge/Flutter-3.38.4-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.3-blue.svg)](https://dart.dev)
[![API](https://img.shields.io/badge/API-REST-green.svg)](https://accessories-eshop.runasp.net/scalar/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

NEXORA is a state-of-the-art, production-ready E-Commerce mobile application built with **Flutter** and **Clean Architecture**. It integrates robust REST API services using **Dio** (`EcommerceApiClient`), secure local caching via `LocalPreferencesHelper`, reactive state management using **Flutter Bloc / Cubit**, and GetIt dependency injection.

---

## 🚀 Key Features & Refactoring Milestones

### **Phase 1: API Client & Local Preferences Setup**
- **`EcommerceApiClient`**: Implemented using Dio with BaseURL set to `https://accessories-eshop.runasp.net/scalar/`.
- **Global Error Handling Interceptor**: Covers HTTP status codes `400`, `401`, `403`, `404`, and `500` with descriptive human-readable messages.
- **`LocalPreferencesHelper`**: Type-safe getters and setters for `has_seen_onboarding` (`bool`), `auth_token` (`String?`), and `is_dark_mode` (`bool`).
- **Dependency Injection**: Fully registered in GetIt (`setupServiceLocator`).

### **Phase 2: Splash, Onboarding & Initial App Routing**
- **Single-Launch Onboarding**: Appears strictly on the first launch, persisting completion status.
- **Splash Screen**: Theme-aware splash screen displaying brand logos (`assets/logos/t-store-splash-logo-white.png` / `assets/logos/t-store-splash-logo-black.png`).
- **Router Logic**: Intelligently routes between Onboarding, Login, and Home (`NavigationMenu`) based on onboarding status and `auth_token`.

### **Phase 3: Authentication Feature REST Integration**
- **REST Endpoints**: Secure Login & Register integration using `EcommerceApiClient`.
- **Auth Cubit & States**: Structured around `AuthSubmitLoading`, `AuthSessionEstablished`, and `AuthFailure`.
- **Form Validation**: Robust validation for email formats and password minimum length (`TValidator`).

### **Phase 4: Product Catalog & CatalogCubit**
- **Catalog Management**: Dynamic product catalog loading, category filtering, and product CRUD actions (POST & DELETE with confirmation dialogs).
- **Domain & Data Layers**: Clean Architecture separation with `ProductEntity`, `CategoryEntity`, `ReviewEntity`, and corresponding models.

### **Phase 5: Cart, Profile & Theme Settings**
- **Shopping Cart**: REST-backed cart management supporting item addition, quantity updates, removal, and live total calculations.
- **Profile & Settings**: User profile views, theme toggle (Light/Dark mode synced with `LocalPreferencesHelper`), and static informational pages (Privacy Policy, Help Center, About Us).
- **Session Management**: Secure logout clearing persistent tokens and redirecting to Login.

### **Phase 6: Branding & Quality Assurance**
- **App Branding**: Configured app name as **"NEXORA"** across `AndroidManifest.xml` and `Info.plist`.
- **Launcher Icons**: Configured via `flutter_launcher_icons`.
- **Zero Errors**: Verified with `flutter analyze` ensuring zero static analysis errors.

---

## 📁 Clean Architecture Directory Structure

```
lib/
├── core/
│   ├── api/                           # EcommerceApiClient & Dio setup
│   ├── common/                        # Shared widgets & view models
│   ├── cubits/                        # App-wide cubits (ThemeCubit, LocaleCubit)
│   ├── dependency_injection/          # Service locator (GetIt setupServiceLocator)
│   └── utils/                         # LocalPreferencesHelper, constants, helpers, validators
│
└── features/
    ├── auth/                          # Authentication (Login, Register, Passwords)
    ├── shop/                          # Product Catalog, Categories, Banners, HomeView
    ├── cart/                          # Shopping Cart management
    └── personalization/               # User Profile, Settings, Static Info Views
```

---

## 🛠️ Setup & Installation Instructions

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/meldeeb/E_Commerce_App.git
   cd E_Commerce_App
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   Ensure your `.env` file contains the necessary configuration keys:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Run the Application:**
   ```bash
   flutter run
   ```

5. **Run Static Analysis:**
   ```bash
   flutter analyze
   ```

---

## 👥 Author & Lead Developer

**Muhammad AlDeeb**
- Full-Stack Flutter & Mobile Architect
- Focused on Clean Architecture, REST APIs, and High-Performance Mobile Apps.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
# E_Commerce_App
