/*
Queries used for Tableau Project done in postgres
*/



-- 1. 

SELECT
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths AS int)) AS total_deaths,
	SUM(cast(new_deaths AS int)) / SUM(New_Cases) * 100 AS DeathPercentage
FROM
	"CovidDeaths"
	--Where location like '%states%'
WHERE
	continent IS NOT NULL AND continent != ''
	--Group By date
ORDER BY
	1,
	2;

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT
	"location",
	SUM(cast(new_deaths AS int)) AS TotalDeathCount
FROM
	"CovidDeaths"
WHERE
	continent = ''
	AND "location" NOT IN('World', 'European Union', 'International')
GROUP BY
	"location"
ORDER BY
	TotalDeathCount DESC;


-- 3.

SELECT
	"location",
	population,
	COALESCE(MAX(total_cases),0) AS HighestInfectionCount,
	COALESCE(Max((total_cases / population)) * 100 ,0) as PercentPopulationInfected
FROM
	"CovidDeaths"
GROUP BY
	"location",
	population
ORDER BY
	PercentPopulationInfected DESC;


-- 4.
SELECT
	"location",
	population,
	to_char(date, 'mm/dd/YYYY') AS date,
	COALESCE(MAX(total_cases), 0) AS HighestInfectionCount,
	COALESCE(Max((total_cases / population)) * 100, 0) AS PercentPopulationInfected
FROM
	"CovidDeaths"
GROUP BY
	"location",
	population,
	date
ORDER BY
	PercentPopulationInfected DESC;

