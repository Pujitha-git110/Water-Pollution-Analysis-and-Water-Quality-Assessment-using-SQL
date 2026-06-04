  -- Create Schema
create schema water_pollution
-- use schema 
 USE water_pollution;
 -- create table
CREATE TABLE final_data (
    station_code INT,
    station_name VARCHAR(255),
    state_name VARCHAR(100),
    temp_min FLOAT,
    temp_max FLOAT,
    temp_mean FLOAT,
    ph_min FLOAT,
    ph_max FLOAT,
    ph_mean FLOAT,
    conductivity_min FLOAT,
    conductivity_max FLOAT,
    conductivity_mean FLOAT,
    bod_min FLOAT,
    bod_max FLOAT,
    bod_mean FLOAT,
    nitrate_min FLOAT,
    nitrate_max FLOAT,
    nitrate_mean FLOAT,
    fecal_min FLOAT,
    fecal_max FLOAT,
    fecal_mean FLOAT,
    total_coliform_min FLOAT,
    total_coliform_max FLOAT,
    total_coliform_mean FLOAT,
    year INT
);
 -- changing column name station code
ALTER TABLE water_pollution.final_data1
RENAME COLUMN `ï»¿  station_code` TO station_code;
 -- Display first 10 rows 
SELECT * FROM water_pollution.final_data1 LIMIT 10;
 -- counting the rows
select count(*) from water_pollution.final_data1;
 -- checking null count in every column
SELECT 
    COUNT(*) AS total_rows,
     SUM(station_code IS NULL) AS station_code_nulls,
    SUM(station_name IS NULL) AS station_name_nulls,
    SUM(state_name IS NULL) AS state_name_nulls,
    SUM(temp_min IS NULL) AS temp_min_nulls,
    SUM(temp_max IS NULL) AS temp_max_nulls,
    SUM(temp_mean IS NULL) AS temp_mean_nulls,
    SUM(ph_min IS NULL) AS ph_min_nulls,
    SUM(ph_max IS NULL) AS ph_max_nulls,
    SUM(ph_mean IS NULL) AS ph_mean_nulls,

    SUM(conductivity_min IS NULL) AS conductivity_min_nulls,
    SUM(conductivity_max IS NULL) AS conductivity_max_nulls,
    SUM(conductivity_mean IS NULL) AS conductivity_mean_nulls,
    SUM(bod_min IS NULL) AS bod_min_nulls,
    SUM(bod_max IS NULL) AS bod_max_nulls,
    SUM(bod_mean IS NULL) AS bod_mean_nulls,
    SUM(nitrate_min IS NULL) AS nitrate_min_nulls,
    SUM(nitrate_max IS NULL) AS nitrate_max_nulls,
    SUM(nitrate_mean IS NULL) AS nitrate_mean_nulls,
    SUM(year IS NULL) AS year_nulls
FROM water_pollution.final_data1;
 -- describe the table
DESCRIBE water_pollution.final_data1;

ALTER TABLE water_pollution.final_data1 
MODIFY COLUMN station_name TEXT NOT NULL,
MODIFY COLUMN state_name TEXT NOT NULL,
MODIFY temp_min DOUBLE NOT NULL,
MODIFY temp_max DOUBLE NOT NULL,
MODIFY temp_mean DOUBLE NOT NULL;
 -- calculating average temperatures and temp range by state name and year wise
SELECT 
    state_name, 
    year, 
    ROUND(AVG(temp_mean), 2) AS avg_yearly_temp,
    MAX(temp_max) - MIN(temp_min) AS temp_range
FROM water_pollution.final_data1
GROUP BY state_name, year
ORDER BY avg_yearly_temp DESC;
 -- top 10 locations (stations) where the temperature difference is highest
SELECT 
    state_name, 
    station_name, 
    year,
    (temp_max - temp_min) AS temp_fluctuation
FROM water_pollution.final_data1
ORDER BY temp_fluctuation DESC
LIMIT 10;
 -- finds rows with extreme temperature values
SELECT * FROM water_pollution.final_data1
WHERE temp_max > 60  
   OR temp_min < -50; 
-- create a view
CREATE VIEW water_pollution.annual_climate_report AS
SELECT 
    state_name,
    COUNT(station_code) AS total_stations,
    year,
    ROUND(AVG(temp_min), 2) AS avg_min,
    ROUND(AVG(temp_max), 2) AS avg_max,
    ROUND(AVG(temp_mean), 2) AS state_yearly_avg
FROM water_pollution.final_data1
GROUP BY state_name, year;

SELECT * FROM water_pollution.annual_climate_report;

-- Finding the highest average temperatures by state
SELECT state_name, year, AVG(temp_max) as peak_temp
FROM water_pollution.final_data1
GROUP BY state_name, year
ORDER BY peak_temp DESC
LIMIT 5;

-- Finding the lowest average temperatures by state
SELECT state_name, year, AVG(temp_max) as peak_temp
FROM water_pollution.final_data1
GROUP BY state_name, year
ORDER BY peak_temp asc
LIMIT 5;
-- calculating midpoint and variance
SELECT *, 
       (temp_max + temp_min) / 2 AS calculated_midpoint,
       ROUND(ABS(temp_mean - ((temp_max + temp_min) / 2)),2) AS variance
FROM water_pollution.final_data1
ORDER BY variance DESC
LIMIT 10;
-- categorizing the data based on variance 
SELECT 
    state_name, 
    station_name, 
    year,
    ROUND(ABS(temp_mean - ((temp_max + temp_min) / 2)), 2) AS variance,
    CASE 
        WHEN ABS(temp_mean - ((temp_max + temp_min) / 2)) >= 2.0 THEN 'High Volatility'
        WHEN ABS(temp_mean - ((temp_max + temp_min) / 2)) BETWEEN 1.0 AND 1.99 THEN 'Moderate'
        ELSE 'Stable'
    END AS weather_category
FROM water_pollution.final_data1
ORDER BY variance DESC;
-- Find correlation-like relationships (simplified check)
SELECT 
    state_name, 
    AVG(bod_mean) as avg_bod, 
    AVG(total_coliform_mean) as avg_coliform
FROM water_pollution.final_data1
GROUP BY state_name
ORDER BY avg_bod DESC;
-- Identify Nitrate Hotspots
SELECT station_name, state_name, year, nitrate_mean
FROM water_pollution.final_data1
WHERE nitrate_mean > 10
ORDER BY nitrate_mean DESC;
-- pollution index(bod,nitrate,total coliform)
WITH MinMax AS (
    SELECT 
        MIN(bod_mean) as min_bod, MAX(bod_mean) as max_bod,
        MIN(nitrate_mean) as min_nit, MAX(nitrate_mean) as max_nit,
        MIN(total_coliform_mean) as min_col, MAX(total_coliform_mean) as max_col
    FROM water_pollution.final_data1
)
SELECT 
    station_name, 
    state_name, 
    year,
    ROUND(
        ( ((bod_mean - min_bod) / (max_bod - min_bod)) * 0.4 +
          ((nitrate_mean - min_nit) / (max_nit - min_nit)) * 0.3 +
          ((total_coliform_mean - min_col) / (max_col - min_col)) * 0.3 
        ) * 100, 2
    ) AS pollution_index
FROM water_pollution.final_data1, MinMax
ORDER BY pollution_index DESC
LIMIT 20;
-- pH Categorization (Acidity vs Alkalinity vs neutral)
SELECT 
    CASE 
        WHEN ph_mean < 6.5 THEN 'Acidic'
        WHEN ph_mean > 8.5 THEN 'Alkaline'
        ELSE 'Neutral'
    END AS ph_category,
    COUNT(*) AS total_stations,
    ROUND(AVG(ph_mean), 2) AS avg_ph
FROM water_pollution.final_data1
GROUP BY 1
ORDER BY total_stations DESC;
-- State-Wise Pollution Ranking
SELECT 
    state_name,
    ROUND(AVG(bod_mean), 2) AS avg_bod,
    ROUND(AVG(nitrate_mean), 2) AS avg_nitrate,
    ROUND(AVG(total_coliform_mean), 0) AS avg_coliform,
    COUNT(station_code) AS monitoring_stations
FROM water_pollution.final_data1
GROUP BY state_name
HAVING avg_bod > 3.0 OR avg_nitrate > 5.0
ORDER BY avg_bod DESC;
-- Yearly Trend for Telangan state
SELECT 
    year,
    ROUND(AVG(bod_mean), 2) AS yearly_avg_bod,
    ROUND(AVG(total_coliform_mean), 0) AS yearly_avg_coliform,
    MAX(bod_max) AS peak_organic_pollution
FROM water_pollution.final_data1
WHERE state_name = 'TELANGANA'
GROUP BY year
ORDER BY year ASC;
-- High Conductivity & Salinity Check
SELECT 
    station_name, 
    state_name, 
    conductivity_mean,
    ph_mean
FROM water_pollution.final_data1
WHERE conductivity_mean > 10000
ORDER BY conductivity_mean DESC;

-- Create a view for easy reporting on water quality and pollution risk
CREATE VIEW water_pollution.v_pollution_analysis AS
WITH Stats AS (
    SELECT 
        MIN(bod_mean) as min_b, MAX(bod_mean) as max_b,
        MIN(nitrate_mean) as min_n, MAX(nitrate_mean) as max_n,
        MIN(total_coliform_mean) as min_c, MAX(total_coliform_mean) as max_c
    FROM water_pollution.final_data1
)
SELECT 
    d.*,
    -- Normalized Pollution Index Calculation (40% BOD, 30% Nitrate, 30% Coliform)
    ROUND(
        ( ((bod_mean - min_b) / NULLIF(max_b - min_b, 0)) * 0.4 +
          ((nitrate_mean - min_n) / NULLIF(max_n - min_n, 0)) * 0.3 +
          ((total_coliform_mean - min_c) / NULLIF(max_c - min_c, 0)) * 0.3 
        ) * 100, 2
    ) AS pollution_index,
    -- pH Category logic
    CASE 
        WHEN ph_mean < 6.5 THEN 'Acidic'
        WHEN ph_mean > 8.5 THEN 'Alkaline'
        ELSE 'Neutral'
    END AS water_type
FROM water_pollution.final_data1 d, Stats;
-- Top 10 Most Polluted Stations
SELECT station_name, state_name, pollution_index, bod_mean, total_coliform_mean
FROM water_pollution.v_pollution_analysis
ORDER BY pollution_index DESC
LIMIT 10;
--  Top 10 Most cleanest Stations
SELECT station_name, state_name, pollution_index, bod_mean, nitrate_mean
FROM water_pollution.v_pollution_analysis
WHERE pollution_index > 0
ORDER BY pollution_index ASC
LIMIT 10;
-- Year-wise individual parameters
SELECT 
    Year,
    ROUND(AVG(bod_mean), 2) AS avg_bod,
    ROUND(AVG(nitrate_mean), 2) AS avg_nitrate,
    ROUND(AVG(total_coliform_mean), 2) AS avg_coliform
FROM water_pollution.final_data1
GROUP BY Year
ORDER BY Year;
-- Year-wise pollution category
SELECT 
    Year,
    ROUND(AVG(bod_mean + nitrate_mean + total_coliform_mean) / 3, 2) AS pollution_value,
    CASE 
        WHEN AVG(bod_mean + nitrate_mean + total_coliform_mean) / 3 < 30 THEN 'Low Pollution'
        WHEN AVG(bod_mean + nitrate_mean + total_coliform_mean) / 3 BETWEEN 30 AND 60 THEN 'Moderate Pollution'
        ELSE 'High Pollution'
    END AS pollution_level
FROM water_pollution.final_data1
GROUP BY Year
ORDER BY Year;
-- Year+state pollution category
SELECT 
    Year, state_name,
    ROUND(AVG(bod_mean + nitrate_mean + total_coliform_mean) / 3, 2) AS pollution_value,
    CASE 
        WHEN AVG(bod_mean + nitrate_mean + total_coliform_mean) / 3 < 30 THEN 'Low Pollution'
        WHEN AVG(bod_mean + nitrate_mean + total_coliform_mean) / 3 BETWEEN 30 AND 60 THEN 'Moderate Pollution'
        ELSE 'High Pollution'
    END AS pollution_level
FROM water_pollution.final_data1
GROUP BY Year, state_name
ORDER BY Year, pollution_value;
        
   