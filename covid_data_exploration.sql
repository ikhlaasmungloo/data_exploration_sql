-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE Location LIKE '%mauritius%'
ORDER BY 1, 2

-- Looking at the Total Cases vs Population 
-- Shows percentage of population diagnsed with covid
SELECT Location, date, total_cases, Population, (total_cases/population)*100 AS diagnosed_percentage
FROM covid_deaths
WHERE Location LIKE '%mauritius%'
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to population size
SELECT Location, Population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS diagnosed_percentage
FROM covid_deaths
GROUP BY Location, Population
ORDER BY diagnosed_percentage DESC

-- showing countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY total_death_count DESC

--Breaking things down by continent
-- showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

-- Calculating global death percentage per day
SELECT 
    date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS death_percentage 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Calculating total global death percentage until date when data was retrieved 
SELECT 
    SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS death_percentage 
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Total population vs rolling vaccinations
SELECT 
    dea.continent, dea.location, dea.date, dea.population, 
    vac.new_vaccinations, SUM(CONVERT(numeric, vac.new_vaccinations))
    OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) 
    AS rolling_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON  dea.location =  vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3

-- Getting percentage of rolling vaccinations in populations using CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS 
(
SELECT 
    dea.continent, dea.location, dea.date, dea.population, 
    vac.new_vaccinations, SUM(CONVERT(numeric, vac.new_vaccinations))
    OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) 
    AS rolling_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON  dea.location =  vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (rolling_vaccinations/population)*100 AS rolling_vac_percentage
FROM pop_vs_vac

-- Getting percentage of rolling vaccinations in populations using TEMP TABLE
-- DROP TABLE IF EXISTS #percent_vaccinated
-- CREATE Table #percent_vaccinated
-- (
--     continent NVARCHAR(255),
--     location NVARCHAR(255),
--     Date DATETIME,
--     population NUMERIC,
--     new_vaccinations NUMERIC,
--     rolling_vaccinations NUMERIC
-- )
-- INSERT INTO #percent_vaccinated
-- SELECT 
--     dea.continent, dea.location, dea.date, dea.population, 
--     vac.new_vaccinations, SUM(CONVERT(numeric, vac.new_vaccinations))
--     OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) 
--     AS rolling_vaccinationss
-- FROM covid_deaths dea
-- JOIN covid_vaccinations vac
--     ON  dea.location =  vac.location
--     AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL

-- SELECT *, (rolling_vaccinations/population)*100 
-- FROM percent_vaccinated


-- Creating view for percentage of population who are vaccinated
CREATE VIEW percent_pop_vacinated AS
SELECT 
    dea.continent, dea.location, dea.date, dea.population, 
    vac.new_vaccinations, SUM(CONVERT(numeric, vac.new_vaccinations))
    OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) 
    AS rolling_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON  dea.location =  vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

