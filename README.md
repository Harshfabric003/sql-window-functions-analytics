# Sales Analytics with SQL Window Functions

Three analytical patterns every data analyst runs into, solved with SQL **window functions** on a single fictional monthly-sales table. Copy the whole file into any MySQL 8.0+ client and run it end to end.

## What's inside

| # | Query | Window function | Answers |
|---|-----------------------------|-----------------|-----------------------------------------------|
| 1 | Running total | `SUM() OVER` | How is cumulative revenue building up per region? |
| 2 | Month-over-month growth | `LAG()` | How fast is each region growing vs. last month? |
| 3 | Top-N products per category | `RANK()` | What are the best sellers within each category? |

## Why window functions

Regular aggregation (`GROUP BY`) collapses rows into one summary row per group. Window functions do the opposite: they calculate across a set of rows **while keeping every row visible**. That's what makes running totals, period-over-period comparisons, and per-group rankings possible in a single, readable query — no self-joins or subquery gymnastics.

## The three techniques

**Running total** — `SUM(...) OVER (PARTITION BY region ORDER BY sale_month)` accumulates revenue row by row, restarting for each region.

**Month-over-month growth** — `LAG(...)` reaches back to the previous month's value in the same partition, so the growth % is just `(this - prev) / prev * 100`. The first month has no previous value, so it correctly returns `NULL`.

**Top-N per category** — `RANK() OVER (PARTITION BY category ORDER BY revenue DESC)` numbers products within each category; filtering `rank <= 2` returns the top two per group.

## How to run

Open `sales_window_functions.sql` in MySQL Workbench, DBeaver, or any MySQL client and run the whole script — it builds the table, inserts sample data, and runs all three queries.

## Sample output (abridged)

**Running total (North):** 20,000 → 43,000 → 88,800

**MoM growth (North):** Jan NULL, Feb +15.0%, Mar +99.13%

**Top 2 Fonts (March):** Metro Display (15,000, rank 1), Aria Sans (12,800, rank 2)

## Notes

- Dialect: **MySQL 8.0+** (window functions are unavailable in 5.7 and earlier).
- Schema and data are fictional, built purely to demonstrate the techniques.
- These three patterns cover a large share of real analytical reporting — cohort trends, retention curves, and leaderboards are all variations on the same functions.
