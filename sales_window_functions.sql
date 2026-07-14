-- =============================================================================
-- Sales Analytics with Window Functions
-- -----------------------------------------------------------------------------
-- Three analytical patterns every data analyst should know, built with SQL
-- window functions on a single fictional monthly-sales table:
--
--   1. Running total (cumulative revenue over time, per region)
--   2. Month-over-month growth (% change vs. the previous month, per region)
--   3. Top-N products per category (ranked by revenue)
--
-- Dialect: MySQL 8.0+  (window functions require 8.0 or later)
-- Note: Fictional schema and data. Not tied to any real system.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Schema + sample data
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS monthly_sales;

CREATE TABLE monthly_sales (
    sale_id      INT AUTO_INCREMENT PRIMARY KEY,
    region       VARCHAR(20)  NOT NULL,
    category     VARCHAR(20)  NOT NULL,
    product      VARCHAR(40)  NOT NULL,
    sale_month   DATE         NOT NULL,   -- first of the month, e.g. '2025-01-01'
    revenue      DECIMAL(10,2) NOT NULL
);

INSERT INTO monthly_sales (region, category, product, sale_month, revenue) VALUES
    ('North', 'Fonts',   'Aria Sans',      '2025-01-01', 12000.00),
    ('North', 'Fonts',   'Aria Sans',      '2025-02-01', 13500.00),
    ('North', 'Fonts',   'Aria Sans',      '2025-03-01', 12800.00),
    ('North', 'Bundles', 'Studio Pack',    '2025-01-01',  8000.00),
    ('North', 'Bundles', 'Studio Pack',    '2025-02-01',  9500.00),
    ('North', 'Bundles', 'Studio Pack',    '2025-03-01', 11000.00),
    ('South', 'Fonts',   'Nova Serif',     '2025-01-01',  9000.00),
    ('South', 'Fonts',   'Nova Serif',     '2025-02-01',  8700.00),
    ('South', 'Fonts',   'Nova Serif',     '2025-03-01', 10200.00),
    ('South', 'Bundles', 'Pro Collection', '2025-01-01',  6000.00),
    ('South', 'Bundles', 'Pro Collection', '2025-02-01',  7200.00),
    ('South', 'Bundles', 'Pro Collection', '2025-03-01',  6800.00),
    -- extra products to make the Top-N ranking meaningful
    ('North', 'Fonts',   'Metro Display',  '2025-03-01', 15000.00),
    ('North', 'Fonts',   'Ink Mono',       '2025-03-01',  7000.00),
    ('South', 'Bundles', 'Starter Kit',    '2025-03-01',  9900.00);


-- -----------------------------------------------------------------------------
-- QUERY 1: Running total of revenue over time, per region
-- SUM(...) OVER (PARTITION BY ... ORDER BY ...) accumulates row by row.
-- -----------------------------------------------------------------------------
SELECT
    region,
    sale_month,
    SUM(revenue) AS monthly_revenue,
    SUM(SUM(revenue)) OVER (
        PARTITION BY region
        ORDER BY sale_month
    ) AS running_total
FROM monthly_sales
GROUP BY region, sale_month
ORDER BY region, sale_month;


-- -----------------------------------------------------------------------------
-- QUERY 2: Month-over-month growth %, per region
-- LAG() pulls the previous month's value so we can compute the % change.
-- -----------------------------------------------------------------------------
SELECT
    region,
    sale_month,
    monthly_revenue,
    prev_month_revenue,
    ROUND(
        (monthly_revenue - prev_month_revenue) / prev_month_revenue * 100,
    2) AS mom_growth_pct
FROM (
    SELECT
        region,
        sale_month,
        SUM(revenue) AS monthly_revenue,
        LAG(SUM(revenue)) OVER (
            PARTITION BY region
            ORDER BY sale_month
        ) AS prev_month_revenue
    FROM monthly_sales
    GROUP BY region, sale_month
) AS m
ORDER BY region, sale_month;


-- -----------------------------------------------------------------------------
-- QUERY 3: Top 2 products by revenue within each category (March 2025)
-- RANK() OVER (PARTITION BY ... ORDER BY ... DESC) ranks within each group.
-- -----------------------------------------------------------------------------
SELECT category, product, total_revenue, revenue_rank
FROM (
    SELECT
        category,
        product,
        SUM(revenue) AS total_revenue,
        RANK() OVER (
            PARTITION BY category
            ORDER BY SUM(revenue) DESC
        ) AS revenue_rank
    FROM monthly_sales
    WHERE sale_month = '2025-03-01'
    GROUP BY category, product
) AS ranked
WHERE revenue_rank <= 2
ORDER BY category, revenue_rank;
