SELECT (SELECT COUNT(*) FROM train) AS train_rows,
       (SELECT COUNT(*) FROM store) AS store_rows;

---- Query 1: Naive promo lift ----
SELECT ROUND((AVG(sales) FILTER (WHERE promo = 1)
            / AVG(sales) FILTER (WHERE promo = 0) - 1) * 100, 1) AS naive_lift_pct
FROM train
WHERE is_open = 1;

---- Query 2: Hafte ke din ke hisaab se lift ----
SELECT day_of_week,
       ROUND(AVG(sales) FILTER (WHERE promo = 0), 1) AS no_promo_avg,
       ROUND(AVG(sales) FILTER (WHERE promo = 1), 1) AS promo_avg,
       ROUND((AVG(sales) FILTER (WHERE promo = 1)
            / AVG(sales) FILTER (WHERE promo = 0) - 1) * 100, 1) AS lift_pct
FROM train
WHERE is_open = 1
GROUP BY day_of_week
ORDER BY day_of_week;

---- Query 3: Usable Promo2 stores ki ginti ----
SELECT COUNT(*) AS usable_treated_stores
FROM store
WHERE promo2 = 1
  AND (make_date(promo2_since_year::int, 1, 1) + (promo2_since_week::int - 1) * 7)
      BETWEEN DATE '2013-03-01' AND DATE '2015-06-01';

---- Treated vs control, mahine ke hisaab se (CTE) ----	  
WITH grp AS (
    SELECT store_id,
           CASE
             WHEN promo2 = 1
              AND (make_date(promo2_since_year::int, 1, 1) + (promo2_since_week::int - 1) * 7)
                  BETWEEN DATE '2013-03-01' AND DATE '2015-06-01' THEN 'treated'
             WHEN promo2 = 0 THEN 'control'
           END AS grp
    FROM store
)
SELECT DATE_TRUNC('month', t.sales_date)::date AS month,
       g.grp,
       ROUND(AVG(t.sales), 0) AS avg_sales
FROM train t
JOIN grp g ON t.store_id = g.store_id
WHERE t.is_open = 1 AND g.grp IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2;

---- Query 5: Mahine-dar-mahine badlav (window function) ----
WITH grp AS (
    SELECT store_id,
           CASE
             WHEN promo2 = 1
              AND (make_date(promo2_since_year::int, 1, 1) + (promo2_since_week::int - 1) * 7)
                  BETWEEN DATE '2013-03-01' AND DATE '2015-06-01' THEN 'treated'
             WHEN promo2 = 0 THEN 'control'
           END AS grp
    FROM store
),
monthly AS (
    SELECT DATE_TRUNC('month', t.sales_date)::date AS month,
           g.grp,
           AVG(t.sales) AS avg_sales
    FROM train t
    JOIN grp g ON t.store_id = g.store_id
    WHERE t.is_open = 1 AND g.grp IS NOT NULL
    GROUP BY 1, 2
)
SELECT month, grp,
       ROUND(avg_sales, 0) AS avg_sales,
       ROUND((avg_sales / LAG(avg_sales) OVER (PARTITION BY grp ORDER BY month) - 1) * 100, 1) AS mom_pct
FROM monthly
ORDER BY grp, month;