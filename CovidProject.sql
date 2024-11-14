SELECT * FROM [Covid Project] ..CovidDeaths
WHERE continent is not null
order by 3,4

SELECT * FROM [Covid Project] ..CovidVaccinations
order by 3,4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population FROM [Covid Project] ..CovidDeaths
order by 1,2

-- Shows what percentage of total cases result in deaths
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/total_cases)*100 as death_percentage FROM [Covid Project] ..CovidDeaths
WHERE location like '%kingdom%'
order by 1,2

-- -- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (CAST(total_cases AS float)/population)*100 as covidpop_percentage FROM [Covid Project] ..CovidDeaths
WHERE location like '%kingdom%'
order by 1,2

-- Looking at countries with highest infection rates compared to population
SELECT location, population, MAX(total_cases) as highestInfectionCount, MAX(CAST(total_cases AS float)/population)*100 as populationInfectedPercentage FROM [Covid Project] ..CovidDeaths
group by location, population
order by populationInfectedPercentage desc

-- Showing countries with highest death count 
SELECT location, MAX(CAST(total_deaths AS int)) as totalDeathCount
FROM [Covid Project] ..CovidDeaths
WHERE continent is not null
group by location
order by totalDeathCount desc

-- Showing continent with the highest death count
SELECT continent, MAX(CAST(total_deaths AS int)) as totalDeathCount
FROM [Covid Project] ..CovidDeaths
WHERE continent is not null
group by continent
order by totalDeathCount desc 

-- Global numbers
SELECT date, SUM(new_cases) as totalNewCases, SUM(new_deaths) as totalNewDeaths, (SUM(CAST(new_deaths AS float))/SUM(new_cases))*100 as deathPercentage FROM [Covid Project] ..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total new cases and total new deaths
SELECT SUM(new_cases) as totalNewCases, SUM(new_deaths) as totalNewDeaths, (SUM(CAST(new_deaths AS float))/SUM(new_cases))*100 as deathPercentage FROM [Covid Project] ..CovidDeaths
where continent is not null
order by 1,2

-- Use CET
WITH popVsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
AS
(
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date,CovidDeaths.population, CovidVaccinations.new_vaccinations, SUM(CovidVaccinations.new_vaccinations) OVER (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as rollingPeopleVaccinated 
FROM [Covid Project]..CovidDeaths
JOIN [Covid Project]..CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location 
AND CovidDeaths.date = CovidVaccinations.date 
WHERE CovidDeaths.continent is not null
)
SELECT *, (CAST(rollingPeopleVaccinated AS float)/population)*100 as percentagePopVaccinated
FROM popVsVac



-- Creating view to store data for later visualisation
CREATE VIEW popVsVac as 
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date,CovidDeaths.population, CovidVaccinations.new_vaccinations, SUM(CovidVaccinations.new_vaccinations) OVER (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as rollingPeopleVaccinated 
FROM [Covid Project]..CovidDeaths
JOIN [Covid Project]..CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location 
AND CovidDeaths.date = CovidVaccinations.date 
WHERE CovidDeaths.continent is not null

SELECT * FROM popVsVac