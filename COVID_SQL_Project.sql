SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- SELECTING THE NECESSARY DATA 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- total_cases vs total_deaths
-- Shows percentage of dying if you contract COVID in PH

SELECT location, date, total_cases, total_deaths,
CONVERT(float,total_deaths)/ NULLIF(CONVERT(float,total_cases),0)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Philippines' AND WHERE continent IS NOT NULL
ORDER BY location, date

-- total_cases vs population
-- shows percentage of population contracted with covid
SELECT location, date, population, total_cases,
(total_cases/population)*100  as CasePercentage
FROM CovidDeaths
WHERE location = 'Philippines' AND WHERE continent IS NOT NULL
ORDER BY location, date

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population)*100) as HighCasePercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighCasePercentage DESC


-- Showing the countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing the continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers 

SELECT SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths, 
CASE
WHEN SUM(new_cases) = 0 THEN 0
ELSE SUM(new_deaths)/ NULLIF(SUM(new_cases),0) * 100
END as DeathPercenatage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY date


-- total population vs total vaccinations

SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY dea.location, dea.date

--CTE
WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)
SELECT *, (RollingPeopleVaccinated / population) * 100 as VacPercentage
FROM PopVSVac

CREATE View VacPercentage as 
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY dea.location, dea.date

SELECT *
FROM VacPercentage

--Query used for Tableau

-- DeathPercentage
SELECT SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths, 
CASE
WHEN SUM(new_cases) = 0 THEN 0
ELSE SUM(new_deaths)/ NULLIF(SUM(new_cases),0) * 100
END as DeathPercenatage
FROM CovidDeaths
WHERE continent IS NOT NULL

--total_death_count per location where continent is null
SELECT location, SUM(CONVERT(int,new_deaths)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World','High income', 'Upper middle income', 'Lower middle income', 'European Union', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC

--Highest_Infection_Count and Population_infected_percentage
SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 as Population_infected_percentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY Population_infected_percentage DESC

--Highest_Infection_Count and Population_infected_percentage by date
SELECT location, population, date, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 as Population_infected_percentage
FROM CovidDeaths
GROUP BY location, population, date
ORDER BY Population_infected_percentage DESC