# Smart Inventory & Stock Replenishment App

A full-featured Flutter inventory management application for small retail stores, labs, and campus facilities.

---

## 📱 Features

### 5 Screens
1. **Dashboard** — Overview with stats, low-stock alerts, recent activity, and stock distribution chart
2. **Products** — Full CRUD with swipe-to-edit/delete, stock progress bars, and category icons
3. **Stock Update** — Tabbed Stock In / Stock Out with validation and product selector
4. **History** — Filterable transaction log with date grouping and summary stats
5. **Search & Filter** — Real-time search + filter by category and stock status

### Core Functionality
- ✅ Add / Edit / Delete products with name, category, qty, threshold, unit, cost
- ✅ Stock In / Stock Out with notes and automatic quantity update
- ✅ Low stock alerts (≤ threshold) with Critical / Warning / Normal indicators
- ✅ Dashboard showing totals, low-stock count, and recent 6 transactions
- ✅ Full stock history with date headers and before→after quantities
- ✅ Search by name + filter by category/status simultaneously
- ✅ Offline-first with Hive local storage (no internet needed)
- ✅ Validation: no negative stock, required fields, invalid input messages
- ✅ Demo data auto-seeded on first launch

### Color Indicators
| Status | Color | Trigger |
|--------|-------|---------|
| 🟢 In Stock | `#00D4AA` | qty > threshold × 1.5 |
| 🟡 Low Stock | `#FFB800` | qty ≤ threshold × 1.5 |
| 🟠 Critical | `#FF6B35` | qty ≤ threshold |
| 🔴 Out of Stock | `#FF4757` | qty ≤ 0 |

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| State Management | **Riverpod 2** (StateNotifier + Provider) |
| Local Storage | **Hive** (offline-first) |
| Architecture | Feature-modular (models / services / providers / screens / widgets) |
| UI | Custom dark theme, Sora font, animated nav bar |

---

## 🚀 Setup

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0

### 1. Clone & Install
```bash
git clone <repo>
cd smart_inventory
flutter pub get
```

### 2. Add Sora Font
Download from Google Fonts: https://fonts.google.com/specimen/Sora

Place in `assets/fonts/`:
- `Sora-Regular.ttf`
- `Sora-Medium.ttf`
- `Sora-SemiBold.ttf`
- `Sora-Bold.ttf`

Or use a fallback — the app will use system font if Sora is unavailable.

### 3. Run
```bash
flutter run
```

### 4. Build APK
```bash
flutter build apk --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point, navigation shell
├── models/
│   ├── product.dart             # Product model + StockStatus enum
│   ├── product.g.dart           # Hive adapter
│   ├── stock_log.dart           # StockLog model
│   └── stock_log.g.dart         # Hive adapters
├── services/
│   └── inventory_service.dart   # All data operations (Hive CRUD)
├── providers/
│   └── inventory_providers.dart # Riverpod providers & notifiers
├── screens/
│   ├── dashboard_screen.dart    # Screen 1
│   ├── product_management_screen.dart  # Screen 2
│   ├── add_edit_product_screen.dart    # Product form
│   ├── stock_update_screen.dart        # Screen 3
│   ├── stock_history_screen.dart       # Screen 4
│   └── search_filter_screen.dart       # Screen 5
├── widgets/
│   ├── product_card.dart        # Swipeable product card
│   └── stock_status_badge.dart  # Status badge + progress bar
└── utils/
    └── app_theme.dart           # Theme, colors, status extensions
```

---

## 🔌 Optional Backend (Firebase)

The app is offline-first using Hive. To add Firebase sync:

1. Add `firebase_core` and `cloud_firestore` to pubspec.yaml
2. In `InventoryService`, after each write operation, also write to Firestore
3. Use the `synced` field on `StockLog` to track pending sync
4. Add `connectivity_plus` listener to trigger batch sync when online

---

## 📸 Demo Data

On first launch, 8 products are auto-created across categories (Medicine, Hygiene, Stationery, etc.) with varied stock levels — some normal, some low, and one out-of-stock — to demonstrate all features immediately.
