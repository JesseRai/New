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
