#!/usr/bin/env bash

set -e

echo "🔎 Verificando dependencias..."

missing=()

check_cmd() {
    command -v "$1" >/dev/null 2>&1 || missing+=("$1")
}

check_python_module() {
    python3 -c "import $1" 2>/dev/null || missing+=("python3-$1")
}

# ---------------- COMANDOS ----------------

check_cmd python3
check_cmd playerctl
check_cmd zenity
check_cmd xdg-user-dir
check_cmd trans
check_cmd yt-dlp
# ---------------- MÓDULOS PYTHON ----------------

check_python_module gi
check_python_module requests
check_python_module cairo
check_python_module bs4

# ---------------- RESULTADO ----------------

if [ ${#missing[@]} -ne 0 ]; then

    echo ""
    echo "❌ Faltan dependencias:"
    printf ' - %s\n' "${missing[@]}"

    echo ""

    echo "Debian/Ubuntu:"
    echo "sudo apt install python3-gi python3-cairo python3-requests python3-bs4 playerctl zenity xdg-user-dirs translate-shell yt-dlp"

    echo ""

    echo "Arch Linux:"
    echo "sudo pacman -S python-gobject python-cairo python-requests python-beautifulsoup4 playerctl zenity xdg-user-dirs translate-shell yt-dlp"

    echo ""

    echo "Fedora:"
    echo "sudo dnf install python3-gobject python3-cairo python3-requests python3-beautifulsoup4 playerctl zenity xdg-user-dirs translate-shell yt-dlp"

    exit 1
fi

echo "✅ Dependencias OK"

APP_NAME="Lyrics Wild Linux Widget"
SHORT_NAME="l-w"

INSTALL_DIR="$HOME/.config/lyrics_widget"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPT_SOURCE="$SCRIPT_DIR/lyrics_widget"

MAIN_SCRIPT="$SCRIPT_SOURCE/lyrics-widget"

echo "📦 Instalando $APP_NAME..."

# ---------------- DIRECTORIOS ----------------

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$APP_DIR"
mkdir -p "$ICON_DIR"
mkdir -p "$HOME/.config/lyrics_widget"
mkdir -p "$HOME/Música/Lyrics"

# ---------------- COPIAR ARCHIVOS ----------------

cp -r "$SCRIPT_SOURCE/"* "$INSTALL_DIR/"

echo "✅ Scripts copiados"

# ---------------- LANZADOR CLI ----------------

cat > "$BIN_DIR/l-w" << EOF
#!/usr/bin/env bash
cd "$INSTALL_DIR"
exec "$INSTALL_DIR/lyrics-widget"
EOF

chmod +x "$BIN_DIR/l-w"

echo "✅ Comando: l-w"

# ---------------- ICONO ----------------


ICON_SOURCE="$SCRIPT_DIR/icon.png"

if [ -f "$ICON_SOURCE" ]; then
    cp "$ICON_SOURCE" "$ICON_DIR/l-w.png"
    echo "🖼️ Icono instalado"
else
    echo "⚠️ icon.png no encontrado"
fi

for f in \
    lyrics-widget \
    lyrics-dl \
    srt2lrc \
    text2lrc \
    yt-lyrics \
    fetch_lyrics
    
do
    [ -f "$INSTALL_DIR/$f" ] && chmod +x "$INSTALL_DIR/$f"
done

# ---------------- DESKTOP ENTRY ----------------

cat > "$APP_DIR/l-w.desktop" << EOF
[Desktop Entry]
Name=$APP_NAME
Comment=Lyrics synchronized widget for Linux
Exec=$BIN_DIR/l-w
Icon=$ICON_DIR/l-w.png
Terminal=false
Type=Application
Categories=AudioVideo;Music;
Keywords=lyrics;music;lrc;karaoke;
StartupNotify=true
StartupWMClass=lyrics-widget
EOF

chmod +x "$APP_DIR/l-w.desktop"

echo "✅ Lanzador creado"

# ---------------- MIME CACHE ----------------

update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true

# ---------------- FINAL ----------------

echo ""
echo "🎉 Instalación completada"
echo ""
echo "▶ Ejecutar:"
echo "   l-w"
echo ""
echo "📂 Instalado en:"
echo "   $INSTALL_DIR"
