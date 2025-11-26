# 🍽️ Restaurant Menu Engineering & Price Optimization

**ML-powered menu analysis platform that combines accurate revenue calculations with advanced price elasticity analysis.**

Processes restaurant transaction data to identify top performers, optimize pricing strategies, and maximize revenue using verified menu prices.

## 🚀 Quick Start

1. **Setup Environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Add Your Data**
   - Place transaction CSV files in `data/` folder
   - Ensure menu pricing CSV is in `menu_data/` folder

3. **Run Analysis**
   ```bash
   python run.py
   ```

4. **View Results**
   - Results saved in `output/` folder with timestamps
   - JSON file: Complete analysis data
   - MD file: Business summary report

## 📊 Analysis Features

### **Revenue Analysis**
- **100% Accurate Totals** - Revenue calculations match source data exactly
- **Verified Menu Prices** - Uses real menu pricing data for 60-80% of items
- **Top Performer Identification** - Revenue and quantity leaders with confidence levels
- **BCG Matrix Classification** - Stars, Plowhorses, Puzzles, Dogs categorization

### **Price Elasticity Analysis** *(requires 3+ months data)*
- **Demand Sensitivity** - How customers respond to price changes
- **Category-Specific Bounds** - Realistic elasticity ranges for food/alcohol/staples  
- **Statistical Validation** - Confidence intervals and significance testing
- **Verified Items Only** - Recommendations only for items with known menu prices

### **Business Insights**
- **Multi-file Processing** - Combines all CSV files in data folder
- **Time-series Analysis** - Revenue trends across multiple months
- **Data Quality Metrics** - Price accuracy and verification statistics
- **Actionable Recommendations** - Specific next steps with risk assessment

## 📁 Data Format

**Transaction Data (place in `data/` folder):**
```csv
Order No.,Items,My Amount (₹),Created
24537,"Veg Thali, Chapati",230.00,31 Oct 2025 01:30:00
```

**Menu Pricing (place in `menu_data/` folder):**
```csv
Name,Price
Veg Thali,110
Chapati,20
```

## 📊 Sample Output

**6-Month Combined Analysis:**
- **Total Revenue**: ₹31,167,275 (19,416 orders)
- **Price Accuracy**: 66.2% (555/839 items verified)
- **Top Performer**: Royalstag (180 Ml) - ₹629,590 revenue
- **Elasticity Analysis**: 34 items with statistically valid coefficients

## 🔧 Technical Stack

- **Python 3.11+** with Pandas, NumPy, SciPy, Scikit-learn
- **Price Elasticity**: Linear regression with statistical validation
- **Revenue Allocation**: Exact matching with verified menu prices
- **Output**: Timestamped JSON + Markdown reports

## 📈 Business Value

### **Immediate Actions**
- **Identify top revenue generators** with verified pricing data
- **Spot underperforming items** for menu optimization
- **Data-driven pricing foundation** for strategic decisions

### **Advanced Analytics** *(with 3+ months data)*
- **Price sensitivity analysis** for optimal pricing
- **Demand elasticity coefficients** for revenue forecasting
- **Statistical confidence levels** for risk-assessed recommendations

---

**📋 See `menu_ml_platform_architecture.md` for complete technical specification**