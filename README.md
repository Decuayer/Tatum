# Tatum - Tattoo Artist Social Platform

A SwiftUI-based iOS social media application connecting tattoo artists with enthusiasts.

## 🎨 Features

- **User Authentication**: Email/password registration and login
- **Social Feed**: View posts from followed artists
- **User Profiles**: Browse artist portfolios and tattoo work
- **Studio Locator**: Find tattoo studios on an interactive map
- **Messaging**: Direct chat with artists  
- **Booking**: Schedule appointments with artists
- **Explore**: Discover new artists and trending content

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+
- CocoaPods or Swift Package Manager
- Firebase account

## 🚀 Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Tatum
```

### 2. Install Dependencies

This project uses Firebase. The required packages are:
- Firebase/Auth
- Firebase/Firestore
- Firebase/Storage

Dependencies should be managed via Swift Package Manager (already configured in the project).

### 3. Firebase Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an iOS app to your Firebase project
3. Download `GoogleService-Info.plist`
4. **IMPORTANT**: Place `GoogleService-Info.plist` in the `Tatum/` folder (it's git-ignored for security)
5. Enable the following Firebase services:
   - **Authentication** → Email/Password provider
   - **Firestore Database**
   - **Storage**

### 4. Deploy Firebase Security Rules

**Critical Step - Do not skip!**

Deploy the security rules to protect your database:

```bash
# Install Firebase CLI if you haven't already
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project directory (if not already done)
firebase init

# Deploy security rules
firebase deploy --only firestore:rules,storage:rules
```

### 5. Build and Run

1. Open `Tatum.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Choose a simulator or connected device
4. Press `Cmd + R` to build and run

## 🏗 Project Structure

```
Tatum/
├── Model/           # Data models (User, Post, Studio, etc.)
├── View/            # SwiftUI views
│   ├── Authentication/
│   ├── Feed/
│   ├── Profile/
│   ├── Studios/
│   └── Messages/
├── ViewModel/       # Business logic layer
├── Service/         # Firebase API interactions
│   ├── AuthService.swift
│   ├── FeedService.swift
│   ├── ProfileService.swift
│   └── ImageUploader.swift
└── Utils/           # Helper extensions and utilities
```

## 🔒 Security Notes

- ✅ Firestore security rules enforce authentication
- ✅ Storage rules validate file types and sizes
- ✅ GoogleService-Info.plist is git-ignored
- ✅ User passwords are handled by Firebase Auth (never stored locally)
- ⚠️ Never commit Firebase configuration files to version control

## 🧪 Testing

### Debug Mode Features

The project includes a `TestDataManager` (DEBUG-only) for creating test users and data. This is automatically excluded from release builds.

To create test data:
1. Run app in Debug mode
2. Test users will be available if referenced in your development views

### Running Tests

```bash
# Run unit tests
xcodebuild test -scheme Tatum -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 📱 Building for Production

1. Set build configuration to **Release**
2. Archive the app (`Product > Archive` in Xcode)
3. Validate the app for App Store submission
4. Ensure all Firebase services are in production mode (not test mode)
5. Submit to App Store Connect

## 🐛 Troubleshooting

### Build Errors

**"GoogleService-Info.plist not found"**
- Ensure you've downloaded the file from Firebase Console
- Place it in the `Tatum/` folder (same level as `TatumApp.swift`)

**Authentication failures**
- Verify Email/Password provider is enabled in Firebase Console
- Check Firebase Auth logs in the console

**Image upload failures**
- Verify Storage security rules are deployed
- Check file size limits (10MB for posts, 5MB for profiles)

### Firebase Emulator (Optional)

For local development without affecting production data:

```bash
firebase emulators:start --only firestore,storage,auth
```

Update `TatumApp.swift` to connect to emulators in debug mode.

## 🤝 Contributing

1. Create a feature branch (`git checkout -b feature/amazing-feature`)
2. Commit your changes (`git commit -m 'Add amazing feature'`)
3. Push to the branch (`git push origin feature/amazing-feature`)
4. Open a Pull Request

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📧 Contact

Demir Cücü - demircucu35@gmail.com

Project Link: [https://github.com/Decuayer/Tatum](https://github.com/Decuayer/Tatum)

## Development Principles

This codebase follows:
- MVVM architecture pattern
- Protocol-oriented design for testability
- SwiftUI best practices
- Firebase security best practices
- English-only code and comments for international collaboration
