# Promo Reality Check

Does a retail promotion really move sales? An analysis of Rossmann store data (1,115 stores, Jan 2013 to Jul 2015) that separates the naive promo lift from a more careful estimate.

![Dashboard](reports/dashboard.png)

## Headline results

| Question | Result |
|---|---|
| Daily Promo, naive comparison | Promo days show **38.8%** higher average sales than non-promo days |
| Same-weekday comparison | Lift ranges from **57% (Mon) to 22% (Fri)**. Promos never run on weekends, so the naive number mixes in weekday effects |
| Promo2 (long-running program), regression | About **+2.8%** daily sales vs similar never-joined stores (95% CI +0.8% to +4.8%, p = 0.006; 176 treated vs 544 control stores) |
| Promo2, ML counterfactual check | About **+1.8%** (95% CI -0.1% to +3.6%) |
| Break-even | At an assumed 20% margin, Promo2 adds roughly 36 currency units of profit per store per day (range about 10 to 62). It pays off only if its cost per store-day is below that |

**Conclusion:** Promo2 shows a modest positive effect of roughly 2-3%, with some uncertainty. The naive daily-promo number overstates what the promo itself does.

## Data
Rossmann Store Sales (Kaggle): `train.csv` and `store.csv`. Raw data is not included. Download it from https://www.kaggle.com/c/rossmann-store-sales/data into a `data/` folder.

## Method
1. **Cleaning (Pandas):** removed closed days and 40 store-days with zero sales, merged store details.
2. **Daily Promo:** naive comparison, then comparison within each weekday.
3. **Promo2 difference-in-differences:** stores that joined during the data window (treated) vs stores that never joined (control).
   - Simple 2x2 version (Oct-Dec 2013 vs Oct-Dec 2014, 40 treated stores): +0.8 pp, p = 0.71, no clear effect with that small sample.
   - Main version: regression on log sales with store and month fixed effects, standard errors clustered by store (176 treated stores).
4. **Checks:** parallel-trends chart (groups moved together before joining) and a placebo test (+3.0 pp, p = 0.49), which shows how noisy small samples are.
5. **ML cross-check (scikit-learn):** a gradient boosting model trained only on never-joined stores (test R2 = 0.91, MAE = 0.068 in log sales) predicts what treated stores would have sold without Promo2.
6. **Break-even analysis** under assumed margins.
7. **SQL (PostgreSQL):** queries using joins, CTEs, window functions and FILTER aggregates, in `sql/`.
8. **Dashboard (Power BI):** one-page summary in `reports/`.

## Limitations
- Observational data: stores chose whether to join Promo2, so the estimate is not proof of causation.
- Promo2 join dates are approximate; actual promo rounds start in the months listed in `PromoInterval`.
- The 2x2 check used only 40 treated stores; the larger regression is the main estimate.
- The placebo estimate (+3.0 pp) was of similar size to the main effect, so the result should be read as a modest effect with uncertainty.
- The ML bootstrap interval resamples stores only and ignores model uncertainty, so it is probably a little too narrow.
- No margin or promo-cost data exists; break-even numbers rely on assumed margins and about 300 open days per year.
- The daily Promo comparison is descriptive, not causal.

## How to run
1. Download the data (see above) into `data/`.
2. `pip install -r requirements.txt`
3. Open `notebooks/promo_reality_check.ipynb` and run all cells.

## Tools
Python (Pandas, NumPy, Seaborn, Matplotlib, SciPy, statsmodels, scikit-learn), PostgreSQL, Power BI