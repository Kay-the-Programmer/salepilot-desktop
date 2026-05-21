# SalePilot POS — Windows install guide

This document covers two audiences:

1. **Developer** — build the `.exe` and `.msix` from source.
2. **Operator** — install the produced `.msix` on a fresh POS terminal.

---

## 1. Developer: build from source

### One-time setup on the build machine

1. Install **Flutter 3.44+** ([https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)) and add it to `PATH`.
2. Install **Visual Studio 2022 Community** with the **"Desktop development with C++"** workload — required for Flutter to compile native Windows code.
3. Verify the toolchain:
   ```powershell
   flutter doctor
   ```
   Both **Windows toolchain** and **Visual Studio** must show a green check.

### Build

From the `salepilot_desktop\` folder:

```powershell
# Quickest path — uses the helper script:
.\scripts\build_windows.ps1 -Msix

# Or manually:
flutter pub get
flutter analyze
flutter test
flutter build windows --release
dart run msix:create
```

Outputs:

| File | Path |
|---|---|
| Standalone executable | `build\windows\x64\runner\Release\salepilot_desktop.exe` (plus DLLs + `data\` folder — distribute the whole folder) |
| MSIX installer | `build\msix\SalePilotPOS.msix` |

### Point the build at a specific backend

Bake the API URL into the build:

```powershell
.\scripts\build_windows.ps1 -Msix -ApiBaseUrl 'https://s-back-q0gg.onrender.com/api'
```

The operator can still override this at runtime via the **"Change"** link on the login screen.

---

## 2. Operator: install on a POS terminal

The MSIX is currently **unsigned** (sideload-only). Three options:

### Option A — Sideload an unsigned MSIX (simplest, requires dev mode)

1. On the Windows terminal, open **Settings → Privacy & Security → For developers**.
2. Turn on **Developer Mode**. (On Windows 10 the toggle says "Install apps from any source, including loose files".)
3. Double-click `SalePilotPOS.msix`. Click **Install**.
4. Launch from the Start Menu: search for **SalePilot POS**.

### Option B — Sideload via PowerShell

```powershell
# As an administrator on the terminal:
Add-AppxPackage -Path 'C:\Path\To\SalePilotPOS.msix'
```

### Option C — Loose-folder install (no MSIX, no dev mode)

Copy the entire `Release\` folder to e.g. `C:\Program Files\SalePilot POS\`, then create a Start Menu shortcut to `salepilot_desktop.exe`. Quick-and-dirty but works on any machine without enabling dev mode.

### Signed installer (production)

To distribute through normal channels without enabling Developer Mode, the MSIX must be signed with a code-signing certificate:

1. Acquire a certificate (e.g. DigiCert, Sectigo — ~$200–500/yr).
2. Add to `pubspec.yaml` under `msix_config`:
   ```yaml
   publisher: 'CN=YourCompany, O=YourCompany, C=US'
   certificate_path: cert.pfx
   certificate_password: <password>
   ```
3. Re-build: `dart run msix:create`.

The package will now install on stock Windows without Developer Mode.

---

## 3. First-run checks (operator)

1. App opens to the login screen.
2. If the default `localhost:5000/api` isn't correct, click the small **"Change"** link under the Sign In button and enter the right API URL.
3. Sign in with your SalePilot credentials.
4. The catalog pulls from the server (~few seconds). The pill in the title bar should show **Synced**.
5. Try a test sale with cash to verify printing — the receipt dialog has a **Print receipt** button.
6. Disconnect the network briefly and confirm the pill goes to **Offline · N queued** when you ring up another sale. Reconnect — it should drain back to **Synced**.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| "Unable to find suitable Visual Studio toolchain" during build | Install VS 2022 + Desktop development with C++ workload. |
| MSIX install fails: "App package is signed by..." / "trust" error | Either enable Developer Mode (Option A) or sign the MSIX (production). |
| Login fails with "Cannot reach server" | Click **Change** under Sign In and update the API base URL. |
| Sync pill stuck on **N queued** | Open the account menu → **Sync diagnostics**. Inspect the last error and click **Sync now**. |
| Receipts print blank or huge | Default is 80mm thermal width. For A4, choose A4 in the print dialog when **Print receipt** opens — the PDF is auto-fit. |
| Barcode scanner not detected | Scanners must emit Enter after the code. Confirm by typing in Notepad first. The listener is paused while a text field has focus. |
