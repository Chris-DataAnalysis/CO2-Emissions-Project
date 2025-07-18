--Inspect the Schema 
PRAGMA table_info(emissions);

--Inspect first 10 rows of data 
SELECT * FROM emissions LIMIT 10;

--See which countries are included 
SELECT DISTINCT country
FROM emissions
ORDER BY country;

--Check for NULLS in key columns 
SELECT COUNT(*) AS total_rows FROM emissions;

SELECT COUNT(*) AS missing_co2 FROM emissions WHERE co2 IS NULL;

SELECT COUNT(*) AS missing_country FROM emissions WHERE country IS NULL;

SELECT COUNT(*) AS missing_year FROM emissions WHERE year IS NULL;

--Remove non-country rows 
CREATE VIEW emissions_clean AS
SELECT *
FROM emissions
WHERE co2 IS NOT NULL
  AND country NOT IN (
    'Africa', 'Africa (GCP)', 'Asia', 'Asia (GCP)', 'Asia (excl. China and India)',
    'Central America (GCP)', 'Europe', 'Europe (GCP)', 'Europe (excl. EU-27)',
    'Europe (excl. EU-28)', 'European Union (27)', 'European Union (28)',
    'North America', 'North America (GCP)', 'North America (excl. USA)',
    'South America', 'South America (GCP)', 'Oceania', 'Oceania (GCP)',
    'Middle East (GCP)', 'Non-OECD (GCP)', 'OECD (GCP)', 'OECD (Jones et al.)',
    'High-income countries', 'Low-income countries', 'Lower-middle-income countries',
    'Upper-middle-income countries', 'Least developed countries (Jones et al.)',
    'World', 'International transport', 'International aviation', 'International shipping',
    'Kuwaiti Oil Fires', 'Kuwaiti Oil Fires (GCP)',
    'Ryukyu Islands', 'Ryukyu Islands (GCP)'
	);
	
--Review cleaned version 
SELECT DISTINCT country
FROM emissions_clean
ORDER BY country;
 
SELECT COUNT(*) FROM emissions_clean;
SELECT MIN(year), MAX(year) FROM emissions_clean;

--Global CO2 Emmisions Over time
SELECT
year,
SUM(COALESCE(co2, 0)) AS global_emissions
FROM emissions_clean
GROUP BY year
ORDER BY year;

--CO₂ Emissions Per Capita by Country (2023)
SELECT
country,
COALESCE(CAST(co2_per_capita AS REAL), 0) AS co2_per_capita
FROM emissions_clean
WHERE year = 2022
ORDER BY co2_per_capita DESC;

--Top 10 emitters in 2023
SELECT
country,
COALESCE(CAST(co2 AS REAL), 0) AS total_co2
FROM emissions_clean
WHERE year = 2023
ORDER BY total_co2 DESC
LIMIT 10;

SELECT
country,
COALESCE(coal_co2, 0) AS coal,
COALESCE(gas_co2, 0) AS gas,
COALESCE(oil_co2, 0) AS oil
FROM emissions_clean
WHERE year = 2022
  AND country IN ('China', 'United States', 'India', 'Russia', 'Japan', 'Iran',
				'Indonesia', 'Germany', 'Saudi Arabia', 'South Korea');

--GDP per Capita vs CO2 per Capita (2023)
SELECT
  country,
  ROUND(COALESCE(co2_per_capita, 0), 2) AS co2_pc,
  ROUND(COALESCE(gdp, 0) / COALESCE(population, 1), 2) AS gdp_pc
FROM emissions_clean
WHERE year = 2022
  AND gdp IS NOT NULL
  AND population IS NOT NULL
  AND co2_per_capita IS NOT NULL;
  
--Top 10 Biggest rises and drops (2013-2023)
WITH emissions_2013 AS (
  SELECT country, co2
  FROM emissions_clean
  WHERE year = 2013
),
emissions_2023 AS (
  SELECT country, co2
  FROM emissions_clean
  WHERE year = 2023
)
SELECT 
  e2023.country,
  ROUND(e2023.co2 - e2013.co2, 2) AS co2_change,
  e2023.co2 AS co2_2023,
  e2013.co2 AS co2_2013
FROM emissions_2023 e2023
JOIN emissions_2013 e2013 ON e2023.country = e2013.country
WHERE e2023.co2 IS NOT NULL AND e2013.co2 IS NOT NULL
ORDER BY ABS(e2023.co2 - e2013.co2) DESC
LIMIT 10;

 
 




