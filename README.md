# QuoteCraft 💼⚡
> **Offline Commercial Quotation & Proposal Engine for Web Freelancers and Digital Agencies**

QuoteCraft is a production-grade Flutter application built for Android that operates **100% offline with zero cloud dependency**. It solves the critical pricing dilemma for web developers, founders, and consultants: quoting too high loses lucrative deals, while quoting too low causes project burnout and financial loss.

QuoteCraft calculates the exact commercial **"Sweet Spot"** price, prevents under-pricing via a built-in **Safety Floor guard**, computes 3-tier proposals, generates itemized **A4 PDF proposals** on-device, and drafts formatted **WhatsApp/Email proposals** in one tap.

---

## 📱 Core Features

1. **Intelligent Dynamic Pricing Engine**:
   - **Baseline Anchor**: Configurable base project rate (default: ₹15,000 INR).
   - **Multi-Currency Engine**: Instant live calculation in **INR (₹)**, **USD ($)**, **EUR (€)**, **GBP (£)**, and **AED (AED)**.
   - **Architecture Category Multipliers**: Landing Page (`1.0x`), Corporate Business (`1.4x`), E-Commerce Store (`2.2x`), Custom Web App / SaaS MVP (`2.8x`), Blog/Media (`1.2x`).
   - **Page Scaling**: Non-linear scaling based on a 5-page standard (discount for single-page landing, incremental rate for extra pages).
   - **Add-on Feature Matrix**: 8 standard commercial deliverables (SEO, Mobile Responsive UX, WhatsApp Lead Bot, Payment Gateways, Speed Optimization, Admin Dashboards, SSL/Security, 30-Day Warranty).
   - **Client Sensitivity (Win-Rate Guard)**: Competitive (`0.88x`), Balanced (`1.0x`), and Premium (`1.25x`).
   - **Delivery Urgency Surcharges**: Standard, Rush (`+25%`), and Flexible (`-5%`).
   - **3-Tier Commercial Packages**: Automatically outputs **Essential (80% floor)**, **Professional (100% recommended)**, and **Enterprise (132% upsell)**.

2. **Client Deliverables**:
   - **Offline A4 PDF Proposal**: Multi-section executive document with agency letterhead, validity date, client box, itemized deliverables table, payment milestones (40/40/20), and authorized founder signoff.
   - **One-Tap WhatsApp Pitch**: Pre-formatted, high-conversion WhatsApp text with emojis, delivery timeline, package options, and payment terms.

3. **100% Offline Storage**:
   - Agency settings (agency name, founder name, tagline, base rate, default currency) persisted in `shared_preferences`.
   - Quote history with search, deletion, review, and re-export capabilities.

---

## 🛠️ Project Structure

```
quotecraft/
├── .github/
│   └── workflows/
│       └── build_apk.yml       # Cloud GitHub Actions workflow to build release APK
├── android/                    # Android host runner & manifests
│   └── app/src/main/
│       └── AndroidManifest.xml # WhatsApp package queries & permissions
├── lib/
│   ├── models/
│   │   ├── quote_model.dart    # Categories, Add-ons, Urgency & Quote calculations
│   │   └── settings_model.dart # Agency letterhead & Currency models
│   ├── services/
│   │   ├── pricing_engine.dart # Core math & dynamic pricing logic
│   │   ├── storage_service.dart# Local offline SharedPreferences persistence
│   │   ├── pdf_service.dart    # Multi-page A4 PDF rendering & printing
│   │   └── sharing_service.dart# WhatsApp intent launcher & share sheet
│   ├── theme/
│   │   └── app_theme.dart      # Material 3 Sky Blue (#0284C7) & Emerald (#10B981)
│   ├── screens/
│   │   ├── main_navigation_screen.dart # Bottom navigation bar
│   │   ├── generator_screen.dart       # Screen 1: Real-time Quote Generator
│   │   ├── history_screen.dart         # Screen 2: Saved Quotes History
│   │   └── settings_screen.dart        # Screen 3: Agency & Pricing Settings
│   └── main.dart
└── pubspec.yaml
```

---

## 🚀 How to Run & Build

### Option A: Cloud CI/CD (No Android Studio Needed)
Push this repository to GitHub on `main` or `master` branch. The pre-configured GitHub Actions workflow (`.github/workflows/build_apk.yml`) will automatically:
1. Set up Java 17 and Flutter stable.
2. Fetch dependencies.
3. Build `QuoteCraft-Release-APK` (`app-release.apk`).
4. Upload it to GitHub Actions Artifacts for one-click download.

### Option B: Local Development
Ensure Flutter 3.x is installed:
```bash
cd quotecraft
flutter pub get
flutter run
```

To build a release APK locally:
```bash
flutter build apk --release
```
The output APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.
