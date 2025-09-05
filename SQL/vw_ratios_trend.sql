CREATE OR REPLACE VIEW vw_ratios_trend AS
WITH base AS (
    SELECT
        company,
        year,
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
    company,
    year,
    current_ratio,
    debt_to_equity,
    roe, roa, roi, net_profit_margin,
    -- absolute change
    (current_ratio  - prev_current_ratio) AS delta_current_ratio,
    (debt_to_equity - prev_dte)           AS delta_dte,
    (roe           - prev_roe)            AS delta_roe,
    (roa           - prev_roa)            AS delta_roa,
    (roi           - prev_roi)            AS delta_roi,
    (net_profit_margin - prev_npm)        AS delta_npm,
    -- YoY percentage change
    (current_ratio  - prev_current_ratio) / NULLIF(prev_current_ratio, 0) AS yoy_current_ratio,
    (debt_to_equity - prev_dte)           / NULLIF(prev_dte, 0)           AS yoy_dte,
    (roe           - prev_roe)            / NULLIF(prev_roe, 0)           AS yoy_roe,
    (roa           - prev_roa)            / NULLIF(prev_roa, 0)           AS yoy_roa,
    (roi           - prev_roi)            / NULLIF(prev_roi, 0)           AS yoy_roi,
    (net_profit_margin - prev_npm)        / NULLIF(prev_npm, 0)           AS yoy_npm
FROM lagged;
