CREATE OR REPLACE TABLE company_financials (
    year                     integer              NOT NULL,
    company                  text                 NOT NULL,   -- e.g., AAPL
    category                 text,                              -- sector / industry
    market_cap               numeric(18,2),                     -- Market Cap
    revenue                  numeric(10,2),                            -- Revenue
    gross_profit             numeric(10,2),                            -- Gross Profit
    net_income               numeric(10,2),                            -- Net Income
    eps                      numeric(10,2),                     -- Earnings Per Share
    ebitda                   numeric(10,2),                            -- EBITDA
    shareholders_equity      numeric(10,2),                            -- Share Holder Equity (Total Equity)
    cash_flow_operating      numeric(10,2),                            -- Cash Flow from Operating Activities
    cash_flow_investing      numeric(10,2),                            -- Cash Flow from Investing Activities
    cash_flow_financing      numeric(10,2),                            -- Cash Flow from Financing Activities
    current_ratio            numeric(10,4),                     -- Current Ratio
    debt_to_equity           numeric(10,4),                     -- Debt/Equity
    roe                      numeric(10,4),                     -- Return on Equity
    roa                      numeric(10,4),                     -- Return on Assets
    roi                      numeric(10,4),                     -- Return on Investment
    net_profit_margin        numeric(10,4),                     -- Net Profit Margin (as a fraction, not %)
    free_cash_flow           numeric(10,4),                            -- Free Cash Flow
    return_on_total_assets   numeric(10,4),                     -- “Return on Ta...” (interpreted as ROA alt)
    employees                integer,                           -- Number of Employees
    us_inflation_rate        numeric(10,4),                     -- Inflation Rate (in US)

    CONSTRAINT company_financials_pk PRIMARY KEY (company, year)
);


CREATE OR REPLACE VIEW vw_income_statement AS
SELECT
    company,
    year,
    revenue,
    (revenue - gross_profit) AS cogs,                           -- Cost of Goods Sold
    (gross_profit - ebitda)  AS operating_expenses_and_da,      -- OpEx + D&A
    (ebitda - net_income)    AS taxes,                          -- Below-the-line (interest + tax)
    -- Subtotals (big bars)
    gross_profit    AS gross_margin,        -- Revenue – COGS
    ebitda          AS operating_income,    -- Gross Profit – OpEx – D&A
    net_income

FROM company_financials;




CREATE VIEW vw_balance_overview AS
SELECT
	company,
	year,
	shareholders_equity,
	CASE
		WHEN debt_to_equity IS NOT NULL AND shareholders_equity IS NOT NULL
			THEN debt_to_equity * shareholders_equity
	END AS total_debt,
	market_cap
FROM company_financials;


CREATE OR REPLACE VIEW vw_ratios_trend AS
WITH base AS (
  SELECT
    company, year,
    current_ratio,
    debt_to_equity,
    roe, roa, roi, net_profit_margin
  FROM company_financials
),
lagged AS (
  SELECT
    b.*,
    LAG(current_ratio)     OVER (PARTITION BY company ORDER BY year) AS prev_current_ratio,
    LAG(debt_to_equity)    OVER (PARTITION BY company ORDER BY year) AS prev_dte,
    LAG(roe)               OVER (PARTITION BY company ORDER BY year) AS prev_roe,
    LAG(roa)               OVER (PARTITION BY company ORDER BY year) AS prev_roa,
    LAG(roi)               OVER (PARTITION BY company ORDER BY year) AS prev_roi,
    LAG(net_profit_margin) OVER (PARTITION BY company ORDER BY year) AS prev_npm
  FROM base b
)
SELECT
  company, year,
  current_ratio,
  debt_to_equity,
  roe, roa, roi, net_profit_margin,

  -- absolute change
  (current_ratio     - prev_current_ratio)     AS delta_current_ratio,
  (debt_to_equity    - prev_dte)               AS delta_dte,
  (roe               - prev_roe)               AS delta_roe,
  (roa               - prev_roa)               AS delta_roa,
  (roi               - prev_roi)               AS delta_roi,
  (net_profit_margin - prev_npm)               AS delta_npm,

  -- YoY percentage change
  (current_ratio     - prev_current_ratio)     / NULLIF(prev_current_ratio, 0) AS yoy_current_ratio,
  (debt_to_equity    - prev_dte)               / NULLIF(prev_dte,            0) AS yoy_dte,
  (roe               - prev_roe)               / NULLIF(prev_roe,           0) AS yoy_roe,
  (roa               - prev_roa)               / NULLIF(prev_roa,           0) AS yoy_roa,
  (roi               - prev_roi)               / NULLIF(prev_roi,            0) AS yoy_roi,
  (net_profit_margin - prev_npm)               / NULLIF(prev_npm,            0) AS yoy_npm
FROM lagged;


CREATE VIEW vw_timeseries_core AS
SELECT
  company,
  year,
  revenue,
  gross_profit,
  net_income,
  ebitda,
  free_cash_flow
FROM company_financials
ORDER BY company, year;

CREATE VIEW vw_kpi_all AS
SELECT
  company,
  year,
  revenue,
  gross_profit,
  (revenue - gross_profit)            AS cogs,
  net_income,
  ebitda,
  eps,
  market_cap,
  free_cash_flow,
  roe, roa, roi, net_profit_margin,
  debt_to_equity,
  shareholders_equity,
  -- Estimate of total debt from D/E × Equity
  (debt_to_equity * shareholders_equity) AS total_debt_est
FROM company_financials;


CREATE VIEW vw_kpi_yoy AS
WITH base AS (
  SELECT
    company, year,
    revenue,
    gross_profit,
    (revenue - gross_profit)                 AS cogs,
    net_income,
    ebitda,
    market_cap,
    roe, roa, roi, net_profit_margin,
    debt_to_equity,
    shareholders_equity,
    (debt_to_equity * shareholders_equity)   AS total_debt_est
  FROM company_financials
),
lagged AS (
  SELECT
    b.*,
    LAG(revenue)          OVER (PARTITION BY company ORDER BY year) AS prev_revenue,
    LAG(gross_profit)     OVER (PARTITION BY company ORDER BY year) AS prev_gross_profit,
    LAG(cogs)             OVER (PARTITION BY company ORDER BY year) AS prev_cogs,
    LAG(net_income)       OVER (PARTITION BY company ORDER BY year) AS prev_net_income,
    LAG(ebitda)           OVER (PARTITION BY company ORDER BY year) AS prev_ebitda,
    LAG(market_cap)       OVER (PARTITION BY company ORDER BY year) AS prev_market_cap,
    LAG(total_debt_est)   OVER (PARTITION BY company ORDER BY year) AS prev_total_debt_est,
    LAG(roe)              OVER (PARTITION BY company ORDER BY year) AS prev_roe,
    LAG(roa)              OVER (PARTITION BY company ORDER BY year) AS prev_roa,
    LAG(roi)              OVER (PARTITION BY company ORDER BY year) AS prev_roi,
    LAG(net_profit_margin)OVER (PARTITION BY company ORDER BY year) AS prev_npm
  FROM base b
)
SELECT
  *,
  (revenue        - prev_revenue)        / NULLIF(prev_revenue,0)        AS yoy_revenue,
  (gross_profit   - prev_gross_profit)   / NULLIF(prev_gross_profit,0)   AS yoy_gross_profit,
  (cogs           - prev_cogs)           / NULLIF(prev_cogs,0)           AS yoy_cogs,
  (net_income     - prev_net_income)     / NULLIF(prev_net_income,0)     AS yoy_net_income,
  (ebitda         - prev_ebitda)         / NULLIF(prev_ebitda,0)         AS yoy_ebitda,
  (market_cap     - prev_market_cap)     / NULLIF(prev_market_cap,0)     AS yoy_market_cap,
  (total_debt_est - prev_total_debt_est) / NULLIF(prev_total_debt_est,0) AS yoy_total_debt,
  (roe            - prev_roe)                                             AS delta_roe,  -- ratios: absolute delta
  (roa            - prev_roa)                                             AS delta_roa,
  (roi            - prev_roi)                                             AS delta_roi,
  (net_profit_margin - prev_npm)                                          AS delta_npm
FROM lagged;

