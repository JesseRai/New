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
