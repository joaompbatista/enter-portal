-- ============================================================
-- Enter Portal – Fictitious Data Schema
-- Database: neondb (PostgreSQL on Neon)
-- ============================================================

-- ── Dim_Date ──────────────────────────────────────────────
CREATE TABLE dim_date (
    date_id         DATE PRIMARY KEY,
    year            INT,
    quarter         INT,
    month           INT,
    month_name      VARCHAR(20),
    week            INT,
    day_of_week     VARCHAR(20),
    is_weekend      BOOLEAN
);

INSERT INTO dim_date
SELECT
    d::DATE,
    EXTRACT(YEAR FROM d),
    EXTRACT(QUARTER FROM d),
    EXTRACT(MONTH FROM d),
    TO_CHAR(d, 'Month'),
    EXTRACT(WEEK FROM d),
    TO_CHAR(d, 'Day'),
    EXTRACT(DOW FROM d) IN (0, 6)
FROM generate_series('2023-01-01'::DATE, '2025-12-31'::DATE, '1 day') d;


-- ── Dim_Crews ─────────────────────────────────────────────
CREATE TABLE dim_crews (
    crew_id         SERIAL PRIMARY KEY,
    crew_name       VARCHAR(100),
    crew_lead       VARCHAR(100),
    region          VARCHAR(50),
    specialisation  VARCHAR(50)
);

INSERT INTO dim_crews (crew_name, crew_lead, region, specialisation) VALUES
    ('Crew Alpha',   'Lukas Bauer',    'Berlin',    'Heat Pumps'),
    ('Crew Beta',    'Anna Schreiber', 'Munich',    'Insulation'),
    ('Crew Gamma',   'Felix Wagner',   'Hamburg',   'Solar PV'),
    ('Crew Delta',   'Sara Koch',      'Frankfurt', 'Windows & Doors'),
    ('Crew Epsilon', 'Tom Richter',    'Stuttgart', 'Ventilation');


-- ── Dim_Homeowners ────────────────────────────────────────
CREATE TABLE dim_homeowners (
    homeowner_id    SERIAL PRIMARY KEY,
    full_name       VARCHAR(100),
    email           VARCHAR(100),
    phone           VARCHAR(30),
    city            VARCHAR(50),
    postal_code     VARCHAR(10),
    acquisition_channel VARCHAR(50)
);

INSERT INTO dim_homeowners (full_name, email, phone, city, postal_code, acquisition_channel) VALUES
    ('Hans Müller',      'hans.mueller@example.de',    '+49 30 1234567',  'Berlin',    '10115', 'Referral'),
    ('Ingrid Weber',     'ingrid.weber@example.de',    '+49 89 2345678',  'Munich',    '80331', 'Online Ad'),
    ('Klaus Fischer',    'klaus.fischer@example.de',   '+49 40 3456789',  'Hamburg',   '20095', 'Partner'),
    ('Monika Schmidt',   'monika.schmidt@example.de',  '+49 69 4567890',  'Frankfurt', '60311', 'Direct'),
    ('Peter Hoffmann',   'peter.hoffmann@example.de',  '+49 711 5678901', 'Stuttgart', '70173', 'Online Ad'),
    ('Ursula Braun',     'ursula.braun@example.de',    '+49 221 6789012', 'Cologne',   '50667', 'Referral'),
    ('Werner Klein',     'werner.klein@example.de',    '+49 351 7890123', 'Dresden',   '01067', 'Partner'),
    ('Erika Wolf',       'erika.wolf@example.de',      '+49 341 8901234', 'Leipzig',   '04109', 'Direct'),
    ('Günter Neumann',   'gunter.neumann@example.de',  '+49 511 9012345', 'Hanover',   '30159', 'Online Ad'),
    ('Brigitte Lange',   'brigitte.lange@example.de',  '+49 231 0123456', 'Dortmund',  '44135', 'Referral');


-- ── Dim_Properties ────────────────────────────────────────
CREATE TABLE dim_properties (
    property_id     SERIAL PRIMARY KEY,
    homeowner_id    INT REFERENCES dim_homeowners(homeowner_id),
    address         VARCHAR(200),
    city            VARCHAR(50),
    postal_code     VARCHAR(10),
    property_type   VARCHAR(50),
    construction_year INT,
    floor_area_sqm  NUMERIC(8,2),
    energy_class_before VARCHAR(5),
    energy_class_after  VARCHAR(5)
);

INSERT INTO dim_properties (homeowner_id, address, city, postal_code, property_type, construction_year, floor_area_sqm, energy_class_before, energy_class_after) VALUES
    (1,  'Unter den Linden 12',   'Berlin',    '10115', 'Detached House',  1978, 142.0, 'F', 'B'),
    (2,  'Maximilianstr. 8',      'Munich',    '80331', 'Semi-detached',   1985, 118.5, 'E', 'C'),
    (3,  'Jungfernstieg 3',       'Hamburg',   '20095', 'Detached House',  1965, 175.0, 'G', 'B'),
    (4,  'Goethestr. 21',         'Frankfurt', '60311', 'Terraced House',  1992, 105.0, 'D', 'B'),
    (5,  'Königstr. 15',          'Stuttgart', '70173', 'Detached House',  1971, 160.0, 'F', 'C'),
    (6,  'Hohe Str. 7',           'Cologne',   '50667', 'Apartment Block', 1960, 320.0, 'G', 'C'),
    (7,  'Prager Str. 4',         'Dresden',   '01067', 'Detached House',  1988, 130.0, 'E', 'B'),
    (8,  'Karl-Liebknecht-Str. 9','Leipzig',   '04109', 'Semi-detached',   1975, 112.0, 'F', 'C'),
    (9,  'Georgstr. 22',          'Hanover',   '30159', 'Detached House',  1980, 148.0, 'E', 'B'),
    (10, 'Westenhellweg 5',       'Dortmund',  '44135', 'Terraced House',  1968, 98.0,  'G', 'C');


-- ── Dim_Contracts ─────────────────────────────────────────
CREATE TABLE dim_contracts (
    contract_id     SERIAL PRIMARY KEY,
    property_id     INT REFERENCES dim_properties(property_id),
    crew_id         INT REFERENCES dim_crews(crew_id),
    contract_date   DATE,
    contract_type   VARCHAR(50),
    contract_value  NUMERIC(10,2),
    status          VARCHAR(30)
);

INSERT INTO dim_contracts (property_id, crew_id, contract_date, contract_type, contract_value, status) VALUES
    (1,  1, '2023-02-10', 'Full Retrofit',    45000.00, 'Completed'),
    (2,  2, '2023-03-15', 'Insulation Only',  18000.00, 'Completed'),
    (3,  3, '2023-05-20', 'Solar + Insulation',52000.00, 'Completed'),
    (4,  1, '2023-07-01', 'Full Retrofit',    41000.00, 'Completed'),
    (5,  4, '2023-09-12', 'Windows & Doors',  22000.00, 'Completed'),
    (6,  5, '2023-11-03', 'Ventilation Only', 15000.00, 'In Progress'),
    (7,  2, '2024-01-18', 'Insulation Only',  17500.00, 'Completed'),
    (8,  3, '2024-03-25', 'Solar PV',         28000.00, 'In Progress'),
    (9,  1, '2024-06-10', 'Full Retrofit',    49000.00, 'Planned'),
    (10, 4, '2024-08-20', 'Windows & Doors',  21000.00, 'Planned');


-- ── Fact_Projects ─────────────────────────────────────────
CREATE TABLE fact_projects (
    project_id          SERIAL PRIMARY KEY,
    contract_id         INT REFERENCES dim_contracts(contract_id),
    property_id         INT REFERENCES dim_properties(property_id),
    crew_id             INT REFERENCES dim_crews(crew_id),
    start_date          DATE,
    end_date            DATE,
    planned_end_date    DATE,
    actual_cost         NUMERIC(10,2),
    budgeted_cost       NUMERIC(10,2),
    co2_savings_kg_year NUMERIC(10,2),
    energy_savings_pct  NUMERIC(5,2),
    status              VARCHAR(30),
    csat_score          NUMERIC(3,1)
);

INSERT INTO fact_projects (contract_id, property_id, crew_id, start_date, end_date, planned_end_date, actual_cost, budgeted_cost, co2_savings_kg_year, energy_savings_pct, status, csat_score) VALUES
    (1,  1,  1, '2023-02-20', '2023-04-15', '2023-04-01', 44200.00, 45000.00, 3200.0, 62.5, 'Completed',   4.8),
    (2,  2,  2, '2023-03-25', '2023-05-10', '2023-05-15', 17800.00, 18000.00, 1800.0, 45.0, 'Completed',   4.5),
    (3,  3,  3, '2023-06-01', '2023-08-20', '2023-08-01', 53100.00, 52000.00, 4500.0, 70.0, 'Completed',   4.9),
    (4,  4,  1, '2023-07-15', '2023-09-30', '2023-09-15', 40500.00, 41000.00, 2900.0, 58.0, 'Completed',   4.7),
    (5,  5,  4, '2023-09-20', '2023-11-10', '2023-11-01', 22300.00, 22000.00, 1200.0, 30.0, 'Completed',   4.6),
    (6,  6,  5, '2023-11-15', NULL,          '2024-01-31', 8000.00,  15000.00, NULL,   NULL, 'In Progress', NULL),
    (7,  7,  2, '2024-02-01', '2024-03-28', '2024-03-15', 17200.00, 17500.00, 1750.0, 43.0, 'Completed',   4.4),
    (8,  8,  3, '2024-04-10', NULL,          '2024-06-30', 15000.00, 28000.00, NULL,   NULL, 'In Progress', NULL),
    (9,  9,  1, '2024-07-01', NULL,          '2024-10-31', 5000.00,  49000.00, NULL,   NULL, 'Planned',     NULL),
    (10, 10, 4, '2024-09-01', NULL,          '2024-11-30', 0.00,     21000.00, NULL,   NULL, 'Planned',     NULL);


-- ── Fact_EnergyReadings ───────────────────────────────────
CREATE TABLE fact_energy_readings (
    reading_id          SERIAL PRIMARY KEY,
    property_id         INT REFERENCES dim_properties(property_id),
    reading_date        DATE,
    consumption_kwh     NUMERIC(10,2),
    heating_kwh         NUMERIC(10,2),
    electricity_kwh     NUMERIC(10,2),
    cost_eur            NUMERIC(8,2)
);

INSERT INTO fact_energy_readings (property_id, reading_date, consumption_kwh, heating_kwh, electricity_kwh, cost_eur) VALUES
    (1, '2023-01-01', 2100.0, 1600.0, 500.0, 420.0),
    (1, '2023-04-01',  950.0,  550.0, 400.0, 190.0),
    (1, '2023-07-01',  780.0,  300.0, 480.0, 156.0),
    (1, '2023-10-01', 1400.0,  900.0, 500.0, 280.0),
    (1, '2024-01-01',  820.0,  380.0, 440.0, 164.0),
    (2, '2023-01-01', 1850.0, 1350.0, 500.0, 370.0),
    (2, '2023-04-01',  870.0,  480.0, 390.0, 174.0),
    (2, '2023-07-01',  720.0,  260.0, 460.0, 144.0),
    (2, '2023-10-01', 1250.0,  780.0, 470.0, 250.0),
    (2, '2024-01-01',  780.0,  340.0, 440.0, 156.0),
    (3, '2023-01-01', 2400.0, 1850.0, 550.0, 480.0),
    (3, '2023-04-01', 1050.0,  620.0, 430.0, 210.0),
    (3, '2023-07-01',  820.0,  310.0, 510.0, 164.0),
    (3, '2023-10-01', 1600.0, 1050.0, 550.0, 320.0),
    (3, '2024-01-01',  700.0,  260.0, 440.0, 140.0),
    (4, '2023-01-01', 1700.0, 1220.0, 480.0, 340.0),
    (4, '2023-04-01',  800.0,  420.0, 380.0, 160.0),
    (4, '2023-07-01',  690.0,  240.0, 450.0, 138.0),
    (4, '2023-10-01', 1150.0,  700.0, 450.0, 230.0),
    (4, '2024-01-01',  730.0,  310.0, 420.0, 146.0),
    (5, '2023-01-01', 2000.0, 1500.0, 500.0, 400.0),
    (5, '2023-04-01',  920.0,  530.0, 390.0, 184.0),
    (5, '2023-07-01',  760.0,  280.0, 480.0, 152.0),
    (5, '2023-10-01', 1350.0,  860.0, 490.0, 270.0),
    (5, '2024-01-01',  850.0,  390.0, 460.0, 170.0);


-- ── Fact_Forecasts ────────────────────────────────────────
CREATE TABLE fact_forecasts (
    forecast_id             SERIAL PRIMARY KEY,
    property_id             INT REFERENCES dim_properties(property_id),
    crew_id                 INT REFERENCES dim_crews(crew_id),
    forecast_date           DATE,
    forecasted_consumption_kwh  NUMERIC(10,2),
    actual_consumption_kwh      NUMERIC(10,2),
    forecasted_savings_eur      NUMERIC(8,2),
    actual_savings_eur          NUMERIC(8,2),
    forecast_accuracy_pct       NUMERIC(5,2)
);

INSERT INTO fact_forecasts (property_id, crew_id, forecast_date, forecasted_consumption_kwh, actual_consumption_kwh, forecasted_savings_eur, actual_savings_eur, forecast_accuracy_pct) VALUES
    (1, 1, '2024-01-01',  850.0,  820.0, 170.0, 164.0, 96.5),
    (2, 2, '2024-01-01',  800.0,  780.0, 160.0, 156.0, 97.5),
    (3, 3, '2024-01-01',  720.0,  700.0, 144.0, 140.0, 97.2),
    (4, 1, '2024-01-01',  750.0,  730.0, 150.0, 146.0, 97.3),
    (5, 4, '2024-01-01',  870.0,  850.0, 174.0, 170.0, 97.7),
    (1, 1, '2024-04-01',  420.0,  410.0,  84.0,  82.0, 97.6),
    (2, 2, '2024-04-01',  390.0,  380.0,  78.0,  76.0, 97.4),
    (3, 3, '2024-04-01',  440.0,  430.0,  88.0,  86.0, 97.7),
    (4, 1, '2024-04-01',  380.0,  370.0,  76.0,  74.0, 97.4),
    (5, 4, '2024-04-01',  400.0,  390.0,  80.0,  78.0, 97.5);


-- ── Fact_CSAT_Surveys ─────────────────────────────────────
-- Captures homeowner satisfaction scores after deep dive sessions
-- with crew leads. Categories reflect the KPIs in the Senior Data
-- Analyst role: Data Insights quality and Forecast Accuracy.
CREATE TABLE fact_csat_surveys (
    survey_id               SERIAL PRIMARY KEY,
    homeowner_id            INT REFERENCES dim_homeowners(homeowner_id),
    crew_id                 INT REFERENCES dim_crews(crew_id),
    project_id              INT REFERENCES fact_projects(project_id),
    survey_date             DATE,
    session_type            VARCHAR(50),   -- 'Deep Dive', 'Forecast Review', 'Progress Update'
    score_data_insights     NUMERIC(3,1),  -- 1–5: clarity and quality of data presented
    score_forecast_accuracy NUMERIC(3,1),  -- 1–5: how accurate the forecast felt vs reality
    score_communication     NUMERIC(3,1),  -- 1–5: crew lead communication
    score_overall           NUMERIC(3,1),  -- 1–5: overall satisfaction
    forecast_used_as_source BOOLEAN,       -- did crew lead use forecast as primary source of truth?
    comments                TEXT
);

INSERT INTO fact_csat_surveys (homeowner_id, crew_id, project_id, survey_date, session_type, score_data_insights, score_forecast_accuracy, score_communication, score_overall, forecast_used_as_source, comments) VALUES
    (1,  1, 1, '2023-03-15', 'Deep Dive',        4.8, 4.9, 4.7, 4.8, TRUE,  'Very clear presentation of energy savings data.'),
    (1,  1, 1, '2023-04-20', 'Forecast Review',  5.0, 4.8, 4.9, 4.9, TRUE,  'Forecast matched reality almost perfectly.'),
    (2,  2, 2, '2023-04-10', 'Deep Dive',        4.5, 4.4, 4.6, 4.5, TRUE,  'Good overview, could show more detail on heating breakdown.'),
    (2,  2, 2, '2023-05-15', 'Forecast Review',  4.6, 4.5, 4.7, 4.6, TRUE,  'Appreciated the comparison between forecast and actuals.'),
    (3,  3, 3, '2023-07-05', 'Deep Dive',        4.9, 4.8, 5.0, 4.9, TRUE,  'Exceptional session, data was very actionable.'),
    (3,  3, 3, '2023-08-25', 'Forecast Review',  4.7, 4.9, 4.8, 4.8, TRUE,  'Solar forecast was spot on.'),
    (4,  1, 4, '2023-08-01', 'Progress Update',  4.6, 4.5, 4.7, 4.6, TRUE,  'Good use of the forecasting tool during the session.'),
    (4,  1, 4, '2023-10-05', 'Forecast Review',  4.8, 4.7, 4.8, 4.8, TRUE,  'Very satisfied with the data quality.'),
    (5,  4, 5, '2023-10-10', 'Deep Dive',        4.4, 4.3, 4.5, 4.4, FALSE, 'Session was good but forecast tool was not shown.'),
    (5,  4, 5, '2023-11-15', 'Forecast Review',  4.6, 4.5, 4.6, 4.6, TRUE,  'Improved compared to last session.'),
    (7,  2, 7, '2024-02-20', 'Deep Dive',        4.3, 4.2, 4.4, 4.3, TRUE,  'Solid session, data was clear and well-structured.'),
    (7,  2, 7, '2024-04-01', 'Forecast Review',  4.5, 4.4, 4.5, 4.5, TRUE,  'Forecast accuracy has improved noticeably.'),
    (1,  1, 1, '2024-02-10', 'Progress Update',  4.9, 4.8, 5.0, 4.9, TRUE,  'Outstanding follow-up, forecasts continue to be reliable.'),
    (3,  3, 3, '2024-03-01', 'Progress Update',  5.0, 5.0, 5.0, 5.0, TRUE,  'Best session so far. All data was accurate and insightful.'),
    (2,  2, 2, '2024-03-20', 'Deep Dive',        4.7, 4.6, 4.8, 4.7, TRUE,  'Great improvement in how data insights are communicated.');
