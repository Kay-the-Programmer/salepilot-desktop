# SalePilot POS — Desktop (Flutter / Windows)

Offline-first Windows desktop client for the SalePilot POS, talking to the
existing `s-back` REST API.

## What's implemented

Per [`FLUTTER_DESKTOP_PLAN.md`](../FLUTTER_DESKTOP_PLAN.md):

- **M1 — Scaffold + connectivity**: Riverpod, Dio, secure JWT storage, login.
- **M2 — Catalog & cart**: Drift (SQLite) local cache, product grid, search,
  cart with weighed-item support, totals (subtotal, discount %/amount, tax,
  store credit, cash + change).
- **M3 — Online sale completion**: `POST /api/sales` with client-generated
  `transactionId`, receipt dialog, 80mm thermal PDF print via `printing`.
- **M4 — Offline + sync engine**: every sale is committed locally first, then
  pushed via a sync queue with exponential backoff, 409-idempotency handling,
  and a live status pill in the title bar (Online · Synced / N queued /
  Offline · N queued / Sync error).
- **M5 — HID scanner + held sales + polish**: USB/Bluetooth keyboard-wedge
  barcode scanners are auto-detected via burst-typing heuristic; held sales
  persist across restarts in SQLite.

## Prerequisites

1. **Flutter 3.44+** with Windows desktop enabled (`flutter config --enable-windows-desktop`).
2. **Visual Studio 2022 Community** with the **"Desktop development with C++"** workload —
   required to compile native Windows builds. Without it `flutter run -d windows` will fail.
3. A reachable `s-back` instance (defaults to `http://localhost:5000/api`).

## Run

```powershell
cd salepilot_desktop
flutter pub get
flutter run -d windows
```

To override the API URL at build time:

```powershell
flutter run -d windows --dart-define=API_BASE_URL=https://s-back-q0gg.onrender.com/api
```

The login screen also has an in-app "Change" link that lets a cashier point
the app at a different server URL at runtime.

## Test

```powershell
flutter analyze   # 0 issues
flutter test      # cart math + widget smoke tests
```

## Layout

```
lib/
├── main.dart                 Window setup, ProviderScope root
├── app.dart                  Root MaterialApp + session restore gate
├── app_providers.dart        Database, repository, sync engine providers
├── core/                     config, theme, logger
├── data/
│   ├── api/                  Dio client + ApiException
│   ├── db/                   Drift schema (app_database.dart + .g.dart)
│   ├── models/               Product, Category, Customer, Sale, StoreSettings
│   ├── repositories/         Products, Customers, Settings, Sales (idempotent)
│   ├── storage/              flutter_secure_storage wrapper
│   └── sync/                 SyncEngine — drain queue, backoff, status stream
├── features/
│   ├── auth/                 Login screen + AuthController
│   └── pos/                  POS screen, cart controller, receipt PDF
│       └── widgets/          ProductGrid, CartPanel, CheckoutPanel,
│                             ReceiptDialog, HeldSalesDialog, SyncStatusPill,
│                             BarcodeListener
└── shared/                   currency formatting helpers
```

## What's deliberately deferred

- **Lenco mobile money** is shown as a regular payment method (manual confirm
  via reference string). The web app's JS widget + verification polling is not
  ported in v1.
- **Mac/Linux builds** — only Windows is enabled.
- **Auto-update / code-signing** — manual install for now.
- **Camera barcode scanning** — only USB/Bluetooth HID scanners. A later
  iteration can add `mobile_scanner` if needed.
- **Multi-store switcher** — uses the user's current store from the JWT.

## Backend contract

No backend changes are required to run the app, but two enhancements would
harden offline sync:

1. `POST /api/sales` should treat a duplicate `transactionId` as idempotent —
   return the existing sale instead of creating a duplicate. (The client
   already treats HTTP 409 as success.)
2. Optional: `GET /api/products?updatedSince=<iso>` for incremental pulls
   instead of full-cache replacement.
