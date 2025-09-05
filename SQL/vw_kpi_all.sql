CREATE VIEW vw_kpi_all AS
SELECT
    company,
    year,
    revenue,
    gross_profit,
    (revenue - gross_profit) AS cogs,
    net_income,
    ebitda,
    eps,
    market_cap,
    free_cash_flow,
    roe, roa, roi, net_profit_margin,
    debt_to_equity,
    shareholders_equity,
    (debt_to_equity * shareholders_equity) AS total_debt_est
FROM company_financials;
