-- NHANES Depression Analysis
-- Highlight Queries
-- 2011-2012 vs 2021-2022
--
-- PHQ-9 >= 10 is used as the threshold for
-- moderate-or-greater depressive symptoms.


-- ============================================================
-- 1. Depression Prevalence by Age Group
-- ============================================================
-- Key finding:
-- Younger adults, particularly ages 18-24 and 25-34,
-- experienced the largest increases in depressive symptoms.
--
-- SQL concepts:
-- CASE, UNION ALL, conditional aggregation

WITH age_groups AS (
    SELECT
        '2011' AS cycle,
        CASE
            WHEN age BETWEEN 18 AND 24 THEN '18-24'
            WHEN age BETWEEN 25 AND 34 THEN '25-34'
            WHEN age BETWEEN 35 AND 44 THEN '35-44'
            WHEN age BETWEEN 45 AND 54 THEN '45-54'
            WHEN age BETWEEN 55 AND 64 THEN '55-64'
            WHEN age >= 65 THEN '65+'
        END AS age_group,
        depression_flag
    FROM demo_depression_2011

    UNION ALL

    SELECT
        '2021' AS cycle,
        CASE
            WHEN age BETWEEN 18 AND 24 THEN '18-24'
            WHEN age BETWEEN 25 AND 34 THEN '25-34'
            WHEN age BETWEEN 35 AND 44 THEN '35-44'
            WHEN age BETWEEN 45 AND 54 THEN '45-54'
            WHEN age BETWEEN 55 AND 64 THEN '55-64'
            WHEN age >= 65 THEN '65+'
        END AS age_group,
        depression_flag
    FROM demo_depression_2021
)
SELECT
    age_group,
    ROUND(
        100.0 * AVG(depression_flag)
        FILTER (WHERE cycle = '2011'),
        2
    ) AS pct_depressed_2011,
    ROUND(
        100.0 * AVG(depression_flag)
        FILTER (WHERE cycle = '2021'),
        2
    ) AS pct_depressed_2021
FROM age_groups
WHERE age_group IS NOT NULL
GROUP BY age_group
ORDER BY age_group;


-- ============================================================
-- 2. Depression Prevalence by Sleep Category
-- ============================================================
-- Key finding:
-- Short sleep had the highest prevalence of moderate-or-greater
-- depressive symptoms among the sleep categories analyzed.
--
-- SQL concepts:
-- INNER JOIN, CASE, UNION ALL, conditional aggregation

WITH sleep_depression AS (
    SELECT
        '2011' AS cycle,
        CASE
            WHEN sleep_hours < 7 THEN 'Short sleep'
            WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
            WHEN sleep_hours > 9 THEN 'Long sleep'
        END AS sleep_category,
        depression_flag
    FROM sleep_2011 s
    INNER JOIN demo_depression_2011 d
        ON s.respondent_id = d.respondent_id
    WHERE sleep_hours IS NOT NULL

    UNION ALL

    SELECT
        '2021' AS cycle,
        CASE
            WHEN sleep_hours < 7 THEN 'Short sleep'
            WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
            WHEN sleep_hours > 9 THEN 'Long sleep'
        END AS sleep_category,
        depression_flag
    FROM sleep_2021 s
    INNER JOIN demo_depression_2021 d
        ON s.respondent_id = d.respondent_id
    WHERE sleep_hours IS NOT NULL
)
SELECT
    sleep_category,
    ROUND(
        100.0 * AVG(depression_flag)
        FILTER (WHERE cycle = '2011'),
        2
    ) AS pct_depressed_2011,
    ROUND(
        100.0 * AVG(depression_flag)
        FILTER (WHERE cycle = '2021'),
        2
    ) AS pct_depressed_2021
FROM sleep_depression
GROUP BY sleep_category
ORDER BY sleep_category;


-- ============================================================
-- 3. Sleep Distribution by Depression Status
-- ============================================================
-- Key finding:
-- Sleep patterns differed between adults above and below the
-- PHQ-9 >= 10 threshold.
--
-- SQL concepts:
-- INNER JOIN, CASE, window functions, conditional percentages

SELECT
    CASE
        WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
        ELSE 'Not recommended'
    END AS sleep_category,
    CASE
        WHEN depression_flag = 1
            THEN 'Moderate-or-greater symptoms'
        ELSE 'Below threshold'
    END AS depression_status,
    COUNT(*) AS n,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY depression_flag),
        2
    ) AS pct_of_depression_group
FROM demo_depression_2021 d
INNER JOIN sleep_2021 s
    ON d.respondent_id = s.respondent_id
WHERE depression_flag IS NOT NULL
    AND sleep_hours IS NOT NULL
GROUP BY sleep_category, depression_flag
ORDER BY depression_flag, sleep_category;


-- ============================================================
-- 4. Sleep Distribution by Age Group
-- ============================================================
-- Analytical use:
-- Examines whether sleep patterns differed substantially across
-- the age groups with different depression prevalence.
--
-- SQL concepts:
-- CTE, INNER JOIN, CASE, window functions

WITH age_sleep AS (
    SELECT
        CASE
            WHEN age BETWEEN 18 AND 24 THEN '18-24'
            WHEN age BETWEEN 25 AND 34 THEN '25-34'
            WHEN age BETWEEN 35 AND 44 THEN '35-44'
            WHEN age BETWEEN 45 AND 54 THEN '45-54'
            WHEN age BETWEEN 55 AND 64 THEN '55-64'
            WHEN age >= 65 THEN '65+'
        END AS age_group,
        CASE
            WHEN sleep_hours < 7 THEN 'Short sleep'
            WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
            WHEN sleep_hours > 9 THEN 'Long sleep'
        END AS sleep_category,
        COUNT(*) AS n
    FROM demo_depression_2021 d
    INNER JOIN sleep_2021 s
        ON d.respondent_id = s.respondent_id
    WHERE age IS NOT NULL
        AND sleep_hours IS NOT NULL
    GROUP BY age_group, sleep_category
)
SELECT
    age_group,
    sleep_category,
    n,
    ROUND(
        100.0 * n /
        SUM(n) OVER (PARTITION BY age_group),
        2
    ) AS pct_of_age_group
FROM age_sleep
ORDER BY age_group, sleep_category;


-- ============================================================
-- 5. Alcohol Distribution by Relationship Status
-- ============================================================
-- Analytical use:
-- Examines differences in alcohol consumption patterns across
-- relationship-status groups.
--
-- SQL concepts:
-- CTE, INNER JOIN, complex CASE, window functions

WITH relationship_alcohol AS (
    SELECT
        relationship_status,
        CASE
            WHEN gender = 'Female'
                AND avg_drinks_per_drinking_day <= 1
                THEN 'Moderate'

            WHEN gender = 'Male'
                AND avg_drinks_per_drinking_day <= 2
                THEN 'Moderate'

            WHEN gender = 'Female'
                AND avg_drinks_per_drinking_day > 1
                AND avg_drinks_per_drinking_day <= 3
                THEN 'Above Moderate'

            WHEN gender = 'Male'
                AND avg_drinks_per_drinking_day > 2
                AND avg_drinks_per_drinking_day <= 4
                THEN 'Above Moderate'

            WHEN gender = 'Female'
                AND avg_drinks_per_drinking_day > 3
                THEN 'Heavy consumption'

            WHEN gender = 'Male'
                AND avg_drinks_per_drinking_day > 4
                THEN 'Heavy consumption'
        END AS alcohol_category,
        COUNT(*) AS n
    FROM demo_depression_2021 d
    INNER JOIN alcohol_2021 a
        ON d.respondent_id = a.respondent_id
    WHERE relationship_status IS NOT NULL
        AND avg_drinks_per_drinking_day IS NOT NULL
    GROUP BY relationship_status, alcohol_category
)
SELECT
    relationship_status,
    alcohol_category,
    n,
    ROUND(
        100.0 * n /
        SUM(n) OVER (PARTITION BY relationship_status),
        2
    ) AS pct_of_relationship_group
FROM relationship_alcohol
ORDER BY relationship_status, alcohol_category;
