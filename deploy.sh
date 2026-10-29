#!/usr/bin/env bash

# ==============================================================================
# ReelVault — Interactive Device Deployment Assistant
# ==============================================================================

# Ensure UTF-8 locale for CocoaPods and iOS toolchains
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

clear

echo -e "${PURPLE}${BOLD}"
echo "================================================================="
echo "        🎬  ReelVault — Device Deployment Assistant              "
echo "================================================================="
echo -e "${NC}"

# Check for Flutter installation
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: 'flutter' command not found in your PATH.${NC}"
    echo "Please ensure Flutter SDK is installed and added to PATH."
    exit 1
fi

# ------------------------------------------------------------------------------
# STEP 1: Select Target Platform (Android or iOS)
# ------------------------------------------------------------------------------
echo -e "${BOLD}Step 1: Choose target platform to deploy to:${NC}"
echo -e "  ${CYAN}[1]${NC} iOS     (iPhone / iPad via cable or wireless)"
echo -e "  ${CYAN}[2]${NC} Android (Phone / Tablet via USB debugging)"
echo -e "  ${CYAN}[q]${NC} Quit"
echo ""

read -p "Select platform [1/2]: " platform_choice

case "$platform_choice" in
    1)
        TARGET_PLATFORM="ios"
        PLATFORM_NAME="iOS"
        ;;
    2)
        TARGET_PLATFORM="android"
        PLATFORM_NAME="Android"
        ;;
    q|Q)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid selection. Please choose 1 or 2.${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}Scanning for connected ${PLATFORM_NAME} devices...${NC}"

# ------------------------------------------------------------------------------
# STEP 2: Query and Filter Connected Devices
# ------------------------------------------------------------------------------
get_devices() {
    flutter devices --machine 2>/dev/null | python3 -c "
import json, sys

platform = '$TARGET_PLATFORM'
try:
    data = sys.stdin.read().strip()
    if not data:
        sys.exit(0)
    devices = json.loads(data)
    filtered = [d for d in devices if d.get('targetPlatform', '').startswith(platform)]
    for idx, d in enumerate(filtered):
        name = d.get('name', 'Unknown')
        dev_id = d.get('id', '')
        sdk = d.get('sdk', '')
        print(f\"{idx+1}|{name}|{dev_id}|{sdk}\")
except Exception:
    sys.exit(0)
"
}

DEVICE_LIST=$(get_devices)

if [ -z "$DEVICE_LIST" ]; then
    echo -e "${YELLOW}⚠️  No connected ${PLATFORM_NAME} devices found.${NC}"
    echo ""
    echo "Troubleshooting Checklist:"
    if [ "$TARGET_PLATFORM" = "ios" ]; then
        echo "  1. Ensure your iPhone is unlocked and plugged in with a Lightning/USB-C cable."
        echo "  2. Tap 'Trust This Computer' if prompted on your iPhone screen."
        echo "  3. Ensure Developer Mode is ON (Settings > Privacy & Security > Developer Mode)."
    else
        echo "  1. Ensure your Android device is connected via USB."
        echo "  2. Turn on 'USB Debugging' in Developer Options."
        echo "  3. Accept the 'Allow USB debugging' RSA prompt on your screen."
    fi
    echo ""
    read -p "Press [Enter] to scan again, or [q] to exit: " retry_choice
    if [[ "$retry_choice" =~ ^[qQ]$ ]]; then
        exit 0
    fi
    DEVICE_LIST=$(get_devices)
    if [ -z "$DEVICE_LIST" ]; then
        echo -e "${RED}Still no device detected. Please check the cable connection and try again.${NC}"
        exit 1
    fi
fi

# Count devices
DEVICE_COUNT=$(echo "$DEVICE_LIST" | wc -l | tr -d ' ')

# ------------------------------------------------------------------------------
# STEP 3: Prompt User to Select the Device
# ------------------------------------------------------------------------------
echo ""
echo -e "${BOLD}Step 2: Choose the connected device:${NC}"

SELECTED_DEVICE_ID=""
SELECTED_DEVICE_NAME=""

if [ "$DEVICE_COUNT" -eq 1 ]; then
    IFS='|' read -r idx name dev_id sdk <<< "$DEVICE_LIST"
    echo -e "Found 1 device: ${GREEN}${BOLD}${name}${NC} (${sdk}) [ID: ${dev_id}]"
    read -p "Deploy to this device? [Y/n]: " confirm
    confirm=${confirm:-Y}
    if [[ "$confirm" =~ ^[yY]$ ]]; then
        SELECTED_DEVICE_ID="$dev_id"
        SELECTED_DEVICE_NAME="$name"
    else
        echo "Deployment cancelled."
        exit 0
    fi
else
    # Multiple devices: display numbered list
    while IFS='|' read -r idx name dev_id sdk; do
        echo -e "  ${CYAN}[$idx]${NC} ${BOLD}${name}${NC} (${sdk}) — ID: ${dev_id}"
    done <<< "$DEVICE_LIST"
    echo ""
    read -p "Select device number [1-$DEVICE_COUNT]: " dev_selection

    # Extract chosen device
    CHOSEN_LINE=$(echo "$DEVICE_LIST" | grep "^${dev_selection}|")
    if [ -z "$CHOSEN_LINE" ]; then
        echo -e "${RED}Invalid selection.${NC}"
        exit 1
    fi
    IFS='|' read -r idx name dev_id sdk <<< "$CHOSEN_LINE"
    SELECTED_DEVICE_ID="$dev_id"
    SELECTED_DEVICE_NAME="$name"
fi

# ------------------------------------------------------------------------------
# STEP 4: Choose Build Mode (Debug or Release)
# ------------------------------------------------------------------------------
echo ""
echo -e "${BOLD}Step 3: Select build mode:${NC}"
echo -e "  ${CYAN}[1]${NC} Debug   (Default: Fast compile, Hot Reload & live logs enabled)"
echo -e "  ${CYAN}[2]${NC} Release (Optimized AOT production binary)"
echo ""
read -p "Select build mode [1/2] (Default 1): " mode_choice
mode_choice=${mode_choice:-1}

BUILD_FLAG=""
if [ "$mode_choice" = "2" ]; then
    BUILD_FLAG="--release"
    MODE_NAME="Release"
else
    BUILD_FLAG=""
    MODE_NAME="Debug"
fi

# ------------------------------------------------------------------------------
# STEP 5: Deploy to Device
# ------------------------------------------------------------------------------
echo ""
echo -e "${GREEN}${BOLD}=================================================================${NC}"
echo -e "${GREEN}${BOLD}🚀 Deploying ReelVault to ${SELECTED_DEVICE_NAME} (${MODE_NAME} Mode)...${NC}"
echo -e "${GREEN}${BOLD}=================================================================${NC}"
echo ""

# Run Flutter build and install
flutter run -d "$SELECTED_DEVICE_ID" $BUILD_FLAG

echo ""
echo -e "${GREEN}Deployment process completed.${NC}"
