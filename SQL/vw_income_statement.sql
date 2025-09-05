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
