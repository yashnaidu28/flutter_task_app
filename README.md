# Flutter Task App

## Overview
This is a Flutter task management app that allows users to create, update, and delete tasks. It uses Firebase Realtime Database for data storage and Flutter Local Notifications for reminder functionality.

## Setup
To set up and run the project locally, follow these steps:

1. **Clone the repository:**  
git clone https://github.com/yashnaidu28/flutter_task_app.git

2. **Navigate to the project directory:**  
cd flutter_task_app

3. **Install dependencies:**  
flutter pub get

4. **Configure Firebase:**  
- Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
- Add an Android app to your Firebase project and follow the setup instructions to download the `google-services.json` file.
- Place the `google-services.json` file in the `android/app` directory of your Flutter project.
- Add an iOS app to your Firebase project and follow the setup instructions to download the `GoogleService-Info.plist` file.
- Place the `GoogleService-Info.plist` file in the `ios/Runner` directory of your Flutter project.

5. **Run the app:**  
flutter run
