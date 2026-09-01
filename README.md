<div align="center">
📦 Supply Chain Analytics
Power BI • SQL • DAX • PostgreSQL
<p>
  <img src="https://img.shields.io/badge/Power%20BI-Executive%20Analytics-F2C811?style=for-the-badge&logo=powerbi&logoColor=000000" alt="Power BI">
  <img src="https://img.shields.io/badge/DAX-Business%20Logic-7B61FF?style=for-the-badge" alt="DAX">
  <img src="https://img.shields.io/badge/SQL-Analytics-336791?style=for-the-badge&logo=postgresql&logoColor=white" alt="SQL">
  <img src="https://img.shields.io/badge/PostgreSQL-Data%20Layer-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/GitHub-Portfolio-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub">
</p>
<p>
  <strong>An end-to-end supply chain analytics solution that turns operational data into management decisions.</strong>
</p>
<p>
  <a href="#-executive-story">Executive Story</a> •
  <a href="#-dashboard">Dashboard</a> •
  <a href="#-business-findings">Findings</a> •
  <a href="#-recommendations">Recommendations</a> •
  <a href="#-technical-implementation">Technical</a> •
  <a href="#-repository-structure">Repository</a>
</p>
</div>
---
🎯 Executive Story
This project was designed around a simple management question:
> **Where is the supply chain underperforming, what is the business impact, and what should management do next?**
The Power BI solution combines revenue, procurement, supplier performance, inventory, replenishment and logistics into a single decision-support environment.
🚨 The headline
KPI	Current position	Management signal
🚚 On-Time Delivery	56.57%	🔴 6.2 pts below 90% target
⏰ Late Shipments	304	🔴 Service-level risk
📦 Products Requiring Reorder	11	🔴 Availability risk
💷 At-Risk Inventory Value	£93K	🟠 Working-capital exposure
🛒 Procurement Spend	£3.20M	🟠 Supplier concentration matters
🤝 Suppliers	8	🔵 Performance varies materially
---
📊 Dashboard
The report contains six stakeholder-focused pages. Each page answers a different business question rather than simply presenting charts.
01 · Executive Overview
Question: How healthy is the supply chain overall?
![Executive Overview](powerbi/screenshots/executive_overview.png)
Focus: revenue, gross profit, procurement, inventory health, delivery performance and management attention.
---
02 · Procurement & Supplier Performance
Question: Which suppliers require commercial or operational intervention?
![Procurement & Supplier Performance](powerbi/screenshots/procurement_supplier_performance.png)
Focus: supplier spend, lead time, on-time delivery, supplier risk and action priorities.
---
03 · Inventory & Stock Performance
Question: Where is inventory tied up and where are stock risks emerging?
![Inventory & Stock Performance](powerbi/screenshots/inventory_stock_performance.png)
Focus: inventory value, stock health, reorder requirements and replenishment priorities.
---
04 · Logistics & Delivery Performance
Question: Why are deliveries late and where should logistics intervene?
![Logistics & Delivery Performance](powerbi/screenshots/logistics_delivery_performance.png)
Focus: shipment reliability, delivery days, late shipments, supplier performance and transportation cost.
---
05 · Inventory & Stock Management
Question: Which products need action first?
![Inventory & Stock Management](powerbi/screenshots/inventory_stock_management.png)
Focus: priority classification, stock coverage, inventory risk and Top-5 replenishment priorities.
---
06 · Business Findings & Recommendations
Question: What should management do next?
![Business Findings & Recommendations](powerbi/business_recommendations_page.png)
Focus: prioritized findings, business impact, recommended actions, ownership and urgency.
---
🔎 Business Findings
1. 🚚 Delivery reliability is the primary operational risk
On-time delivery is 56.57%, materially below the 90% target, with 304 late shipments.
Business implication: customer service, production planning and inventory availability can all be affected by unreliable inbound/outbound delivery.
---
2. 🤝 Supplier performance is uneven
Supplier delivery performance ranges from approximately 50% to 62%, creating a meaningful difference in operational reliability.
The biggest concern is not simply a low-performing supplier — it is the combination of:
high procurement spend + weak delivery performance
That combination deserves immediate management attention.
---
3. 📦 Inventory requires targeted intervention
11 products require replenishment, while approximately £93K of inventory is identified as at-risk.
Management should prioritize the largest stock shortfalls and highest-business-impact products rather than treating every SKU equally.
---
4. 💷 Procurement concentration creates exposure
Total procurement spend is approximately £3.20M.
Metro IT Supply represents the largest current supplier spend while also showing weak delivery reliability. This creates a clear opportunity to review supplier allocation and contingency options.
---
5. 🚛 Logistics needs SLA-level management
The logistics analysis shows that delivery performance should be managed using a combination of:
promised days
actual delivery days
on-time status
late shipment volume
supplier performance
transportation cost
A single OTD percentage is not enough to diagnose the underlying problem.
---
🧭 Recommendations
Priority	Recommendation	Owner	Timing	Expected outcome
🔴 1	Launch corrective-action plans for the weakest supplier delivery performers	Procurement	Immediate	Improve supplier OTD
🔴 2	Expedite the Top-5 replenishment priorities	Supply Planning	Immediate	Reduce stockout risk
🟠 3	Review high-spend / low-service supplier dependency	Procurement	30–60 days	Reduce concentration risk
🟠 4	Review carrier and shipment SLA performance	Logistics	30 days	Reduce late deliveries
🔵 5	Establish a monthly executive supply-chain scorecard	Operations	Monthly	Sustain performance improvement
Recommended management sequence
```text
              IDENTIFY
                  │
                  ▼
        🔴 Delivery reliability
                  │
                  ▼
        🔴 Supplier intervention
                  │
                  ▼
        🔴 Protect inventory availability
                  │
                  ▼
        🟠 Diversify / renegotiate supply
                  │
                  ▼
        🔵 Monitor through executive KPIs
```
---
💡 KPI Scorecard
KPI	Definition
Total Revenue	Total revenue for the selected period
Gross Profit	Revenue less applicable product cost
Gross Profit Margin %	Gross Profit ÷ Revenue
Total Orders	Number of customer orders
Total Procurement Spend	Sum of purchase-order value
Current Stock Units	Units currently held in inventory
Products Requiring Reorder	Products where current stock is below reorder point
On-Time Delivery %	On-time shipments ÷ total shipments
Average Lead Time	Average procurement lead time
Inventory Value	Current stock units × applicable unit value
At-Risk Inventory Value	Inventory value associated with items requiring intervention
Late Shipments	Shipments delivered later than the promised delivery time
---
🛠️ Technical Implementation
Architecture
```text
┌──────────────────────┐
│   Source Data        │
│ Products / Orders    │
│ Inventory / Shipments│
│ Suppliers            │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ PostgreSQL / SQL     │
│ Validation + Analysis│
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Power BI Data Model  │
│ Relationships + KPIs │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ DAX Measures         │
│ Business Rules       │
│ Risk / Priority Logic│
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Executive Dashboard  │
│ Insights → Actions   │
└──────────────────────┘
```
Technology stack
<p>
  <img src="https://img.shields.io/badge/Microsoft%20Power%20BI-F2C811?style=flat-square&logo=powerbi&logoColor=000000" alt="Microsoft Power BI">
  <img src="https://img.shields.io/badge/DAX-7B61FF?style=flat-square" alt="DAX">
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=flat-square&logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/SQL-336791?style=flat-square&logo=postgresql&logoColor=white" alt="SQL">
  <img src="https://img.shields.io/badge/GitHub-181717?style=flat-square&logo=github&logoColor=white" alt="GitHub">
</p>
Data model
Core analytical entities include:
`core products`
`core product_supplier`
`core orders`
`core inventory`
`core purchase_orders`
`core shipments`
The model supports analysis across commercial performance → procurement → inventory → logistics.
See `documentation/data_model.md`.
---
🧮 DAX
The project uses DAX for:
executive KPI calculations
on-time delivery
inventory health
reorder identification
stock shortfall
supplier risk
supplier ranking
management-action classification
All documented measures are available in:
👉 `dax/measures.md`
The documentation also captures the circular-dependency issue encountered during development and the corrected approach for separating row-level logic from ranking measures.
---
🗄️ SQL
SQL is used for data validation and analytical investigation.
Script	Purpose
`01_data_quality.sql`	Data checks and validation
`02_procurement_supplier.sql`	Supplier spend, lead time and performance
`03_inventory.sql`	Stock levels, shortfalls and inventory risk
`04_logistics.sql`	Shipment, delivery and carrier analysis
👉 Browse the `sql/` folder.
---
🎨 Dashboard Design System
The dashboard uses an executive-oriented visual system designed to keep attention on exceptions and decisions.
Element	Colour	Purpose
Header / structure	`#0B2239`	Executive navigation and hierarchy
Operational blue	`#2F80ED`	Neutral KPIs / analytical visuals
Healthy green	`#27AE60`	Good performance / healthy stock
Warning amber	`#F2B134`	Monitor / moderate risk
Critical red	`#D64545`	Immediate action
Page background	`#F4F6F8`	Clean canvas
Visual container	`#FFFFFF`	Separation and readability
Design principle: red and amber are reserved for exceptions so management can identify problems quickly.
---
📁 Repository Structure
```text
supply-chain-analytics-powerbi/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── data/
│   └── README.md
│
├── sql/
│   ├── 01_data_quality.sql
│   ├── 02_procurement_supplier.sql
│   ├── 03_inventory.sql
│   └── 04_logistics.sql
│
├── dax/
│   └── measures.md
│
├── powerbi/
│   ├── Supply_Chain_Analytics.pbix
│   ├── README.md
│   ├── business_recommendations_build_spec.md
│   ├── business_recommendations_page.png
│   └── screenshots/
│       ├── executive_overview.png
│       ├── procurement_supplier_performance.png
│       ├── inventory_stock_performance.png
│       ├── logistics_delivery_performance.png
│       └── inventory_stock_management.png
│
└── documentation/
    ├── data_model.md
    ├── business_findings.md
    └── recommendations.md
```
> **Note:** The PBIX file may be large. Git LFS is recommended if the file exceeds normal Git hosting limits.
---
📚 Documentation
Resource	What it contains
📐 `data_model.md`	Model structure and analytical relationships
💼 `business_findings.md`	Key findings from the dashboard
🎯 `recommendations.md`	Management actions and priorities
🧮 `measures.md`	DAX measures and business logic
🗄️ `sql/`	SQL validation and analysis
📊 `powerbi/`	PBIX guidance and dashboard assets
---
🚀 How to Use
1. Clone the repository
```bash
git clone https://github.com/YashPrajapati989/supply-chain-analytics-powerbi.git
cd supply-chain-analytics-powerbi
```
2. Open the Power BI report
Open:
```text
powerbi/Supply_Chain_Analytics.pbix
```
3. Review the model
Inspect the relationships between products, suppliers, procurement, inventory, orders and shipments.
4. Explore the six dashboard pages
Start with Executive Overview, then move through procurement, inventory and logistics before finishing with Business Findings & Recommendations.
5. Review the technical documentation
Use the SQL and DAX folders to understand how the business logic was implemented.
---
🏆 What This Project Demonstrates
This portfolio project demonstrates the ability to move through the complete analytics lifecycle:
Data → SQL → Data Model → DAX → Visualization → Insight → Recommendation
Technical skills
Power BI dashboard development
DAX measure design
SQL analytical querying
PostgreSQL data analysis
KPI design
Data modelling
Conditional / risk logic
Executive reporting
Business skills
Supplier performance management
Inventory risk analysis
Replenishment prioritization
Logistics performance analysis
Procurement risk assessment
Executive storytelling
Action-oriented recommendations
---
👤 Author
<div align="center">
Yash Prajapati
Data Analytics • Power BI • SQL • DAX
Building business-focused analytics solutions that connect data, insight and action.
</div>
---
<div align="center">
⭐ If this project is useful, consider giving the repository a star.
Supply Chain Analytics — From operational data to management action.
</div>
