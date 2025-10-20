<div align="center">

# 🧾 Flutter Inventory App

![Flutter Badge](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase Badge](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart Badge](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

</div>

<p align="center">
A comprehensive and modern <b>inventory management system</b> built with Flutter and Firebase, designed for simplicity and real-time synchronization.
<br/><br/>
<a href="https://github.com/Azrof88/flutter-inventory-app/issues">Report Bug</a> ·
<a href="https://github.com/Azrof88/flutter-inventory-app/issues">Request Feature</a>
</p>

---

## 📖 About The Project

The **Flutter Inventory App** provides a robust solution for managing inventory, tracking products, and handling user access through a **role-based system**.

Built for both **Android** and **iOS**, the app leverages Firebase for real-time updates, secure authentication, and scalability.

> This project was developed collaboratively as part of an undergraduate Software Engineering program, applying modern mobile development techniques with a powerful cloud backend.

---

## 🎬 Demo

Watch the live demo of the Flutter Inventory App in action:

[![Flutter Inventory App Demo](https://img.youtube.com/vi/NyV19egIf7I/hqdefault.jpg)](https://www.youtube.com/watch?v=NyV19egIf7I)

---

## ✨ Key Features

- 🔐 **Role-Based Authentication** – Secure sign-up/login for **Admin** and **Staff** roles.  
- 👤 **User Management (Admin Only)** – View, promote, or delete users from the system.  
- 📦 **Product CRUD** – Full Create, Read, Update, and Delete functionality for inventory management.  
- 📈 **Transaction History** – Logs all inventory activities.  
- 📊 **Dashboard** – Centralized view of metrics and quick navigation.  
- ☁️ **Real-Time Sync** – Firestore ensures instant synchronization across devices.  

---

## 🛠️ Built With

| Layer | Technology |
|-------|-------------|
| **Frontend** | Flutter |
| **Language** | Dart |
| **Backend & Database** | Firebase |
| **Authentication** | Firebase Auth (Email/Password) |
| **Realtime Database** | Firestore |

---

## 🚀 Getting Started

Follow these steps to set up the project locally.

### ✅ Prerequisites

Ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)  
- A code editor: VS Code or Android Studio  
- Android Emulator or physical device  

---

### 🔧 Firebase Setup

1. **Create a Firebase Project**  
   - Visit [Firebase Console](https://console.firebase.google.com/) → Create new project  

2. **Enable Authentication**  
   - Go to **Authentication → Sign-in method → Enable Email/Password**  

3. **Create Firestore Database**  
   - Go to **Firestore Database → Create database → Start in test mode**  

4. **Register Your App**  
   - Add an **Android app** with the package name found in `android/app/build.gradle` (`applicationId`).  
   - Download the `google-services.json` file.  
   - Place it inside `android/app/` directory of your Flutter project.  

---

### ⚙️ Installation & Running

To run the project locally, follow these steps:

    # Clone the repository
    git clone https://github.com/Azrof88/flutter-inventory-app.git

    # Navigate into the project directory
    cd flutter-inventory-app

    # Install dependencies
    flutter pub get

    # Run the app (ensure emulator/device is connected)
    flutter run


---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create.  
We **welcome all contributions** — whether it's a bug fix, a new feature, or an improvement.

Follow the steps below to contribute:

    # 1️⃣ Fork the project

    # 2️⃣ Create your feature branch
    git checkout -b feat/AmazingFeature

    # 3️⃣ Commit your changes
    git commit -m "feat: Add some AmazingFeature"

    # 4️⃣ Push to your branch
    git push origin feat/AmazingFeature

    # 5️⃣ Open a Pull Request on GitHub
    
## 👥 Project Contributors

This project is maintained by:

| Name          | GitHub                                     |
| ------------- | ------------------------------------------ |
| **Mehedi-86** | [@Mehedi-86](https://github.com/Mehedi-86) |
| **Azrof88**   | [@Azrof88](https://github.com/Azrof88)     |
| **MMI122**    | [@MMI122](https://github.com/MMI122)       |

    

