# Hetanshi Enterprise

A Flutter-based Inventory and Order Management System for Hetanshi Enterprise.

## Features
- **Dashboard**: Real-time overview of Revenue, Net Profit, and Expenses.
- **Order Management**: Create and track orders for different parties.
- **Expense Tracker**: manage business expenses and calculate profit.
- **Party & Product Management**: Manage catalogs of products and customer details.
- **Notifications**: System alerts and updates.
- **Reports**: Generate PDF reports (Invoices).

## Tech Stack
- **Framework**: Flutter (Dart)
- **Backend**: Firebase Firestore
- **State Management**: setState / Streams

## Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/hetanshi-enterprise.git
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Setup Firebase**:
    - This project relies on Firebase.
    - You will need to provide your own `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
    - Generate `firebase_options.dart` using FlutterFire CLI.
4.  **Run the app**:
    ```bash
    flutter run
    ```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
