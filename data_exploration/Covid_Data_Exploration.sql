-- SELECT data that we are going to be using
SELECT *--"location", "date", total_cases, new_cases, total_deaths, population
FROM "CovidDeaths" 
WHERE continent is not null
ORDER BY 1,2;

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covide in your country
SELECT "location", "date", total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM "CovidDeaths"
--WHERE "location" like '%States%'
WHERE continent is not null
ORDER BY 1,2;

-- Looking at the total cases vs the population
-- Show the percentage of population that got covid
SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 as cases_per_pop
FROM "CovidDeaths"
WHERE continent is not null
--WHERE location like '%States%'
ORDER BY 1,2;

--Looking at the total deaths vs the population
-- Show the percentage of population dead from covid 
SELECT location, date, total_cases, total_deaths, population, (total_deaths/population)*100 as deaths_per_pop
FROM "CovidDeaths"
WHERE continent is not null
--WHERE location LIKE '%Senegal'
ORDER BY 1,2;

-- Looking at transmission rate
--Looking at countries with highest infection rate compared to population
SELECT location,population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as percent_population_infected
FROM "CovidDeaths"
WHERE continent is not null
--WHERE location LIKE '%Senegal'
GROUP BY location,population
ORDER BY percent_population_infected DESC;

-- Showing the countries with the highest death count per population
SELECT location, MAX(total_deaths) as highest_death_count --MAX((total_deaths/population))*100 as percent_population_dead
FROM "CovidDeaths"
WHERE continent IS NOT NULL AND continent != ''
GROUP BY "location"
ORDER BY highest_death_count DESC;

-- Showing the countries with the highest death count per continent
SELECT continent, MAX(total_deaths) as TotalDeathCount 
FROM "CovidDeaths"
WHERE continent IS NOT NULL AND continent != ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Showing the continents with the highest death COUNT
SELECT continent, MAX(total_deaths) as TotalDeathCount 
FROM "CovidDeaths"
WHERE continent IS NOT NULL AND continent != ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Joinning the two tables

SELECT dea.continent, dea."location", dea."date", dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea."location" ORDER BY dea."location",dea."date") as RollingPeopleVaccinated
FROM "CovidDeaths" as dea
JOIN "CovidVaccinations" as vac
ON dea."date" = vac."date" AND dea."location" = vac."location"
WHERE dea.continent IS NOT NULL AND dea.continent !=''
ORDER BY 2,3;

-- USE CTE for RollingPeopleVaccinated Max on population
WITH PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS(
SELECT dea.continent, dea."location", dea."date", dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea."location" ORDER BY dea."location",dea."date") as RollingPeopleVaccinated
FROM "CovidDeaths" as dea
JOIN "CovidVaccinations" as vac
ON dea."date" = vac."date" AND dea."location" = vac."location"
WHERE dea.continent IS NOT NULL AND dea.continent !=''
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as rol_per_pop FROM PopvsVac;

-- TEMP tables USE
CREATE TEMPORARY TABLE percentpopulationvaccinated
(
continent TEXT,
location TEXT,
"date" DATE,
population FLOAT8,
new_vaccinations FLOAT8,
RollingPeopleVaccinated FLOAT8
)
--INSERT INTO PercentPopulationVaccinated(continent,location,"date",population,new_vaccinations,RollingPeopleVaccinated) 
SELECT dea.continent, dea."location", dea."date", dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea."location" ORDER BY dea."location",dea."date") as RollingPeopleVaccinated
INTO TEMPORARY TABLE percentpopulationvaccinated
FROM "CovidDeaths" as dea
JOIN "CovidVaccinations" as vac
ON dea."date" = vac."date" AND dea."location" = vac."location"
WHERE dea.continent IS NOT NULL AND dea.continent !=''

SELECT *,(RollingPeopleVaccinated/population)*100 as rol_per_pop FROM percentpopulationvaccinated
DROP TABLE percentpopulationvaccinated;


-- Creating view to store data for vizualisation

CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent, dea."location", dea."date", dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea."location" ORDER BY dea."location",dea."date") as RollingPeopleVaccinated
FROM "CovidDeaths" as dea
JOIN "CovidVaccinations" as vac
ON dea."date" = vac."date" AND dea."location" = vac."location"
WHERE dea.continent IS NOT NULL AND dea.continent !='';

SELECT * FROM percentpopulationvaccinated;