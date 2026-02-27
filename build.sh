#!/bin/bash
set -e

# Install Flutter if not present
if [ ! -d "flutter" ]; then
    echo "Installing Flutter..."
    git clone --depth 1 -b stable https://github.com/flutter/flutter.git flutter
fi

export PATH="$PATH:$PWD/flutter/bin"

flutter precache
flutter pub get
flutter build web --release
