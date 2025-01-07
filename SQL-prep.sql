-- NOTE: for confidentiality reasons, all field names, table names, and hotel names have been changed/generalized

-- searches view: for each ABC search, the number of results with a ABC result, and whether or not a ABC was returned/booked
DECLARE from_dt DATE DEFAULT "2022-01-01";
DECLARE to_dt DATE DEFAULT "2023-12-31";

CREATE OR REPLACE VIEW `demo-datalake-businesstravel.ABC_searches_view` AS

-- Selecting only the correlation IDs associated with ABC rate plans
WITH searches_ABC AS (
  SELECT
    DISTINCT(search_id)
  FROM `demo-datalake-businesstravel.searches` as s
  WHERE
    EXTRACT(DATE FROM eda_ingest_ts) BETWEEN from_dt AND to_dt
    AND (REGEXP_MATCH(program_code,r'^ABC$')))
),
results_ABC AS (
  SELECT
    result_id, 
    CASE WHEN REGEXP_MATCH(program_code,r'^ABC$')) THEN 1 ELSE 0
    END AS program_flag,
    ratekey
  FROM `demo-datalake-businesstravel.results` as r
  WHERE
    EXTRACT(DATE FROM eda_ingest_ts) BETWEEN from_dt AND  to_dt
),
result_ABC_ct AS (
  select
    search_id, 
    result_id,
    sum(program_flag) as program_result_ct, 
  from results_ABC
  group by result_id, ratekey
),
bookings AS (
  SELECT
  booking_id,
  result_id,
  program_code,
  ratekey,
  FROM `demo-datalake-businesstravel.bookings`
  WHERE EXTRACT(DATE FROM eda_ingest_ts) BETWEEN from_dt AND to_dt
)
SELECT
results_ABC_ct.result_id,
program_result_ct,
CASE 
  WHEN program_result_ct >= 1 THEN TRUE 
  WHEN program_result_ct = 0 THEN FALSE
  ELSE FALSE
END AS ProgramReturned,
CASE 
  WHEN bookings.REGEXP_MATCH(program_code,r'^ABC$')) THEN TRUE ELSE FALSE
END AS ABCRate
FROM result_ABC_ct
inner JOIN searches_ABC ON searches_ABC.search_id = result_ABC_ct.search_id
inner JOIN bookings ON results_ABC_ct.result_id = bookings.result_id

--1c. cases view (A, B, C)
CREATE OR REPLACE VIEW `demo-datalake-businesstravel.ABC_cases` AS

SELECT
*,
CASE 
  WHEN ProgramReturned = TRUE AND ABCRate = TRUE THEN "A"
  WHEN ProgramReturned = TRUE AND ABCRate = FALSE THEN "B"
  WHEN ProgramReturned = FALSE THEN "C"
  ELSE "other"
END AS cases
FROM `demo-datalake-businesstravel.ABC_searches_view`

-- case B view
CREATE OR REPLACE VIEW `demo-datalake-businesstravel.ABC_caseB` AS
-- Selecting only the searches with leakage (program code is returned but not booked)
WITH caseB AS (
    SELECT *
FROM `demo-datalake-businesstravel.ABC_cases`
WHERE cases = "B"
),
calc AS (
SELECT
    result_id,
    search_id,
    AVG(CASE 
        WHEN REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END) AS avg_APP,
    AVG(CASE 
        WHEN NOT REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END) AS avg_other,
    (AVG(CASE 
        WHEN REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END) - AVG(CASE 
        WHEN NOT REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END)) AS avg_diff_from_other,
    ((AVG(CASE 
        WHEN REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END) - AVG(CASE 
        WHEN NOT REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END)) / AVG(CASE 
        WHEN NOT REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END)) * 100 AS avg_percent_diff,
    MIN(CASE 
        WHEN REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END) AS min_APP,
    MIN(CASE 
        WHEN NOT REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END) AS min_other,
    (MIN(CASE 
        WHEN REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END) - MIN(CASE 
        WHEN NOT REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END)) AS min_diff_from_other,
    ((MIN(CASE 
        WHEN REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END) - MIN(CASE 
        WHEN NOT REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END)) / MIN(CASE 
        WHEN NOT REGEXP_MATCH(program_code,r'^ABC$')) THEN amount_after_tax 
        ELSE NULL 
    END)) * 100 AS min_percent_diff
FROM `demo-datalake-businesstravel.results` rs 
GROUP BY search_id
)

SELECT
DISTINCT
caseB.result_id,
avg_ABC,
avg_other,
avg_diff_from_other,
avg_percent_diff,
min_ABC,
min_other,
min_diff_from_other,
min_percent_diff
FROM caseB
LEFT JOIN calc ON caseB.result_id = calc.result_id
