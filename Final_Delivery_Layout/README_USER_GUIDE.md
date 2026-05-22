# 🚀 Academix v13.2 — User Quick-Start Guide
**Decision Support System (DSS) for Inventory Management**
*Direction de l'Education, Wilaya de El Bayadh*

---

## 📝 Overview
Academix v13.2 is a specialized Decision Support System designed to optimize inventory management and supply chain logistics. It replaces manual tracking with an automated, data-driven approach to ensure resource availability and minimize waste.

## 🛠️ Getting Started
1. **Open the File**: Double-click `ERP_v13.2.xlsm`.
2. **Enable Content**: Since this system uses advanced VBA (Visual Basic for Applications), you **MUST** click **"Enable Content"** or **"Enable Macros"** in the yellow warning bar at the top of Excel.
3. **Environment**: For best performance, use **Microsoft Excel 2010 or newer** on Windows.

## 🔄 Core Workflow
The system operates in a linear data flow:
**Data Input** $\rightarrow$ **Analytical Processing** $\rightarrow$ **DSS Output**

### 1. Data Input (Saisie des Données)
- Navigate to the **Input sheets**.
- Enter current stock levels, incoming shipments, and outgoing distributions.
- Ensure all fields are filled correctly to avoid calculation errors.

### 2. Processing (Traitement)
- The system automatically calculates metrics based on the **Economic Order Quantity (EOQ)** and **Reorder Point (ROP)** models.
- It analyzes lead times (LT) and consumption rates to predict future needs.

### 3. DSS Output (Aide à la Décision)
- View the **Dashboard** to see real-time stock status.
- Check the **Alerts** for items that have reached their reorder point.
- Generate **Reports** for administrative review.

## ⚙️ System Parameters (Ground Truth)
The system is calibrated with the following optimized parameters:
- **Average Demand (D)**: 1,546 units
- **Order Cost (S)**: 801.45 DZD
- **Holding Cost (I)**: 20%
- **Lead Time (LT)**: 2 days
- **Reorder Point (ROP)**: 212.4 units

## 🆘 Support & Troubleshooting
- **Stale Data**: If calculations seem incorrect, please rebuild the workbook from the source files using the provided `build.ps1` script (for admins).
- **Macro Error**: Ensure that no other conflicting Excel Add-ins are running.
- **Contact**: For technical support, contact the system administrator.

---
*Version: v13.2 | Status: FINAL | Delivery: 2026*
