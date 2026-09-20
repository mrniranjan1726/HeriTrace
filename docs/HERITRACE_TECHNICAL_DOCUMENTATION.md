# 🏛️ HeriTrace: Technical Architecture & System Documentation

**Project Title**: HeriTrace — AI-Powered Digital Business Manager & Marketplace for Artisans  
**Repository**: [https://github.com/mrniranjan1726/HeriTrace](https://github.com/mrniranjan1726/HeriTrace)  
**Live Web Application**: [https://heritrace.web.app](https://heritrace.web.app)  
**Production AI Microservice**: [https://heritrace-api.onrender.com](https://heritrace-api.onrender.com)  
**Release APK**: `d:\HeriTrace_Real_MVP\HeriTrace_Release.apk`  

---

## 1. Executive Summary & Problem Statement

India is home to over 7 million traditional artisans and hundreds of Geographical Indication (GI) protected crafts. Despite immense cultural and commercial value, the traditional artisan sector faces critical systemic bottlenecks:
1. **Middlemen Exploitation**: Intermediaries often pocket 50%–80% of consumer retail value, leaving generational master craftspeople with sub-living wages.
2. **Digital Literacy Barrier**: Mainstream e-commerce portals (Amazon, Flipkart) require complex text-heavy cataloging, SKU management, and technical logistics beyond the digital literacy of rural makers.
3. **Studio Photography Deficit**: Raw smartphone photos taken in village workshops have poor lighting and cluttered backgrounds, reducing customer purchase confidence.
4. **Counterfeiting & Trust Deficit**: Industrial machine-made replicas flood the market, eroding consumer trust in handmade authenticity.

**The HeriTrace Solution**:  
HeriTrace is an artisan-first ecosystem combining **voice-driven multimodal AI**, **computer vision photo cleanup**, **transparent living wage pricing**, **real-time live auctions**, and **direct loom-to-doorstep traceability** with a **7-day guarantee lifecycle**.

---

## 2. High-Level System Architecture

HeriTrace uses a **Decoupled 3-Tier Reactive Architecture**:

```
[ Tier 1: Client Application ]
Flutter Native Client (Android / iOS / Web)
  ├── Artisan Atelier Portal (Voice Storyteller, AI Studio, Order Management)
  └── Customer Connoisseur Marketplace (Voice Search, Live Auctions, 7-Day Guarantee)

               │                                    │
               │ (Real-Time WebSockets)              │ (JSON REST APIs)
               ▼                                    ▼
[ Tier 2: Cloud Infrastructure ]         [ Tier 3: Python Microservice ]
Google Firebase (BaaS Core)               FastAPI on Render Container
  ├── Firebase Auth (RBAC)                 ├── Pillow Computer Vision Studio
  ├── Cloud Firestore (Reactive NoSQL)     ├── Multilingual NLP Catalog Generator
  ├── Cloud Storage (High-Res Assets)      ├── Fair Wage & Living Margin Formula
  └── Firestore Security Rules             └── Razorpay HMAC-SHA256 Verification
```

---

## 3. Technology Stack Specification

| Component | Technology | Version / Implementation | Role |
| :--- | :--- | :--- | :--- |
| **Mobile & Web UI** | Flutter / Dart | Flutter 3.x / Dart 3.8+ | Native cross-platform compilation for Android, iOS, and Web |
| **State Management** | Provider + Streams | `provider: ^6.1.5`, `ValueNotifier` | Decoupled reactive state with zero unnecessary widget rebuilds |
| **Audio & Speech** | Native Speech-to-Text | `speech_to_text: ^7.5.0` | OS-native speech recognition (`RecognitionService` on Android, Apple Speech on iOS) |
| **Cloud Database** | Google Cloud Firestore | NoSQL Real-Time Database | Sub-second WebSocket streaming via `snapshots()` and collection groups |
| **Authentication** | Firebase Auth | OAuth 2.0 / JWT | Role-Based Access Control (Artisan, Customer, Admin) |
| **Asset Storage** | Firebase Cloud Storage | Google Cloud Storage Bucket | Byte stream (`Uint8List`) uploads with public signed CDN URLs |
| **AI Microservice** | FastAPI | Python 3.11 / Uvicorn | High-performance asynchronous REST microservice |
| **Computer Vision** | Pillow (PIL) | `pillow`, `ImageOps`, `ImageEnhance` | Orientation correction, background cleanup, Lanczos downscaling, contrast normalization |
| **Payments** | Razorpay SDK & Webhooks | `razorpay_flutter`, `razorpay-py` | INR payments (UPI, Cards, NetBanking) with server-side HMAC-SHA256 signature verification |

---

## 4. Frontend Engineering & Design System

### 4.1 HeriTrace Luxury Heritage Design System
* **Royal Silk Terracotta Gradient** (`#7A2012` to `#9E341B`): Brand primary identity across headers, action buttons, and active tabs.
* **Antique Heirloom Gold** (`#D4A056`): GI verification badges, SuperCoins loyalty counters, and rating stars.
* **Artisanal Linen Surface** (`#F7F3EE` / `#FDFBF7`): Warm natural background providing high contrast for craft photography.
* **Pristine Pearl Cards** (`#FFFFFF`, border `#E8DFD3`): Clean elevated cards with subtle ambient elevation.
* **Charcoal Ink Typography** (`#1D2A24`): Crisp legibility compliant with WCAG AAA contrast standards.

### 4.2 Cross-Platform Conformance
* **Android (API 21 to 34+)**:
  * Configured `RECORD_AUDIO`, `INTERNET`, and Bluetooth permissions.
  * Declared `<action android:name="android.speech.RecognitionService" />` inside `<queries>` for Android 11+ package visibility.
* **Apple iOS (iPhone & iPad)**:
  * Configured `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`, `NSCameraUsageDescription`, and `NSPhotoLibraryUsageDescription` in `ios/Runner/Info.plist`.
  * Generated full 16-asset Apple AppIcon set from master 1024x1024 branding.

---

## 5. Backend Infrastructure & Security

### 5.1 Google Cloud Firestore Data Model
* **`users/{userId}`**: Profiles containing `uid`, `email`, `role`, contact info, and SuperCoin balances.
* **`users/{userId}/products/{productId}`**: Private artisan inventory containing craft metadata:
  * `name`, `category`, `price`, `description`, `origin`, `material`, `traditionalTechnique`, `heritageStory`, `imageUrl`.
* **`products` (Collection Group)**: Enables global multi-artisan catalog queries for the customer marketplace.
* **`auctions/{auctionId}`**: Live synchronized bidding documents tracking `startingPrice`, `currentBid`, `highestBidderUid`, `bidCount`, and `endTime`.
* **`orders/{orderId}`**: Order lifecycle records including items, totals, artisan breakdown, delivery address, and return tracking fields (`returnStatus`, `returnType`, `returnReason`).

### 5.2 Server-Side Security Rules (`firestore.rules`)
* **Atomic Bid Verification**: A bid update is permitted only if:
  1. `request.resource.data.currentBid > resource.data.currentBid` (new bid strictly exceeds prior bid).
  2. `request.resource.data.bidCount == resource.data.bidCount + 1` (guarantees single-increment atomicity).
* **Data Isolation**: Artisans have write access strictly to their own inventory under `/users/{auth.uid}/products/`.

---

## 6. Python AI & Microservices Engine (`backend/main.py`)

### 6.1 Computer Vision Studio (`/ai/enhance-image`)
1. Reads base64-encoded workshop photos.
2. Applies `ImageOps.exif_transpose` to normalize orientation metadata.
3. Separates foreground craft from noisy workshop backdrops using alpha masking and composites onto an e-commerce white background.
4. Performs Lanczos bicubic resampling (capping max dimensions at 1800px for optimal mobile delivery).
5. Normalizes histogram contrast and enhances edge sharpness.

### 6.2 Multilingual Catalog Generator (`/ai/generate-catalog`)
1. Ingests raw voice transcripts spoken by rural artisans.
2. Extracts cultural craft DNA (origin, technique, material, cultural motifs).
3. Generates structured e-commerce listings with titles, storytelling copy, and SEO keywords in **English**, **Hindi**, **Odia**, and **Bengali**.

### 6.3 Living Wage Algorithmic Pricing (`/ai/recommend-price`)
$$\text{Base Price} = \text{Raw Material Cost} \times 1.45$$
$$\text{Final Price} = \text{Base Price} \times \text{Quality Multiplier} \times \text{Demand Multiplier}$$
* Quality Multipliers: Basic (1.10x), Standard (1.35x), High (1.60x), Premium (1.90x).
* Ensures artisans retain **70%–85% direct profit margin**.

### 6.4 Cryptographic Payment Verification (`/payments/verify`)
Verifies payment signatures using server-side HMAC-SHA256:
$$\text{Signature} = \text{HMAC-SHA256}(\text{Key Secret}, \text{Order ID} \parallel "|" \parallel \text{Payment ID})$$
Validated with `hmac.compare_digest` to eliminate timing attacks.

---

## 7. Post-Purchase Trust & 7-Day Guarantee

```
[ Order Delivered ]
         │
         ▼
[ 7-Day Guarantee Window Active ]
         │
         ├── Option A: Customer Satisfied ──► Order Marked Completed
         │
         └── Option B: Issue Encountered
                   │
                   ▼
         [ Customer Requests Action ]
         ├── 1. Return (Full Refund)
         ├── 2. Exchange (Size / Color)
         └── 3. Replace (Damaged Item)
                   │
                   ▼
         [ Artisan Portal Alert ] ──► Maker reviews & approves
                   │
                   ▼
         [ Reverse Doorstep Pickup Executed ]
                   │
                   ▼
         [ Resolution: Refund Credited or Replacement Dispatched ]
```

---

## 8. Deployment & Build Artifacts

1. **Android Release APK**: `d:\HeriTrace_Real_MVP\HeriTrace_Release.apk` (59.6 MB)
2. **Live Web App**: [https://heritrace.web.app](https://heritrace.web.app)
3. **Cloud Microservice**: [https://heritrace-api.onrender.com](https://heritrace-api.onrender.com)
4. **Source Code**: [https://github.com/mrniranjan1726/HeriTrace](https://github.com/mrniranjan1726/HeriTrace)
