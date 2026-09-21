-- Create tables for imported NHANES data
-- 2011-2012 and 2021-2022 cycles


-- Alcohol

CREATE TABLE alcohol_2011 (
	respondent_id INTEGER,
	avg_drinks_per_drinking_day TEXT,
	PRIMARY KEY (respondent_id)
);

CREATE TABLE alcohol_2021 (
	respondent_id INTEGER,
	avg_drinks_per_drinking_day TEXT,
	PRIMARY KEY (respondent_id)
);


-- Body measurements

CREATE TABLE body_measurements_2011 (
	respondent_id INT,
	weight_kg NUMERIC,
	height_cm NUMERIC,
	bmi NUMERIC,
	waist_circumference_cm NUMERIC,
	PRIMARY KEY(respondent_id)
);

CREATE TABLE body_measurements_2021 (
	respondent_id INT,
	weight_kg NUMERIC,
	height_cm NUMERIC,
	bmi NUMERIC,
	waist_circumference_cm NUMERIC,
	PRIMARY KEY(respondent_id)
);


-- Demographics

CREATE TABLE demographics_2011 (
	respondent_id INT,
	gender TEXT,
	age INT,
	race TEXT,
	served_active_duty BOOLEAN,
	education TEXT,
	relationship_status TEXT,
	income_to_poverty_ratio NUMERIC,
	PRIMARY KEY(respondent_id)
);

CREATE TABLE demographics_2021 (
	respondent_id INT,
	gender TEXT,
	age INT,
	race TEXT,
	served_active_duty BOOLEAN,
	education TEXT,
	relationship_status TEXT,
	income_to_poverty_ratio NUMERIC,
	PRIMARY KEY(respondent_id)
);


-- Sleep

CREATE TABLE sleep_2011(
	respondent_id INT,
	sleep_hours INT,
	PRIMARY KEY(respondent_id)
);

CREATE TABLE sleep_2021(
	respondent_id INT,
	sleep_hours INT,
	PRIMARY KEY(respondent_id)
);


-- Smoking

CREATE TABLE smoking_2011 (
	respondent_id INT,
	smoked_at_least_100_cigarettes BOOLEAN,
	currently_smokes TEXT,
	smoking_days_past_30_days TEXT,
	average_cigarettes_per_day INT,
	PRIMARY KEY(respondent_id)
);

CREATE TABLE smoking_2021 (
	respondent_id INT,
	smoked_at_least_100_cigarettes BOOLEAN,
	currently_smokes TEXT,
	smoking_days_past_30_days TEXT,
	average_cigarettes_per_day INT,
	PRIMARY KEY(respondent_id)
);


-- Depression

CREATE TABLE depression_2011(
	respondent_id INT,
	little_interest TEXT,
	feeling_down TEXT,
	sleep_issues TEXT,
	fatigue TEXT,
	appetite_issues TEXT,
	low_self_worth TEXT, 
	concentration_difficulty TEXT,
	psychomotor_changes TEXT,
	death_or_self_harm_thoughts TEXT,
	functional_impairment TEXT,
	phq9_score INT,
	PRIMARY KEY (respondent_id)
);

CREATE TABLE depression_2021(
	respondent_id INT,
	little_interest TEXT,
	feeling_down TEXT,
	sleep_issues TEXT,
	fatigue TEXT,
	appetite_issues TEXT,
	low_self_worth TEXT, 
	concentration_difficulty TEXT,
	psychomotor_changes TEXT,
	death_or_self_harm_thoughts TEXT,
	functional_impairment TEXT,
	phq9_score INT,
	PRIMARY KEY (respondent_id)
);


-- Blood pressure

CREATE TABLE blood_pressure_2011(
	respondent_id INT,
	avg_systolic_bp INT,
	avg_dialostic_bp INT,
	avg_pulse INT,
	PRIMARY KEY(respondent_id)
);

CREATE TABLE blood_pressure_2021(
	respondent_id INT,
	avg_systolic_bp INT,
	avg_dialostic_bp INT,
	avg_pulse INT,
	PRIMARY KEY(respondent_id)
);


-- Create reusable views combining demographic and depression data

CREATE VIEW demo_depression_2011 AS
SELECT demo.respondent_id,
	demo.gender,
	demo.age,
	demo.race, 
	demo.served_active_duty, 
	demo.relationship_status,
	demo.income_to_poverty_ratio,
	dp.phq9_score,
	CASE WHEN dp.phq9_score >= 10 THEN 1 ELSE 0
	END AS depression_flag
FROM demographics_2011 demo
INNER JOIN depression_2011 dp
	ON demo.respondent_id = dp.respondent_id
WHERE dp.phq9_score IS NOT NULL;


CREATE VIEW demo_depression_2021 AS
SELECT demo.respondent_id,
	demo.gender,
	demo.age,
	demo.race, 
	demo.served_active_duty, 
	demo.relationship_status,
	demo.income_to_poverty_ratio,
	dp.phq9_score,
	CASE WHEN dp.phq9_score >= 10 THEN 1 ELSE 0
	END AS depression_flag
FROM demographics_2021 demo
INNER JOIN depression_2021 dp
	ON demo.respondent_id = dp.respondent_id
WHERE dp.phq9_score IS NOT NULL;
