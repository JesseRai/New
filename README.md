# Company Financial Dashboard – SQL Scripts

This repository stores the SQL data model behind the [Company Financial Dashboard](https://public.tableau.com/app/profile/jesse.rai/viz/CompanyFinancialDashboard_17570199628260/Dashboard1) on Tableau Public.

## About the Dashboard

The dashboard visualizes a company’s financial performance using interactive filters. Select a **year** and **company** (e.g., *AAPL*) from the sidebar to update the views.

Key sections include:

- **Key Performance Metrics** – cards summarizing total revenue, gross profit, cost of goods sold (COGS), net income, EBITDA, and total debt with year‑over‑year (YoY) changes.
- **Leverage & Capital Structure** – line and scatter charts showing debt versus shareholder’s equity and debt versus market capitalization over time.
- **Financial Health Indicators** – ratios such as current ratio, debt‑to‑equity (D/E), return on equity (ROE), return on assets (ROA), and net profit margin.

Together these components highlight profitability, leverage, and liquidity trends across years.

## SQL Structure

The `SQL` folder contains separate files for each table and view used by the dashboard:

- `company_financials.sql` – base table storing raw financial data (revenue, profit, ratios, market cap, etc.).
- `vw_balance_overview.sql` – view calculating total debt from the debt‑to‑equity ratio and shareholder’s equity.
- `vw_income_statement.sql` – view deriving income statement elements (revenue, COGS, EBITDA, etc.).
- `vw_kpi_all.sql` – view exposing key performance indicators in a flat structure.
- `vw_kpi_yoy.sql` – view computing year‑over‑year changes for KPIs with lag functions.
- `vw_ratios_trend.sql` – view summarizing financial ratios by year for trend charts.
- `vw_timeseries_core.sql` – view generating time‑series data for the leverage and market capitalization charts.

These SQL scripts can be executed to build the data model in a database prior to connecting it to Tableau.
