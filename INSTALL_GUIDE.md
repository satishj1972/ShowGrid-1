# ShowGrid Complete App - Installation Guide

## 📋 Complete Sitemap Implementation

### 1. APP ENTRY FLOW ✅
```
App Launch → Splash → Onboarding (3 screens) → Login/Signup → OTP → HOME
```

### 2. HOME (ROOT HUB) ✅
```
HOME (Hero Banner)
  ├── 2.1 Fortune
  ├── 2.2 Fanverse  
  └── 2.3 GridVoice

Bottom Navigation: Home | Discovery | Powerboard | Profile
```

### 2.1 FORTUNE ✅
```
Fortune → Challenge → Live/Upload
  ├── Photo Flow (Capture → Take → Review → Submit)
  ├── Video Flow (Record → Recording → Review → Submit)
  └── Upload (Gallery → Preview → Submit)
```

### 2.2 FANVERSE ✅
```
Fanverse → Challenge → Live/Upload
  ├── Photo Flow (Capture → Take → Review → Submit)
  ├── Video Flow (Record → Recording → Review → Submit)
  └── Upload (Gallery → Preview → Submit)
```

### 2.3 GRIDVOICE ✅
```
GridVoice → Challenge → Live/Upload
  ├── Audio Flow (Start → Stop → Review → Submit)
  └── Upload Flow (Upload Audio → Preview → Submit)
```

### 3. DISCOVERY ✅
```
Discovery → All Images & Videos Feed
```

### 4. POWERBOARD ✅
```
Powerboard → All Season Ranking
  By Challenge | By Category | Global | Seasonal
```

### 5. PROFILE ✅
```
Profile
  ├── My Uploads
  ├── Performance
  └── Settings
```

---

## 📁 Files Included (26 Screens)

| Feature | Screen | Route |
|---------|--------|-------|
| **Auth** | Splash | `/` |
| | Onboarding | `/onboarding` |
| | Login | `/login` |
| | OTP | `/otp` |
| **Home** | Home | `/home` |
| **Fortune** | Main | `/fortune` |
| | Challenge | `/fortune/challenge/:id` |
| | Live/Upload | `/fortune/live/:id` |
| | Photo | `/fortune/photo/:id` |
| | Video | `/fortune/video/:id` |
| | Upload | `/fortune/upload/:id` |
| **Fanverse** | Main | `/fanverse` |
| | Challenge | `/fanverse/challenge/:id` |
| | Live/Upload | `/fanverse/live/:id` |
| | Photo | `/fanverse/photo/:id` |
| | Video | `/fanverse/video/:id` |
| | Upload | `/fanverse/upload/:id` |
| **GridVoice** | Main | `/gridvoice` |
| | Challenge | `/gridvoice/challenge/:id` |
| | Live/Upload | `/gridvoice/live/:id` |
| | Audio | `/gridvoice/audio/:id` |
| | Upload | `/gridvoice/upload/:id` |
| **Discovery** | Feed | `/discover` |
| **Powerboard** | Rankings | `/powerboard` |
| **Profile** | User | `/profile` |

---

## 🚀 Installation Steps

### Step 1: Extract the Package
Extract `showgrid_complete_app.zip` to your desired location.

### Step 2: Copy to Your Project

**Option A: Fresh Project**
```bash
# Copy all contents to your Flutter project root
cp -r showgrid_complete_app/* your_project/
cd your_project
flutter pub get
flutter run -d android
```

**Option B: Existing Project**
Copy the `lib/` folder contents to your project's `lib/` folder.

### Step 3: Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### Step 4: iOS Configuration

Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>ShowGrid needs camera access to capture photos and videos</string>
<key>NSMicrophoneUsageDescription</key>
<string>ShowGrid needs microphone access to record audio</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ShowGrid needs photo library access to upload media</string>
```

### Step 5: Run the App
```bash
flutter pub get
flutter run -d android
```

---

## 🧭 App Flow

```
SPLASH (3 sec)
    ↓
ONBOARDING (3 slides)
    ↓
LOGIN / SIGNUP
    ↓
OTP VERIFICATION
    ↓
HOME ←────────────────────────────┐
  │                               │
  ├── FORTUNE ──→ Challenge ──→ Create Entry
  │                               │
  ├── FANVERSE ─→ Episode ────→ Create Entry
  │                               │
  └── GRIDVOICE ─→ Chapter ───→ Create Story
                                  │
DISCOVER ←────────────────────────┤
                                  │
POWERBOARD ←──────────────────────┤
                                  │
PROFILE ←─────────────────────────┘
```

---

## 🎨 Color Themes

| Grid | Primary | Secondary |
|------|---------|-----------|
| Fortune | Gold #FFB84D | Pink #FF4FD8 |
| Fanverse | Pink #FF4FD8 | Violet #9B7DFF |
| GridVoice | Mint #5CFFB1 | Blue #5CA8FF |

---

## ✅ Features

- [x] Complete auth flow (Splash, Onboarding, Login, OTP)
- [x] Home screen with 3 grid cards
- [x] Fortune with 6 challenges
- [x] Fanverse with 6 episodes
- [x] GridVoice with 4 chapters
- [x] Photo capture with neon corners
- [x] Video recording with timer
- [x] Audio recording with waveform
- [x] Gallery upload for all types
- [x] AI score simulation
- [x] Discovery feed
- [x] Powerboard rankings
- [x] Profile with tabs

---

**ShowGrid Complete App v1.0**
*Built for Brand Book v2.1*
