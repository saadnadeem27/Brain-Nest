# 🧠 Brain Nest - Educational Learning Platform

<div align="center">

![Brain Nest Logo](https://img.shields.io/badge/Brain%20Nest-Educational%20Platform-blue?style=for-the-badge&logo=flutter)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)](https://firebase.google.com)
[![GetX](https://img.shields.io/badge/GetX-9C27B0?style=for-the-badge&logo=flutter&logoColor=white)](https://pub.dev/packages/get)

*A comprehensive learning management system connecting students and educators through innovative technology*

[📱 Demo](#demo) • [🚀 Features](#features) • [🏗️ Architecture](#architecture) • [⚡ Quick Start](#quick-start) • [📖 Documentation](#documentation)

</div>

## 📖 Project Overview

Brain Nest is a modern, cross-platform educational learning management system built with Flutter and powered by Firebase. The platform seamlessly bridges the gap between students and educators, providing a comprehensive suite of tools for course management, assignment tracking, real-time collaboration, and progress analytics.

### 🎯 Mission Statement

Empowering education through technology by creating an intuitive, scalable, and feature-rich platform that enhances the learning experience for both students and educators.

## ✨ Features

### 👨‍🎓 Student Portal
- **🏠 Personalized Dashboard**: Quick access to enrolled courses, pending assignments, and progress overview
- **📚 Course Management**: Browse, enroll, and track progress in multiple courses
- **📝 Assignment Center**: Submit assignments, view grades, and track completion status
- **📊 Progress Analytics**: Visual representation of learning progress and achievements
- **👤 Profile Management**: Customizable profile with academic information and preferences
- **🔔 Smart Notifications**: Real-time updates on assignments, grades, and course announcements

### 👩‍🏫 Educator Portal
- **📋 Course Administration**: Create, manage, and publish courses with multimedia content
- **📝 Assignment Creation**: Design and distribute assignments with flexible grading rubrics
- **📊 Gradebook Management**: Comprehensive grading system with analytics and reporting
- **👥 Student Management**: Monitor student progress and engagement metrics
- **📈 Analytics Dashboard**: Detailed insights into course performance and student analytics
- **⚙️ Advanced Settings**: Customize course settings, permissions, and notifications

### 🔧 Technical Features
- **🌐 Cross-Platform**: Native performance on iOS, Android, Web, Windows, and macOS
- **🔐 Secure Authentication**: Firebase Authentication with role-based access control
- **☁️ Cloud Storage**: Seamless file uploads and downloads with Firebase Storage
- **🔄 Real-time Sync**: Live updates and collaborative features powered by Firestore
- **📱 Responsive Design**: Adaptive UI that works perfectly on all screen sizes
- **🌙 Dark/Light Theme**: Toggle between themes for optimal viewing experience

## 🏗️ Architecture

### 📁 Project Structure

```
lib/
├── 🎯 main.dart                 # Application entry point
├── 🛤️ routes.dart              # Navigation routing configuration
├── 🔧 common_imports.dart       # Centralized imports
├── ⚙️ app_selection_screen.dart # Role selection interface
├── 🔥 firebase_options.dart     # Firebase configuration
│
├── 📱 screens/                  # Application screens
│   ├── 🏠 dashboard/           # Dashboard screens for both roles
│   ├── 🔐 auth/                # Authentication screens
│   ├── 📚 courses/             # Course-related screens
│   ├── 📝 assignments/         # Assignment management screens
│   └── 👤 profile/             # User profile screens
│
├── 🎮 controllers/             # GetX state management
│   ├── 🔐 auth_controller.dart
│   ├── 👨‍🎓 learner_controller.dart
│   └── 👩‍🏫 educator_controller.dart
│
├── 🛠️ services/               # Business logic services
│   ├── 🔥 firebase/           # Firebase service layer
│   │   ├── authentication_service.dart
│   │   ├── firestore_service.dart
│   │   ├── storage_service.dart
│   │   └── cloud_function_service.dart
│   └── 📊 static_data_service.dart
│
├── 🧩 components/              # Reusable UI components
│   ├── 🎨 common/             # Shared components
│   ├── 📊 charts/             # Data visualization components
│   └── 📋 cards/              # Information display cards
│
├── 🎨 view/                    # UI styling and themes
├── 🔧 helper/                  # Utility functions
└── 📦 common/                  # Shared resources
```

### 🔧 Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | Flutter 3.6+ | Cross-platform UI framework |
| **State Management** | GetX 4.6.6 | Reactive state management |
| **Backend** | Firebase | Cloud services and authentication |
| **Database** | Cloud Firestore | NoSQL document database |
| **Storage** | Firebase Storage | File and media storage |
| **Authentication** | Firebase Auth | Secure user authentication |
| **Cloud Functions** | Firebase Functions | Server-side logic |
| **Analytics** | Firebase Analytics | User behavior tracking |

### 🏛️ Architecture Pattern

Brain Nest follows the **MVVM (Model-View-ViewModel)** pattern enhanced with **Clean Architecture** principles:

```
📱 Presentation Layer (Views & Controllers)
    ↕️
🧠 Business Logic Layer (Services & UseCases)
    ↕️
💾 Data Layer (Repositories & Data Sources)
    ↕️
☁️ External Services (Firebase, APIs)
```

## ⚡ Quick Start

### 📋 Prerequisites

Before running this project, ensure you have:

- **Flutter SDK**: Version 3.6.0 or higher
- **Dart SDK**: Version 2.19.0 or higher
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
- **Platform Tools**: 
  - Android: Android Studio & SDK
  - iOS: Xcode (macOS only)
  - Web: Chrome browser
  - Desktop: Platform-specific requirements

### 🔧 Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/brain_nest.git
   cd brain_nest
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   
   **Option 1: Quick Setup (Recommended)**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Configure FlutterFire
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   **Option 2: Manual Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add your app for each platform (Android, iOS, Web)
   - Download configuration files:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Update `lib/firebase_options.dart` with your project configuration

4. **Configure Firebase Services**
   
   Enable the following services in your Firebase project:
   - ✅ Authentication (Email/Password)
   - ✅ Cloud Firestore
   - ✅ Storage
   - ✅ Cloud Functions (optional)
   - ✅ Analytics (optional)

5. **Run the Application**
   ```bash
   # For development
   flutter run
   
   # For specific platform
   flutter run -d chrome          # Web
   flutter run -d macos           # macOS
   flutter run -d windows         # Windows
   ```

### 🚀 Build for Production

```bash
# Android APK
flutter build apk --release

# iOS App Store
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

## 📖 Documentation

### 🎮 State Management with GetX

Brain Nest uses GetX for reactive state management:

```dart
// Example: Course Controller
class CourseController extends GetxController {
  final _courses = <Course>[].obs;
  List<Course> get courses => _courses;
  
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }
  
  Future<void> loadCourses() async {
    _isLoading.value = true;
    try {
      final courses = await FirestoreService.instance.getCourses();
      _courses.assignAll(courses);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load courses');
    } finally {
      _isLoading.value = false;
    }
  }
}
```

### 🔥 Firebase Integration

#### Authentication Service
```dart
// Sign in example
final user = await AuthenticationService.instance.signInWithEmailAndPassword(
  email: 'student@example.com',
  password: 'password123',
);
```

#### Firestore Service
```dart
// Create course example
final courseId = await FirestoreService.instance.createCourse(
  title: 'Flutter Development',
  description: 'Learn Flutter from basics to advanced',
  educatorId: 'educator_123',
  category: 'Programming',
);
```

#### Storage Service
```dart
// Upload file example
final downloadUrl = await StorageService.instance.uploadFile(
  filePath: '/path/to/file.pdf',
  fileName: 'assignment.pdf',
  storagePath: StorageService.assignmentFilesPath,
);
```

### 🎨 UI Components

#### Custom Cards
```dart
GradientCard(
  child: CourseInfoWidget(course: course),
  onTap: () => Get.to(() => CourseDetailScreen(course: course)),
)
```

#### Progress Indicators
```dart
CircularProgressIndicator(
  value: course.progress / 100,
  backgroundColor: Colors.grey[300],
  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
)
```

## 🧪 Testing

### Running Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
```

### Test Structure

```
test/
├── unit/
│   ├── controllers/
│   ├── services/
│   └── models/
├── widget/
├── integration/
└── test_utils/
```

## 📊 Performance Optimization

### Code Organization
- **Lazy Loading**: Controllers and services are loaded on-demand
- **Efficient State Management**: Minimal rebuilds with GetX observables
- **Image Optimization**: Cached network images with automatic compression
- **Code Splitting**: Feature-based module organization

### Best Practices Implemented
- ✅ Null safety enabled
- ✅ Lint rules enforced
- ✅ Performance monitoring
- ✅ Memory leak prevention
- ✅ Efficient list rendering
- ✅ Optimized animations

## 🔒 Security Features

- **🔐 Authentication**: Secure Firebase Authentication
- **🛡️ Authorization**: Role-based access control
- **🔒 Data Validation**: Input sanitization and validation
- **🚫 Security Rules**: Firestore security rules
- **🔑 API Security**: Secure cloud function endpoints

## 🌍 Internationalization

Brain Nest supports multiple languages:

```dart
// Add to pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter

// Usage
Text('welcome'.tr)  // GetX translation
```

## 🚀 Deployment

### Web Hosting (Firebase Hosting)
```bash
firebase init hosting
flutter build web
firebase deploy
```

### App Store Deployment
```bash
# iOS App Store
flutter build ios --release
# Follow Apple's app submission guidelines

# Google Play Store
flutter build appbundle --release
# Follow Google Play Console submission process
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes following our coding standards
4. Add tests for new functionality
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Coding Standards
- Follow Dart/Flutter style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features
- Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors & Contributors

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for robust backend services
- GetX community for excellent state management
- Material Design for UI inspiration
- Open source community for various packages

## 📞 Support & Contact

- **📧 Email**: support@brainnest.com
- **💬 Discord**: [Join our community](https://discord.gg/brainnest)
- **🐛 Issues**: [GitHub Issues](https://github.com/yourusername/brain_nest/issues)
- **📖 Documentation**: [Wiki](https://github.com/yourusername/brain_nest/wiki)

## 🗺️ Roadmap

### 🔮 Upcoming Features
- [ ] 📹 Video conferencing integration
- [ ] 📝 Rich text editor for assignments
- [ ] 🤖 AI-powered content recommendations
- [ ] 📱 Mobile app widgets
- [ ] 🌐 Multi-language support
- [ ] 📊 Advanced analytics dashboard
- [ ] 🔔 Push notifications
- [ ] 📋 Offline mode support

### 🎯 Version History
- **v1.0.0** - Initial release with core features
- **v1.1.0** - Enhanced UI and performance improvements
- **v1.2.0** - Firebase integration and cloud features

---

<div align="center">

**Made with ❤️ using Flutter**

[⭐ Star this project](https://github.com/yourusername/brain_nest) if you found it helpful!

</div>
