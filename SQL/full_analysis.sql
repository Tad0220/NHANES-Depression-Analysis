-- Depression demographics analysis
-- NHANES 2011-2012 and 2021-2022
-- Main demographic focus: age, relationship status, and income-to-poverty ratio


-- Relationship status
-- Depression prevalence using PHQ-9 >= 10

-- Depression prevalence by relationship status

-- 2011
SELECT relationship_status, 
	COUNT(*) AS n,
	ROUND(100.0 * AVG(depression_flag), 2) AS pct_depressed
FROM demo_depression_2011
WHERE relationship_status IS NOT NULL
GROUP BY relationship_status;

-- 2021
SELECT relationship_status, 
	COUNT(*) AS n,
	ROUND(100.0 * AVG(depression_flag), 2) AS pct_depressed
FROM demo_depression_2021
WHERE relationship_status IS NOT NULL
GROUP BY relationship_status;

-- Comparison of depression prevalence across cycles

WITH relationship_2011 AS(
SELECT relationship_status, 
	COUNT(*) AS n,
	ROUND(100.0 * AVG(depression_flag), 2) AS pct_depressed
FROM demo_depression_2011
WHERE relationship_status IS NOT NULL
GROUP BY relationship_status
),
relationship_2021 AS(
SELECT relationship_status, 
	COUNT(*) AS n,
	ROUND(100.0 * AVG(depression_flag), 2) AS pct_depressed
FROM demo_depression_2021
WHERE relationship_status IS NOT NULL
GROUP BY relationship_status
)
SELECT a.relationship_status,
	a.pct_depressed,
	b.pct_depressed,
	ROUND(100.0 * (b.pct_depressed - a.pct_depressed) /
	a.pct_depressed, 2) AS pct_change
FROM relationship_2011 a
INNER JOIN relationship_2021 b
	ON a.relationship_status = b.relationship_status;



-- Income-to-poverty ratio
-- Depression prevalence by income category

-- Depression prevalence by income-to-poverty category
WITH income_to_poverty_2011 AS(
SELECT 
	CASE 
		WHEN income_to_poverty_ratio < 1.0 THEN 'Below Poverty Level'
		WHEN income_to_poverty_ratio < 2.0 THEN 'Low Income'
		WHEN income_to_poverty_ratio < 4.0 THEN 'Middle Income'
		ELSE 'High-Income'
	END AS income_to_poverty,
	depression_flag, 
	phq9_score
FROM demo_depression_2011
WHERE income_to_poverty_ratio IS NOT NULL
)
SELECT income_to_poverty,
	ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed
FROM income_to_poverty_2011
GROUP BY income_to_poverty;

-- 2021
WITH income_to_poverty_2021 AS(
SELECT 
	CASE 
		WHEN income_to_poverty_ratio < 1.0 THEN 'Below Poverty Level'
		WHEN income_to_poverty_ratio < 2.0 THEN 'Low Income'
		WHEN income_to_poverty_ratio < 4.0 THEN 'Middle Income'
		ELSE 'High-Income'
	END AS income_to_poverty,
	depression_flag, 
	phq9_score
FROM demo_depression_2021
WHERE income_to_poverty_ratio IS NOT NULL
)
SELECT income_to_poverty,
	ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed
FROM income_to_poverty_2021
GROUP BY income_to_poverty
ORDER BY pct_depressed;



-- Age groups
-- Depression prevalence using PHQ-9 >= 10

-- Depression prevalence by age group
WITH age_group_depression_2011 AS( 
SELECT 
	CASE
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        WHEN age >= 65 THEN '65+'
	END AS age_group,
	depression_flag
FROM demo_depression_2011 d
)
SELECT age_group,
	COUNT(*),
	ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed
FROM age_group_depression_2011
GROUP BY age_group
ORDER BY age_group;



-- 2021
WITH age_group_depression_2021 AS( 
SELECT 
	CASE
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        WHEN age >= 65 THEN '65+'
	END AS age_group,
	depression_flag
FROM demo_depression_2021 d
)
SELECT age_group,
	COUNT(*),
	ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed
FROM age_group_depression_2021
GROUP BY age_group
ORDER BY age_group;




-- Depression risk factor analysis
-- NHANES 2011-2012 and 2021-2022
-- Main risk factor focus: sleep, alcohol, and BMI

-- Sleep
-- Depression prevalence by sleep category

-- 2011
SELECT 
CASE 
	WHEN sleep_hours < 7 THEN 'Short sleep'
	WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
	WHEN sleep_hours > 9 THEN 'Long sleep'
END AS sleep_categories,
ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed,
COUNT(*) AS n
FROM sleep_2011 s
INNER JOIN demo_depression_2011 d
	ON s.respondent_id = d.respondent_id
WHERE sleep_hours IS NOT NULL 
AND phq9_score IS NOT NULL
GROUP BY sleep_categories;


-- 2021
SELECT 
CASE 
	WHEN sleep_hours < 7 THEN 'Short sleep'
	WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
	WHEN sleep_hours > 9 THEN 'Long sleep'
END AS sleep_categories,
ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed,
COUNT(*) AS n
FROM sleep_2021 s
INNER JOIN demo_depression_2021 d
	ON s.respondent_id = d.respondent_id
WHERE sleep_hours IS NOT NULL 
AND phq9_score IS NOT NULL
GROUP BY sleep_categories;



-- Comparison of depression prevalence across cycles
WITH sleep_depr_2011 AS(
SELECT 
CASE 
	WHEN sleep_hours < 7 THEN 'Short sleep'
	WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
	WHEN sleep_hours > 9 THEN 'Long sleep'
END AS sleep_categories,
ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed,
COUNT(*) AS n
FROM sleep_2011 s
INNER JOIN demo_depression_2011 d
	ON s.respondent_id = d.respondent_id
WHERE sleep_hours IS NOT NULL 
AND phq9_score IS NOT NULL
GROUP BY sleep_categories
),
sleep_depr_2021 AS(
SELECT 
CASE 
	WHEN sleep_hours < 7 THEN 'Short sleep'
	WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
	WHEN sleep_hours > 9 THEN 'Long sleep'
END AS sleep_categories,
ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed,
COUNT(*) AS n
FROM sleep_2021 s
INNER JOIN demo_depression_2021 d
	ON s.respondent_id = d.respondent_id
WHERE sleep_hours IS NOT NULL 
AND phq9_score IS NOT NULL
GROUP BY sleep_categories
)
SELECT a.sleep_categories,
	a.pct_depressed AS pct_depressed_2011,
	b.pct_depressed AS pct_depressed_2021,
	ROUND(100.0 * (b.n - a.n) / a.n, 2) AS count_change_pct,
	b.pct_depressed - a.pct_depressed AS change
FROM sleep_depr_2011 a
INNER JOIN sleep_depr_2021 b
	ON a.sleep_categories = b.sleep_categories;



-- Alcohol
-- Depression prevalence by alcohol category

-- Depression prevalence by alcohol category



-- 2011 
SELECT 
CASE 
	WHEN gender = 'Female' AND avg_drinks_per_drinking_day <= 1 THEN 'Moderate'
	WHEN gender = 'Male' AND avg_drinks_per_drinking_day <= 2 THEN 'Moderate'
	WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 1 AND avg_drinks_per_drinking_day <= 3 THEN 'Above Moderate'
	WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 2 AND avg_drinks_per_drinking_day <= 4 THEN 'Above Moderate'
	WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 3 THEN 'Heavy consumption'
	WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 4 THEN 'Heavy consumption'
END AS alcohol_categories,
ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed,
COUNT(*)
FROM alcohol_2011 a
INNER JOIN demo_depression_2011 d
	ON a.respondent_id = d.respondent_id
WHERE avg_drinks_per_drinking_day IS NOT NULL
GROUP BY alcohol_categories;

-- 2021 
SELECT 
CASE 
	WHEN gender = 'Female' AND avg_drinks_per_drinking_day <= 1 THEN 'Moderate'
	WHEN gender = 'Male' AND avg_drinks_per_drinking_day <= 2 THEN 'Moderate'
	WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 1 AND avg_drinks_per_drinking_day <= 3 THEN 'Above Moderate'
	WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 2 AND avg_drinks_per_drinking_day <= 4 THEN 'Above Moderate'
	WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 3 THEN 'Heavy consumption'
	WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 4 THEN 'Heavy consumption'
END AS alcohol_categories,
ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed,
COUNT(*)
FROM alcohol_2021 a
INNER JOIN demo_depression_2021 d
	ON a.respondent_id = d.respondent_id
WHERE avg_drinks_per_drinking_day IS NOT NULL
GROUP BY alcohol_categories;



-- Comparison of depression prevalence across cycles

WITH alcohol_depression_2011 AS(
SELECT 
CASE 
	WHEN gender = 'Female' AND avg_drinks_per_drinking_day <= 1 THEN 'Moderate'
	WHEN gender = 'Male' AND avg_drinks_per_drinking_day <= 2 THEN 'Moderate'
	WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 1 AND avg_drinks_per_drinking_day <= 3 THEN 'Above Moderate'
	WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 2 AND avg_drinks_per_drinking_day <= 4 THEN 'Above Moderate'
	WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 3 THEN 'Heavy consumption'
	WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 4 THEN 'Heavy consumption'
END AS alcohol_categories,
ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed
FROM alcohol_2011 a
INNER JOIN demo_depression_2011 d
	ON a.respondent_id = d.respondent_id
WHERE avg_drinks_per_drinking_day IS NOT NULL
GROUP BY alcohol_categories
),
alcohol_depression_2021 AS(
SELECT 
CASE 
	WHEN gender = 'Female' AND avg_drinks_per_drinking_day <= 1 THEN 'Moderate'
	WHEN gender = 'Male' AND avg_drinks_per_drinking_day <= 2 THEN 'Moderate'
	WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 1 AND avg_drinks_per_drinking_day <= 3 THEN 'Above Moderate'
	WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 2 AND avg_drinks_per_drinking_day <= 4 THEN 'Above Moderate'
	WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 3 THEN 'Heavy consumption'
	WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 4 THEN 'Heavy consumption'
END AS alcohol_categories,
ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed
FROM alcohol_2021 a
INNER JOIN demo_depression_2021 d
	ON a.respondent_id = d.respondent_id
WHERE avg_drinks_per_drinking_day IS NOT NULL
GROUP BY alcohol_categories
)
SELECT a.alcohol_categories, 
	a.pct_depressed AS pct_depressed_2011,
	b.pct_depressed AS pct_depressed_2021,
	b.pct_depressed - a.pct_depressed AS change
FROM alcohol_depression_2011 a
INNER JOIN alcohol_depression_2021 b 
	ON a.alcohol_categories = b.alcohol_categories
ORDER BY change;



-- BMI
-- Depression prevalence by BMI category

-- 2011
SELECT 
CASE 
	WHEN bmi < 18.5 THEN 'Underweight'
	WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'Normal'
	WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'Overweight'
	WHEN bmi >= 30.0 THEN 'Obese'
END AS bmi_categories,
ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed,
COUNT(*)
FROM body_measurements_2011 bm
INNER JOIN demo_depression_2011 d
	ON bm.respondent_id = d.respondent_id
WHERE bmi IS NOT NULL
GROUP BY bmi_categories;


-- 2021
SELECT 
CASE 
	WHEN bmi < 18.5 THEN 'Underweight'
	WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'Normal'
	WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'Overweight'
	WHEN bmi >= 30.0 THEN 'Obese'
END AS bmi_categories,
ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed,
COUNT(*)
FROM body_measurements_2021 bm
INNER JOIN demo_depression_2021 d
	ON bm.respondent_id = d.respondent_id
WHERE bmi IS NOT NULL
GROUP BY bmi_categories;



-- Comparison of depression prevalence across cycles
WITH bmi_depression_2011 AS(
SELECT 
CASE 
	WHEN bmi < 18.5 THEN 'Underweight'
	WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'Normal'
	WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'Overweight'
	WHEN bmi >= 30.0 THEN 'Obese'
END AS bmi_categories,
ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed,
COUNT(*)
FROM body_measurements_2011 bm
INNER JOIN demo_depression_2011 d
	ON bm.respondent_id = d.respondent_id
WHERE bmi IS NOT NULL
GROUP BY bmi_categories
),
bmi_depression_2021 AS(
SELECT 
CASE 
	WHEN bmi < 18.5 THEN 'Underweight'
	WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'Normal'
	WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'Overweight'
	WHEN bmi >= 30.0 THEN 'Obese'
END AS bmi_categories,
ROUND(AVG(100.0 * depression_flag), 2) AS pct_depressed,
COUNT(*)
FROM body_measurements_2021 bm
INNER JOIN demo_depression_2021 d
	ON bm.respondent_id = d.respondent_id
WHERE bmi IS NOT NULL
GROUP BY bmi_categories
)
SELECT a.bmi_categories,
	a.pct_depressed AS pct_depressed_2011,
	b.pct_depressed AS pct_depressed_2021,
	b.pct_depressed - a.pct_depressed AS change
FROM bmi_depression_2011 a
INNER JOIN bmi_depression_2021 b
	ON a.bmi_categories = b.bmi_categories
;




-- Demographics and risk factors analysis
-- NHANES 2011-2012 and 2021-2022
-- Main demographic focus: age, relationship status, and income-to-poverty ratio


-- Age groups

-- Sleep distribution by age group

-- 2011
WITH age_sleep_2011 AS(
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
	END AS sleep_categories,
	COUNT(*) AS n
FROM demo_depression_2011 d
INNER JOIN sleep_2011 s
	ON d.respondent_id = s.respondent_id
WHERE sleep_hours IS NOT NULL 
AND age IS NOT NULL
GROUP BY age_group, sleep_categories
)
SELECT age_group, 
	sleep_categories,
	ROUND(
		100.0 * n / SUM(n) OVER (PARTITION BY age_group), 2
	) AS sleep_pct,
	SUM(n) OVER (PARTITION BY age_group) AS age_group_total
FROM age_sleep_2011
ORDER BY age_group, sleep_categories;


-- 2021
WITH age_sleep_2021 AS(
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
	END AS sleep_categories,
	COUNT(*) AS n
FROM demo_depression_2021 d
INNER JOIN sleep_2021 s
	ON d.respondent_id = s.respondent_id
WHERE sleep_hours IS NOT NULL 
AND age IS NOT NULL
GROUP BY age_group, sleep_categories
)
SELECT age_group, 
	sleep_categories,
	ROUND(
		100.0 * n / SUM(n) OVER (PARTITION BY age_group), 2
	) AS sleep_pct,
	SUM(n) OVER (PARTITION BY age_group) AS age_group_total
FROM age_sleep_2021
ORDER BY age_group, sleep_categories;


-- Alcohol consumption distribution by age group

-- 2011
WITH age_alcohol_2011 AS(
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
		WHEN gender = 'Female' AND avg_drinks_per_drinking_day <= 1 THEN 'Moderate'
		WHEN gender = 'Male' AND avg_drinks_per_drinking_day <= 2 THEN 'Moderate'
		WHEN gender = 'Female' 
			AND avg_drinks_per_drinking_day > 1 
			AND avg_drinks_per_drinking_day <= 3 THEN 'Above Moderate'
		WHEN gender = 'Male' 
			AND avg_drinks_per_drinking_day > 2 
			AND avg_drinks_per_drinking_day <= 4 THEN 'Above Moderate'
		WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 3 THEN 'Heavy consumption'
		WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 4 THEN 'Heavy consumption'
	END AS alcohol_categories,
	COUNT(*) AS n
FROM demo_depression_2011 d
INNER JOIN alcohol_2011 a
	ON d.respondent_id = a.respondent_id
WHERE avg_drinks_per_drinking_day IS NOT NULL 
AND age IS NOT NULL
GROUP BY age_group, alcohol_categories
)
SELECT age_group, 
	alcohol_categories,
	ROUND(
		100.0 * n / SUM(n) OVER (PARTITION BY age_group), 2
	) AS alcohol_pct,
	SUM(n) OVER (PARTITION BY age_group) AS age_group_total
FROM age_alcohol_2011
ORDER BY age_group, alcohol_categories;


-- 2021
WITH age_alcohol_2021 AS(
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
		WHEN gender = 'Female' AND avg_drinks_per_drinking_day <= 1 THEN 'Moderate'
		WHEN gender = 'Male' AND avg_drinks_per_drinking_day <= 2 THEN 'Moderate'
		WHEN gender = 'Female' 
			AND avg_drinks_per_drinking_day > 1 
			AND avg_drinks_per_drinking_day <= 3 THEN 'Above Moderate'
		WHEN gender = 'Male' 
			AND avg_drinks_per_drinking_day > 2 
			AND avg_drinks_per_drinking_day <= 4 THEN 'Above Moderate'
		WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 3 THEN 'Heavy consumption'
		WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 4 THEN 'Heavy consumption'
	END AS alcohol_categories,
	COUNT(*) AS n
FROM demo_depression_2021 d
INNER JOIN alcohol_2021 a
	ON d.respondent_id = a.respondent_id
WHERE avg_drinks_per_drinking_day IS NOT NULL 
AND age IS NOT NULL
GROUP BY age_group, alcohol_categories
)
SELECT age_group, 
	alcohol_categories,
	ROUND(
		100.0 * n / SUM(n) OVER (PARTITION BY age_group), 2
	) AS alcohol_pct,
	SUM(n) OVER (PARTITION BY age_group) AS age_group_total
FROM age_alcohol_2021
ORDER BY age_group, alcohol_categories;


-- Relationship status

-- Sleep distribution by relationship status

-- 2011
SELECT relationship_status,
	CASE 
		WHEN sleep_hours < 7 THEN 'Short sleep'
		WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
		WHEN sleep_hours > 9 THEN 'Long sleep'
	END AS sleep_categories,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY relationship_status), 2
	) AS pct_of_group
FROM demo_depression_2011 d
INNER JOIN sleep_2011 s
	ON d.respondent_id = s.respondent_id
WHERE relationship_status IS NOT NULL
AND sleep_hours IS NOT NULL
GROUP BY relationship_status, sleep_categories
ORDER BY relationship_status, sleep_categories;


-- 2021
SELECT relationship_status,
	CASE 
		WHEN sleep_hours < 7 THEN 'Short sleep'
		WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
		WHEN sleep_hours > 9 THEN 'Long sleep'
	END AS sleep_categories,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY relationship_status), 2
	) AS pct_of_group
FROM demo_depression_2021 d
INNER JOIN sleep_2021 s
	ON d.respondent_id = s.respondent_id
WHERE relationship_status IS NOT NULL
AND sleep_hours IS NOT NULL
GROUP BY relationship_status, sleep_categories
ORDER BY relationship_status, sleep_categories;


-- Alcohol consumption distribution by relationship status

-- 2011
SELECT relationship_status,
	CASE 
		WHEN gender = 'Female' AND avg_drinks_per_drinking_day <= 1 THEN 'Moderate'
		WHEN gender = 'Male' AND avg_drinks_per_drinking_day <= 2 THEN 'Moderate'
		WHEN gender = 'Female' 
			AND avg_drinks_per_drinking_day > 1 
			AND avg_drinks_per_drinking_day <= 3 THEN 'Above Moderate'
		WHEN gender = 'Male' 
			AND avg_drinks_per_drinking_day > 2 
			AND avg_drinks_per_drinking_day <= 4 THEN 'Above Moderate'
		WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 3 THEN 'Heavy consumption'
		WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 4 THEN 'Heavy consumption'
	END AS alcohol_categories,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY relationship_status), 2
	) AS pct_of_total,
	COUNT(*)
FROM demo_depression_2011 d
INNER JOIN alcohol_2011 a
	ON d.respondent_id = a.respondent_id
WHERE avg_drinks_per_drinking_day IS NOT NULL 
AND relationship_status IS NOT NULL
GROUP BY relationship_status, alcohol_categories
ORDER BY relationship_status, alcohol_categories;


-- 2021
SELECT relationship_status,
	CASE 
		WHEN gender = 'Female' AND avg_drinks_per_drinking_day <= 1 THEN 'Moderate'
		WHEN gender = 'Male' AND avg_drinks_per_drinking_day <= 2 THEN 'Moderate'
		WHEN gender = 'Female' 
			AND avg_drinks_per_drinking_day > 1 
			AND avg_drinks_per_drinking_day <= 3 THEN 'Above Moderate'
		WHEN gender = 'Male' 
			AND avg_drinks_per_drinking_day > 2 
			AND avg_drinks_per_drinking_day <= 4 THEN 'Above Moderate'
		WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 3 THEN 'Heavy consumption'
		WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 4 THEN 'Heavy consumption'
	END AS alcohol_categories,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY relationship_status), 2
	) AS pct_of_total,
	COUNT(*)
FROM demo_depression_2021 d
INNER JOIN alcohol_2021 a
	ON d.respondent_id = a.respondent_id
WHERE avg_drinks_per_drinking_day IS NOT NULL 
AND relationship_status IS NOT NULL
GROUP BY relationship_status, alcohol_categories
ORDER BY relationship_status, alcohol_categories;


-- Income-to-poverty ratio

-- Sleep distribution by income-to-poverty ratio

-- 2011
WITH pir_sleep_2011 AS(
SELECT
	CASE 
		WHEN income_to_poverty_ratio < 1.0 THEN 'Below Poverty Level'
		WHEN income_to_poverty_ratio < 2.0 THEN 'Low Income'
		WHEN income_to_poverty_ratio < 4.0 THEN 'Middle Income'
		ELSE 'High-Income'
	END AS income_to_poverty,
	CASE 
		WHEN sleep_hours < 7 THEN 'Short sleep'
		WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
		WHEN sleep_hours > 9 THEN 'Long sleep'
	END AS sleep_categories,
	COUNT(*) AS n
FROM demo_depression_2011 d
INNER JOIN sleep_2011 s
	ON d.respondent_id = s.respondent_id
WHERE income_to_poverty_ratio IS NOT NULL
AND sleep_hours IS NOT NULL
GROUP BY income_to_poverty, sleep_categories
)
SELECT income_to_poverty, 
	sleep_categories,
	ROUND(
		100.0 * n / SUM(n) OVER (PARTITION BY income_to_poverty), 2
	) AS sleep_pct
FROM pir_sleep_2011
ORDER BY income_to_poverty, sleep_categories;


-- 2021
WITH pir_sleep_2021 AS(
SELECT
	CASE 
		WHEN income_to_poverty_ratio < 1.0 THEN 'Below Poverty Level'
		WHEN income_to_poverty_ratio < 2.0 THEN 'Low Income'
		WHEN income_to_poverty_ratio < 4.0 THEN 'Middle Income'
		ELSE 'High-Income'
	END AS income_to_poverty,
	CASE 
		WHEN sleep_hours < 7 THEN 'Short sleep'
		WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
		WHEN sleep_hours > 9 THEN 'Long sleep'
	END AS sleep_categories,
	COUNT(*) AS n
FROM demo_depression_2021 d
INNER JOIN sleep_2021 s
	ON d.respondent_id = s.respondent_id
WHERE income_to_poverty_ratio IS NOT NULL
AND sleep_hours IS NOT NULL
GROUP BY income_to_poverty, sleep_categories
)
SELECT income_to_poverty, 
	sleep_categories,
	ROUND(
		100.0 * n / SUM(n) OVER (PARTITION BY income_to_poverty), 2
	) AS sleep_pct
FROM pir_sleep_2021
ORDER BY income_to_poverty, sleep_categories;




-- Depression risk factor analysis
-- NHANES 2011-2012 and 2021-2022
-- Main risk factor focus: sleep, alcohol consumption, and BMI

-- Depression status distribution

-- 2011
SELECT depression_flag, 
	COUNT(*) AS n,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2
	) AS pct_of_total
FROM demo_depression_2011
WHERE depression_flag IS NOT NULL
GROUP BY depression_flag;


-- 2021
SELECT depression_flag, 
	COUNT(*) AS n,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2
	) AS pct_of_total
FROM demo_depression_2021
WHERE depression_flag IS NOT NULL
GROUP BY depression_flag;


-- Sleep distribution by depression status

-- 2011
SELECT 
	CASE 
		WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
		ELSE 'Not recommended'
	END AS sleep_categories,
	depression_flag, 
	COUNT(*) AS n,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY depression_flag), 2
	) AS pct_of_total
FROM demo_depression_2011 d
INNER JOIN sleep_2011 s
	ON d.respondent_id = s.respondent_id
WHERE depression_flag IS NOT NULL
	AND sleep_hours IS NOT NULL
GROUP BY sleep_categories, depression_flag;


-- 2021
SELECT 
	CASE 
		WHEN sleep_hours BETWEEN 7 AND 9 THEN 'Recommended'
		ELSE 'Not recommended'
	END AS sleep_categories,
	depression_flag, 
	COUNT(*) AS n,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY depression_flag), 2
	) AS pct_of_total
FROM demo_depression_2021 d
INNER JOIN sleep_2021 s
	ON d.respondent_id = s.respondent_id
WHERE depression_flag IS NOT NULL
	AND sleep_hours IS NOT NULL
GROUP BY sleep_categories, depression_flag;


-- Alcohol consumption distribution by depression status

-- 2011
SELECT 
	CASE 
		WHEN gender = 'Female' AND avg_drinks_per_drinking_day <= 1 THEN 'Moderate'
		WHEN gender = 'Male' AND avg_drinks_per_drinking_day <= 2 THEN 'Moderate'
		WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 1 THEN 'Above Moderate'
		WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 2 THEN 'Above Moderate'
	END AS alcohol_categories,
	depression_flag,
	COUNT(*) AS n,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY depression_flag), 2
	) AS pct_of_total
FROM demo_depression_2011 d
INNER JOIN alcohol_2011 a
	ON d.respondent_id = a.respondent_id
WHERE depression_flag IS NOT NULL
	AND avg_drinks_per_drinking_day IS NOT NULL
GROUP BY alcohol_categories, depression_flag;


-- 2021
SELECT 
	CASE 
		WHEN gender = 'Female' AND avg_drinks_per_drinking_day <= 1 THEN 'Moderate'
		WHEN gender = 'Male' AND avg_drinks_per_drinking_day <= 2 THEN 'Moderate'
		WHEN gender = 'Female' AND avg_drinks_per_drinking_day > 1 THEN 'Above Moderate'
		WHEN gender = 'Male' AND avg_drinks_per_drinking_day > 2 THEN 'Above Moderate'
	END AS alcohol_categories,
	depression_flag,
	COUNT(*) AS n,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY depression_flag), 2
	) AS pct_of_total
FROM demo_depression_2021 d
INNER JOIN alcohol_2021 a
	ON d.respondent_id = a.respondent_id
WHERE depression_flag IS NOT NULL
	AND avg_drinks_per_drinking_day IS NOT NULL
GROUP BY alcohol_categories, depression_flag;


-- BMI distribution by depression status

-- 2011
SELECT 
	CASE 
		WHEN bmi < 18.5 THEN 'Underweight'
		WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'Normal'
		WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'Overweight'
		WHEN bmi >= 30.0 THEN 'Obese'
	END AS bmi_categories,
	depression_flag,
	COUNT(*) AS n,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY depression_flag), 2
	) AS pct_of_total
FROM demo_depression_2011 d
INNER JOIN body_measurements_2011 b
	ON d.respondent_id = b.respondent_id
WHERE depression_flag IS NOT NULL
	AND bmi IS NOT NULL
GROUP BY bmi_categories, depression_flag;


-- 2021
SELECT 
	CASE 
		WHEN bmi < 18.5 THEN 'Underweight'
		WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'Normal'
		WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'Overweight'
		WHEN bmi >= 30.0 THEN 'Obese'
	END AS bmi_categories,
	depression_flag,
	COUNT(*) AS n,
	ROUND(
		100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY depression_flag), 2
	) AS pct_of_total
FROM demo_depression_2021 d
INNER JOIN body_measurements_2021 b
	ON d.respondent_id = b.respondent_id
WHERE depression_flag IS NOT NULL
	AND bmi IS NOT NULL
GROUP BY bmi_categories, depression_flag;



