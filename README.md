# Expensio – Expense Tracker

Expensio is a modern Flutter expense tracker built for simple and efficient personal finance management. It uses Firebase for authentication and cloud storage, with Provider for state management.

## ✨ Features

* Google Sign-In authentication
* Persistent onboarding experience
* Google profile information
* Add, edit, delete, and view expenses
* Expense categories and notes
* Monthly expense summary
* Category spending chart
* Search and filter by category/date
* Dark, Light, and System themes
* Currency selection
* User-scoped Firestore data

## 🏗️ Architecture

The project follows a clean, modular structure:

```text
lib/
├── app/
├── core/
├── data/
├── features/
└── providers/
```

Application flow:

```text
UI → Provider → Repository → Service → Firebase
```

## 🛠️ Tech Stack

* Flutter & Dart
* Firebase Authentication
* Cloud Firestore
* Google Sign-In
* Provider
* GoRouter
* SharedPreferences
* fl_chart
* intl

## 🚀 Setup

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Firebase configuration is handled using FlutterFire.

## 📦 Build APK

```bash
flutter build apk --release
```

APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 🎥 Demo

**Demo:** Add Google Drive / YouTube link

## 🤖 AI Tools

* ChatGPT
* Google Antigravity

AI tools were used for architecture planning, UI implementation, Firebase integration, debugging, code review, testing guidance, and documentation. All generated suggestions were reviewed and validated manually.

## 🌿 Git Workflow

Git was used for version control with meaningful commits and feature-based branches for substantial changes. Small related changes were kept together to avoid unnecessary branches.

## 📄 License

Developed as part of the **CyphLab Flutter Developer Internship practical task**.
