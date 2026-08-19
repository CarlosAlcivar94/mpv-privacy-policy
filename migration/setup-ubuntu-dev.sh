#!/usr/bin/env bash
set -Eeuo pipefail

OWNER="${GITHUB_OWNER:-CarlosAlcivar94}"
DEV_DIR="${DEV_DIR:-$HOME/Dev}"
FLUTTER_DIR="${FLUTTER_DIR:-$HOME/development/flutter}"
NODE_VERSION="${NODE_VERSION:-22}"
INSTALL_GUI_APPS="${INSTALL_GUI_APPS:-1}"

run_or_warn() {
  "$@" || echo "WARN: command failed: $*"
}

ensure_path_line() {
  local line="$1"
  local file="$HOME/.bashrc"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '\n%s\n' "$line" >> "$file"
  fi
}

install_system_packages() {
  sudo apt-get update
  sudo apt-get install -y \
    build-essential ca-certificates clang cmake curl git gnupg libglu1-mesa \
    libgtk-3-dev libsqlite3-dev lsb-release ninja-build openjdk-17-jdk \
    php-cli php-curl php-mbstring php-mysql php-sqlite3 php-xml php-zip \
    pkg-config python3 python3-cryptography python3-pip python3-venv unzip \
    xz-utils zip composer
}

install_node() {
  export NVM_DIR="$HOME/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  fi

  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
  nvm install "$NODE_VERSION"
  nvm alias default "$NODE_VERSION"
  nvm use default
  npm install -g npm@11 firebase-tools

  ensure_path_line 'export NVM_DIR="$HOME/.nvm"'
  ensure_path_line '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'
}

install_flutter() {
  mkdir -p "$(dirname "$FLUTTER_DIR")"
  if [ ! -d "$FLUTTER_DIR/.git" ]; then
    git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
  else
    git -C "$FLUTTER_DIR" pull --ff-only
  fi

  export PATH="$FLUTTER_DIR/bin:$HOME/.pub-cache/bin:$PATH"
  ensure_path_line "export PATH=\"$FLUTTER_DIR/bin:\$HOME/.pub-cache/bin:\$PATH\""

  flutter --version
  flutter config --enable-android
  run_or_warn flutter precache --android
  run_or_warn dart pub global activate flutterfire_cli
}

install_optional_gui_apps() {
  if [ "$INSTALL_GUI_APPS" != "1" ]; then
    return
  fi

  if command -v snap >/dev/null 2>&1; then
    run_or_warn sudo snap install code --classic
    run_or_warn sudo snap install android-studio --classic
    run_or_warn sudo snap install chromium
  else
    echo "WARN: snap is not available. Install Android Studio, VS Code and Chrome/Chromium manually."
  fi
}

clone_or_update() {
  local repo="$1"
  local folder="$2"
  local custom_url="${3:-}"
  local target="$DEV_DIR/$folder"
  local url="${custom_url:-https://github.com/$OWNER/$repo.git}"

  mkdir -p "$DEV_DIR"

  if [ -d "$target/.git" ]; then
    echo "Updating $target"
    run_or_warn git -C "$target" pull --ff-only
    return
  fi

  echo "Cloning $url -> $target"
  if [ -n "${GITHUB_TOKEN:-}" ] && [[ "$url" == https://github.com/* ]]; then
    git -c "http.extraheader=AUTHORIZATION: bearer $GITHUB_TOKEN" clone "$url" "$target"
  else
    git clone "$url" "$target"
  fi
}

install_node_package() {
  local path="$1"
  if [ ! -f "$path/package.json" ]; then
    return
  fi

  pushd "$path" >/dev/null
  if [ -f package-lock.json ]; then
    run_or_warn npm ci --no-audit --no-fund
  else
    run_or_warn npm install --no-audit --no-fund
  fi
  popd >/dev/null
}

install_flutter_package() {
  local path="$1"
  if [ ! -f "$path/pubspec.yaml" ]; then
    return
  fi

  pushd "$path" >/dev/null
  run_or_warn flutter pub get
  popd >/dev/null
}

install_project_dependencies() {
  local folder="$1"
  local profile="$2"
  local path="$DEV_DIR/$folder"

  if [ ! -d "$path" ]; then
    echo "WARN: missing project folder: $path"
    return
  fi

  echo "Installing dependencies for $folder [$profile]"

  case "$profile" in
    flutter-firebase)
      install_flutter_package "$path"
      install_node_package "$path/functions"
      ;;
    flutter-node-firebase)
      install_flutter_package "$path"
      install_node_package "$path"
      install_node_package "$path/functions"
      ;;
    turnero-node)
      pushd "$path" >/dev/null
      run_or_warn npm run install:frontend
      run_or_warn npm run install:backend
      popd >/dev/null
      ;;
    node-firebase)
      install_node_package "$path"
      ;;
    python)
      if [ -f "$path/requirements.txt" ]; then
        python3 -m venv "$path/.venv"
        "$path/.venv/bin/python" -m pip install --upgrade pip
        "$path/.venv/bin/python" -m pip install -r "$path/requirements.txt"
      fi
      ;;
    php-node)
      if [ -f "$path/composer.json" ]; then
        pushd "$path" >/dev/null
        run_or_warn composer install
        popd >/dev/null
      fi
      install_node_package "$path"
      ;;
    static-site)
      echo "Static site: no dependency install required."
      ;;
    *)
      echo "WARN: unknown install profile: $profile"
      ;;
  esac
}

main() {
  install_system_packages
  install_node
  install_flutter
  install_optional_gui_apps

  clone_or_update "MVP" "MVP"
  clone_or_update "FutureBalance" "FutureBalance"
  clone_or_update "SATurno" "SATurno" "${SATURNO_REPO_URL:-}"
  clone_or_update "GeCTExcel" "gectexcel" "${GECTEXCEL_REPO_URL:-}"
  clone_or_update "AdminCenterKA94" "AdminCenterKA94"
  clone_or_update "GlobalView" "globalview" "${GLOBALVIEW_REPO_URL:-}"
  clone_or_update "CeviFlash" "ceviflash"
  clone_or_update "mpv-privacy-policy" "mpv-privacy-policy"

  install_project_dependencies "MVP" "flutter-firebase"
  install_project_dependencies "FutureBalance" "flutter-firebase"
  install_project_dependencies "SATurno" "turnero-node"
  install_project_dependencies "gectexcel" "python"
  install_project_dependencies "AdminCenterKA94" "flutter-node-firebase"
  install_project_dependencies "globalview" "php-node"
  install_project_dependencies "ceviflash" "node-firebase"
  install_project_dependencies "mpv-privacy-policy" "static-site"

  echo ""
  echo "Base setup finished."
  echo "Open Android Studio once, install Android SDK, then run:"
  echo "  flutter doctor --android-licenses"
  echo "  flutter doctor"
}

main "$@"
