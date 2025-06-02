# 📱 SmartCheck App

A mobile-based attendance management system using **React Native** with **facial recognition** and **geofencing (GPS)**. Built to streamline academic attendance tracking for students and lecturers.

---

## ✨ Features

- 🔐 User Registration and Login (with role-based access)
- 🧭 GPS-based geofencing to verify user location
- 📷 Facial Recognition for identity verification
- 📝 Attendance session creation and management
- 📊 Real-time dashboard and attendance history
- 📨 Leave and dispute submission
- 🔔 Push notifications using Firebase Cloud Messaging

---

## 🛠️ Tech Stack

- React Native (CLI)
- Node.js & Firebase (backend & storage)
- React Navigation
- Firebase Authentication & Firestore
- Device GPS & Camera APIs

---

## 📦 Prerequisites

Make sure the following tools are installed:

- [Node.js (LTS)](https://nodejs.org/)
- [Git](https://git-scm.com/)
- [Android Studio](https://developer.android.com/studio) (with Emulator or USB debugging)
- React Native CLI:
  ```bash
  npm install -g react-native-cli
  ```

---

## 🚀 Getting Started (Installation)

1. **Clone the repository**
   ```bash
   git clone https://https://github.com/kc505/CEF440_2025_GROUP12.git
   cd Task_5_FrontEnd
   cd AttendanceApp
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start Metro bundler**
   ```bash
   npx react-native start
   ```

4. **Run on Android**
   ```bash
   npx react-native run-android
   ```

> You must have an Android emulator running or a physical device connected via USB with USB debugging enabled.


## 👨‍💻 Collaboration Guide (Git Workflow)

> To avoid merge conflicts and code overwriting:

###  Pull before you push:
```bash
git pull origin main
```

### 🆕 Create a new branch before making changes:
```bash
git checkout -b your-feature-branch
```

### After changes:
```bash
git add .
git commit -m "Your meaningful message"
git push origin your-feature-branch
```

### 🔁 Create a Pull Request (PR)
- Go to GitHub → your repo → "Pull Requests" → "New Pull Request"
- Assign reviewers and wait for approval.

---
### Frontend Architecture 
```bash
/SmartCheck
├── /src
│   ├── /assets               # Images, icons, logos, fonts
│   ├── /components/          # Reusable UI components (Button, Card, Header, etc.)
│   |    ├── common/          # Generic components (Button, Input, etc.)
│   |    ├── forms/           # Form-specific components
│   |    └── charts/          # Data visualization components
├── screens/                  # Screen components organized by user role
│   ├── auth/                 # Authentication screens
│   ├── student/              # Student-specific screens
│   │   ├── /Home
│   │   ├── /Dashboard
│   │   ├── /CheckIn
│   │   ├── /Reports
│   │   ├── /Course
│   │   ├── /Profile
│   │   ├── /Dispute
│   │   └── /Auth            # Login/Register
│   ├── lecturer/            # Lecturer-specific screens
│   ├── admin/               # Admin-specific screens
│   └── common/              # Shared screens
│   ├── /constants           # Reusable constants (colors, strings, styles)
│   ├── /navigation          # Navigation logic (Stack, Tab, Drawer)
│   ├── /services            # Firebase, API, face recognition, GPS
│   ├── /store               # Redux/Zustand state management
│   ├── /utils               # Utility functions (validators, GPS checker, etc.)
│   └── App.js               # Entry point
│
├── .env                     # Environment variables (Firebase keys)
├── app.json / app.config.js
├── package.json
└── README.md
```


## 💡 Tips

- Enable camera and location permissions on your device.
- Use `.env` files for any sensitive keys (if required).
- Keep commits small and meaningful.
- Use consistent naming conventions (e.g., `camelCase` for variables).

---

## 📄 License

This project is part of an academic group project. For educational use only.

---

## 🙋‍♂️ Contributors

- TIWA DELAN NDIKA  
- AKO RUTH ACHERE 
- TUMUTOH LYDIE-KASEY BIHNUI 
- NGUIMENANG ZEUFACK KEREINE
- MEKOLLE ASHLEY ARREYMANYOR 
