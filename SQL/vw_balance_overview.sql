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
