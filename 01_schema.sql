-- Daily sales table (train.csv ke 9 columns, usi order mein)
CREATE TABLE train (
    store_id        INT,
    day_of_week     INT,
    sales_date      DATE,
    sales           INT,
    customers       INT,
    is_open         INT,
    promo           INT,
    state_holiday   TEXT,
    school_holiday  INT
);

-- Store info table (store.csv ke 10 columns, usi order mein)
CREATE TABLE store (
    store_id              INT,
    store_type            TEXT,
    assortment            TEXT,
    competition_distance  NUMERIC,
    comp_open_month       NUMERIC,
    comp_open_year        NUMERIC,
    promo2                INT,
    promo2_since_week     NUMERIC,
    promo2_since_year     NUMERIC,
    promo_interval        TEXT
);