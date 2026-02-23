#!/bin/bash
# ============================================================
#  MySchedule – Termux Build Script
#  Run this script inside Termux on your Android phone
#  Usage: bash BUILD_ON_TERMUX.sh
# ============================================================

set -e
echo "=================================================="
echo "  MySchedule – Termux Build Script"
echo "=================================================="

# Step 1: Storage
echo "[1/7] Setting up storage access..."
termux-setup-storage || true
sleep 2

# Step 2: Packages
echo "[2/7] Installing system packages..."
pkg update -y && pkg upgrade -y
pkg install -y git wget curl unzip openjdk-17 proot-distro

# Step 3: Flutter SDK
echo "[3/7] Downloading Flutter SDK..."
cd ~
if [ ! -d "flutter" ]; then
  wget -q --show-progress https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz -O flutter.tar.xz
  tar xf flutter.tar.xz
  rm flutter.tar.xz
fi

export PATH="$HOME/flutter/bin:$PATH"
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc

# Step 4: Android SDK via sdkmanager
echo "[4/7] Setting up Android SDK..."
mkdir -p ~/android-sdk/cmdline-tools
cd ~/android-sdk/cmdline-tools
if [ ! -d "latest" ]; then
  wget -q --show-progress https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline.zip
  unzip -q cmdline.zip
  mv cmdline-tools latest
  rm cmdline.zip
fi

export ANDROID_SDK_ROOT="$HOME/android-sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
echo 'export ANDROID_SDK_ROOT="$HOME/android-sdk"' >> ~/.bashrc
echo 'export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"' >> ~/.bashrc

yes | sdkmanager --licenses
sdkmanager "platforms;android-34" "build-tools;34.0.0" "platform-tools"

# Step 5: Copy project
echo "[5/7] Copying MySchedule project..."
cp -r ~/storage/downloads/myschedule ~/myschedule_build 2>/dev/null || true
cd ~/myschedule_build

# Step 6: Flutter pub get
echo "[6/7] Getting Flutter dependencies..."
flutter pub get

# Step 7: Build APK
echo "[7/7] Building APK (this may take 5-10 minutes)..."
flutter build apk --release --no-tree-shake-icons

echo ""
echo "=================================================="
echo "  BUILD COMPLETE!"
echo "  APK location:"
echo "  ~/myschedule_build/build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "  Copying to Downloads..."
cp build/app/outputs/flutter-apk/app-release.apk ~/storage/downloads/MySchedule.apk
echo "  Done! Find MySchedule.apk in your Downloads folder."
echo "  Install it by tapping the file!"
echo "=================================================="
