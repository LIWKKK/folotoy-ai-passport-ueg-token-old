<p align="right">
  <strong>English</strong> · <a href="README.zh_CN.md">简体中文</a>
</p>

# UEG Digital Life Card · Firmware & Source Release (Archived)

> [!IMPORTANT]
> **This repository is a historical archive of v1.0.0.** Active development and the latest releases live at [folotoy-ai-passport-ueg-token](https://github.com/LIWKKK/folotoy-ai-passport-ueg-token).

[![archived](https://img.shields.io/badge/status-archived_yellow)]() [![chip](https://img.shields.io/badge/chip-ESP32__C3__8MB-red)]() [![idf](https://img.shields.io/badge/ESP--IDF-v5.5-blue)]() [![version](https://img.shields.io/badge/WE--TOKEN-v1.0.0-green)]()

> Firmware for the [FoloToy AI Passport](https://ai-passport.folotoy.cn/) (ESP32-C3, 8 MB Flash) that turns the device into a pocket "digital life card": AI-platform balances, daily spend, a monthly usage heatmap, plus the next F1 race countdown and championship standings.

Official play page: <https://ai-passport.folotoy.cn/plays/342/>

**Build gate**: `tools/validate.sh` all green (repository checks / host tests / firmware layout / merged image)

---

## What it is

Five pages, navigated with the UP/DOWN keys: **Identity card**, **Balance board**, **Usage heatmap**, **F1 board** (next race, standings, news in Beijing time), and **Connection setup** (press OK on page 5 to open the config hotspot).

> This repository hosts the release assets only (firmware images + source snapshot + checksums); the fully browsable source tree lives in the [new repository](https://github.com/LIWKKK/folotoy-ai-passport-ueg-token).

## Flashing

Root files are the release assets: `FoloToy-AI-Passport-full.bin` (full image, 2 866 528 B, flash from 0x0), `FoloToy-AI-Passport-app-only.bin` (app only, 2 800 928 B, from 0x10000), `ueg-token-src-20260913.tar.gz` (source snapshot), `SHA256SUMS.txt`, and `flash.sh` (verifies SHA256, calls esptool, picks full/app automatically).

```bash
./flash.sh /dev/ttyACM0            # full image (default)
./flash.sh /dev/ttyACM0 app        # app partition only

# Manual full image
esptool.py --chip esp32c3 --baud 921600 \
  --flash_mode dio --flash_freq 80m --flash_size 8MB \
  write_flash 0x0 FoloToy-AI-Passport-full.bin

# Manual app-only
esptool.py --chip esp32c3 --baud 921600 \
  --flash_mode dio --flash_freq 80m --flash_size 8MB \
  write_flash 0x10000 FoloToy-AI-Passport-app-only.bin
```

### ⚠️ Before you flash

- **A full image overwrites the NVS partition** (`0x9000`) → saved Wi-Fi credentials and platform keys are wiped; re-configure after boot. Use the app-only method to keep your configuration.
- **Protected regions are untouched**: the full image writes up to `0x2bbd60`, while `cardid` sits at `0x356000` and `recovery` at `0x700000`. `tools/verify_firmware.py` enforces this.

## First-boot setup

1. Join the hotspot **`UEG-TOKEN-XXXX`** (last 4 digits from the device MAC)
2. Password: `ordinarylife`
3. Open `http://192.168.4.1` (private window recommended; the save button is pinned to the top)
4. Enter Wi-Fi credentials and platform API keys → save → the device reboots and refreshes online

## Rebuild from source

```bash
tar xzf ueg-token-src-20260913.tar.gz
cd ueg-token
idf.py build                       # ESP-IDF v5.5
./tools/validate.sh
idf.py merge-bin -o "$(pwd)/build/FoloToy-AI-Passport-full.bin"
```

> `-o` of `idf.py merge-bin` resolves relative to the **build directory** — use an absolute path.

## F1 data sources

| Data | Endpoint |
|---|---|
| Next race | `api.jolpi.ca/ergast/f1/current/next.json` |
| Drivers | `.../driverstandings.json?limit=5` |
| Constructors | `.../constructorstandings.json?limit=5` |
| News | `formula1.com/en/latest/all.xml` |

All times are displayed in Beijing time.

## License

Firmware and source are provided as-is for FoloToy AI Passport community play.
