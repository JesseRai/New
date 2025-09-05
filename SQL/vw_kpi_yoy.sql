CREATE VIEW vw_kpi_yoy AS
WITH base AS (
    SELECT
        company,
        year,
        revenue,
        gross_profit,
        (revenue - gross_profit) AS cogs,
        net_income,
        ebitda,
        market_cap,
        roe, roa, roi, net_profit_margin,
        debt_to_equity,
        shareholders_equity,
        (debt_to_equity * shareholders_equity) AS total_debt_est
    FROM company_financials
),
lagged AS (
    SELECT
        b.*,
        LAG(revenue)        OVER (PARTITION BY company ORDER BY year) AS prev_revenue,
        LAG(gross_profit)   OVER (PARTITION BY company ORDER BY year) AS prev_gross_profit,
        LAG(cogs)           OVER (PARTITION BY company ORDER BY year) AS prev_cogs,
        LAG(net_income)     OVER (PARTITION BY company ORDER BY year) AS prev_net_income,
        LAG(ebitda)         OVER (PARTITION BY company ORDER BY year) AS prev_ebitda,
        LAG(market_cap)     OVER (PARTITION BY company ORDER BY year) AS prev_market_cap,
        LAG(total_debt_est) OVER (PARTITION BY company ORDER BY year) AS prev_total_debt_est,
        LAG(roe)            OVER (PARTITION BY company ORDER BY year) AS prev_roe,
        LAG(roa)            OVER (PARTITION BY company ORDER BY year) AS prev_roa,
        LAG(roi)            OVER (PARTITION BY company ORDER BY year) AS prev_roi,
        LAG(net_profit_margin) OVER (PARTITION BY company ORDER BY year) AS prev_npm
    FROM base b
)
SELECT
    *,
    (revenue      - prev_revenue)      / NULLIF(prev_revenue, 0)        AS yoy_revenue,
    (gross_profit - prev_gross_profit) / NULLIF(prev_gross_profit, 0)   AS yoy_gross_profit,
    (cogs         - prev_cogs)         / NULLIF(prev_cogs, 0)           AS yoy_cogs,
    (net_income   - prev_net_income)   / NULLIF(prev_net_income, 0)     AS yoy_net_income,
    (ebitda       - prev_ebitda)       / NULLIF(prev_ebitda, 0)         AS yoy_ebitda,
    (market_cap   - prev_market_cap)   / NULLIF(prev_market_cap, 0)     AS yoy_market_cap,
    (total_debt_est - prev_total_debt_est) / NULLIF(prev_total_debt_est, 0) AS yoy_total_debt,
    -- ratios: absolute delta
    (roe - prev_roe)                   AS delta_roe,
    (roa - prev_roa)                   AS delta_roa,
    (roi - prev_roi)                   AS delta_roi,
    (net_profit_margin - prev_npm)     AS delta_npm
FROM lagged;
