# HeriTrace — AI-Powered Digital Business Platform for Artisans

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)](https://fastapi.tiangolo.com)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![GitHub Release](https://img.shields.io/badge/Release-v1.0.0-success?style=for-the-badge&logo=github)](https://github.com/mrniranjan1726/HeriTrace/releases/tag/v1.0.0)

**HeriTrace** is an AI-powered business manager, digital studio, and marketplace designed specifically for traditional craftspeople and cultural heritage artisans.

---

## 🚀 Live Deployments & Downloads

* 🌐 **Live Web Application**: [https://heritrace.web.app](https://heritrace.web.app)
* 📱 **Download Android APK**: [HeriTrace v1.0.0 APK (56.6 MB)](https://github.com/mrniranjan1726/HeriTrace/releases/download/v1.0.0/HeriTrace-v1.0.0.apk)
* ⚡ **1-Click Backend Deploy on Render**:
  
  [![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/mrniranjan1726/HeriTrace)

---

## 🌟 Key Features

1. **AI Craft Story & Multilingual Catalog Generator**: Generates engaging cultural provenance stories across multiple Indian regional languages.
2. **AI Image Enhancement Studio**: Automatic contrast, border-framing, and clarity enhancement tailored for handmade crafts.
3. **Dynamic Fair-Pricing Calculator**: Factors in artisan wages, materials, and market demand for sustainable pricing.
4. **Live Craft Auctions**: Real-time bidding on rare, one-of-a-kind handmade items.
5. **Direct Artisan-to-Consumer Marketplace**: Integrated cart, multi-address management, and Razorpay payment gateway.
6. **Support Chatbot & Admin Governance**: Verification badges, platform order monitoring, and interactive artisan help.

---

## 🛠️ Project Structure

```
├── lib/
│   ├── main.dart               # App entry point with Firebase initialization
│   ├── app.dart                # Material 3 earth-tone theme & route definitions
│   ├── models/                 # Product and Auction data models
│   ├── screens/                # Artisan, Customer, and Admin screens
│   ├── services/               # Firebase Auth/Firestore and Razorpay payment service
│   └── widgets/                # In-app Support Chatbot and reusable UI components
├── backend/
│   ├── main.py                 # FastAPI server (AI cataloging, image studio, Razorpay verification)
│   ├── requirements.txt        # Python dependencies
│   └── Dockerfile              # Container spec for cloud deployment
├── render.yaml                 # 1-click cloud deployment blueprint for Render
└── firebase.json               # Firebase Hosting and security configuration
```

---

## ⚙️ Local Development Setup

### 1. Flutter Client (Web & Mobile)
```bash
# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Build for Web
flutter build web --release

# Build Android APK
flutter build apk --release
```

### 2. FastAPI AI Backend
```bash
cd backend
python -m venv venv
venv\Scripts\activate          # On Windows
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```
