#!/bin/bash
# ============================================================
#  MySchedule - Termux Build Script
#  Run this inside Termux on your Android phone
# ============================================================

echo "🚀 MySchedule Build Script Starting..."
echo ""

# Step 1: Update packages
echo "📦 Step 1: Updating Termux packages..."
pkg update -y && pkg upgrade -y

# Step 2: Install dependencies
echo "📦 Step 2: Installing required packages..."
pkg install -y git wget curl unzip openjdk-17 gradle

# Step 3: Download Flutter
echo "🐦 Step 3: Downloading Flutter SDK..."
cd $HOME
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Step 4: Add Flutter to PATH
echo "🔧 Step 4: Setting up PATH..."
export PATH="$HOME/flutter/bin:$PATH"
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc

# Step 5: Set JAVA_HOME
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc

# Step 6: Accept Android licenses & set up SDK
echo "🤝 Step 6: Setting up Android SDK..."
flutter config --android-sdk $HOME/flutter/bin/cache/artifacts/engine/android-arm-release/
flutter doctor --android-licenses

# Step 7: Pre-cache Flutter
echo "📥 Step 7: Pre-caching Flutter..."
flutter precache --android

# Step 8: Build the APK
echo "🔨 Step 8: Building APK..."
cd $HOME/myschedule
flutter pub get
flutter build apk --release --no-shrink

# Done!
echo ""
echo "✅ BUILD COMPLETE!"
echo "📱 Your APK is at:"
echo "   $HOME/myschedule/build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "Transfer it to your Downloads folder with:"
echo "   cp build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/MySchedule.apk"
