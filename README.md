# Project Title

**Stock Order Management App**

---

## Overview

This iOS application streamlines the end-to-end workflow for ordering, preparing, and delivering stock items across multiple restaurant branches. It supports three roles:

* **Branch Staff**: Place orders with item quantities and optional notes.
* **Kitchen Staff**: View pending orders, mark them as preparing/prepared, adjust prepared quantities, and add kitchen notes.
* **Delivery Staff**: Collect prepared orders, mark them as collected/delivered, and undo status if needed.

Key features include:

* Multi‑stage workflows with clear status transitions.
* Partial preparation: kitchen selects which items and quantities to send.
* Chronological branch order history with detailed drill‑in views.
* At‑a‑glance summary bars for each role’s screen.
* Undo functionality for mistaken status changes.

---

## Tech Stack

* **Language**: Swift 5
* **UI Framework**: UIKit
* **Architecture**: MVC with singleton `OrderManager` for shared data
* **Persistence**: In‑memory (no database) — easy to replace with Core Data or a network API
* **Dependency Management**: None (built‑in frameworks only)

---

## Getting Started

1. **Clone the Repository**

   ```bash
   git clone https://github.com/your-org/stock-order-app.git
   cd stock-order-app
   ```

2. **Open in Xcode**

   * Double‑click `StockOrderApp.xcodeproj` to open the project.
   * Select an iOS simulator or a connected device.

3. **Build & Run**

   * Press **⌘R** to compile and launch the app.

4. **Explore the Roles**

   * On launch, the home screen lets you navigate to branch ordering, kitchen, or delivery flows.
   * Use sample branches: Regent’s Street, Seven Dials Market, etc.

---

## Architecture Overview

```
[Branch Screens] ▶ OrderPageViewController ▶ Review & Submit ▶ OrderManager
   ↓
[Kitchen Screens] ▶ KitchenOrdersViewController ▶ PrepareOrderViewController ▶ OrderManager
   ↓
[Delivery Screens] ▶ DeliveryPageViewController ▶ OrderManager
```

* **OrderManager**: Singleton that holds an array of `PlacedOrder` models.
* **PlacedOrder**: Represents branchName, items, statuses, timestamps, and notes.
* **CustomStockItem**: Immutable name + mutable quantity.

---

## Contributing

1. Fork the repo and create a feature branch.
2. Ensure new code includes unit/UI tests where applicable.
3. Follow Swift style conventions (CamelCase, clear naming).
4. Submit a pull request describing your changes.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

