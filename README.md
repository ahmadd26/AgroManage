# AgroManage – Agriculture Shop Management System

> **Application**: Mobile Shop & Inventory Management System  
> **Target Audience**: Agrochemical Dealers, Fertilizer Distributors & Kisan Centers  
> **Repository**: [https://github.com/ahmadd26/AgroManage](https://github.com/ahmadd26/AgroManage)

---

## 🌾 Project Overview

**AgroManage** is a modern Flutter mobile application designed specifically for agricultural retail shops and dealerships (*Kisan Agro Centers*). 

Running an agriculture dealership presents unique challenges compared to standard retail:
- Products have strict **expiry dates** and batch numbers (e.g. pesticides, insecticides, fungicide).
- Farmers buy seeds and fertilizers on seasonal **Khata (Credit)** and pay back after the harvesting season via installments.
- Strict inventory management with **minimum stock alerts** to avoid shortages during peak sowing periods.

AgroManage provides an all-in-one mobile solution to handle billing, inventory, farmer accounts, supplier purchases, and daily store expenses.

---

## ✨ Key Features & Modules

### 1. 📊 Executive Dashboard
- **Financial Metrics**: Real-time totals for today's gross sales, cash received, outstanding farmer balances, and expenses.
- **Stock & Expiry Alerts**: Interactive alert cards highlighting low-stock items and chemicals nearing expiration (within 90 days).
- **Recent Activity**: Quick overview of the latest invoices and customer transactions.

### 2. 🛒 Point of Sale (POS) & Smart Invoicing
- **Quick Billing**: Add items to cart with dynamic quantity adjustments and automatic price calculation.
- **Farmer Balance Detection**: Select a customer to immediately view their current credit balance.
- **Multiple Payment Channels**: Support for **Cash**, **Bank Transfer**, and **Credit Khata** (Udhaar).
- **Inventory Synchronization**: Stock is automatically deducted upon invoice confirmation.

### 3. 📦 Inventory & Product Catalog
- **Categorization**: Hybrid Seeds, Chemical Fertilizers, Liquid Pesticides, Spray Equipment, and Growth Regulators.
- **Batch & Expiry Control**: Every product tracks unit types (Bags, Liters, Kg, Bottles), min stock levels, and expiration dates.
- **Product Management**: Interactive forms to add, edit, or adjust inventory.

### 4. 👨‍🌾 Farmer Khata (Credit) & Installments
- **Customer Profiles**: Complete ledger showing contact info, land area, total purchases, and outstanding dues.
- **Harvest-Linked Installments**: Structured installment plans aligned with crop cycles (Wheat, Cotton, Rice, Maize).
- **Record Payments**: Easy workflow to log partial or full payments, automatically updating pending balances.

### 5. 🚚 Supplier Purchases & Expense Tracker
- **Supplier Directory**: Contact info and representation records for agrochemical manufacturers and distributors.
- **Purchase Orders**: Log incoming shipments to restock inventory with cost and selling price margins.
- **Expense Logging**: Track operational expenses such as tube-well power, generator fuel, warehouse rent, and transport.

---

## 🛠️ Technology Stack & Architecture

- **Framework**: Flutter 3.47+ / Dart 3.13+
- **Platform**: Android (minSdk: 21, targetSdk: 34, compileSdk: 34)
- **Design System**: Material Design 3 (`AppTheme`) with responsive layout shell
- **State Management**: Centralized reactive in-memory state (`ChangeNotifier` / `AppState`)

```
lib/
├── main.dart                  # Application entry point & theme initialization
├── models/                    # Data models (Product, Customer, Invoice, Expense, etc.)
│   ├── customer.dart
│   ├── expense.dart
│   ├── invoice.dart
│   ├── product.dart
│   ├── purchase.dart
│   └── supplier.dart
├── state/
│   └── app_state.dart         # Global reactive business logic & initial mock data
├── theme/
│   └── app_theme.dart         # Custom colors, typography, and card styles
├── widgets/
│   └── custom_widgets.dart    # Reusable MetricCard, StatusBadge, SectionHeader
└── screens/                   # Application screens (18 interactive screens)
    ├── dashboard_screen.dart
    ├── pos_screen.dart
    ├── products_screen.dart
    ├── customers_screen.dart
    ├── invoices_screen.dart
    ├── installments_screen.dart
    ├── expenses_screen.dart
    ├── reports_screen.dart
    └── ...
```

---

## 🚀 How to Run the Application

### Prerequisites
1. [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.47.0 or newer).
2. [Android Studio](https://developer.android.com/studio) with Android SDK and an Android Virtual Device (AVD).

### Execution Steps
1. **Clone the repository**:
   ```bash
   git clone https://github.com/ahmadd26/AgroManage.git
   cd AgroManage
   ```

2. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify the environment**:
   ```bash
   flutter doctor
   ```

4. **Launch on an Android Emulator or Physical Device**:
   ```bash
   # Launch available emulator
   flutter emulators --launch Pixel_5

   # Run the app
   flutter run
   ```
