SELECT *
FROM PortfolioProject1..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject1..CovidVaccinations
--ORDER BY 3,4


--Select the data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2


--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at total cases by population
--Shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CovidCasesPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Looking at countries with highest infection rates compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Showing the countries with the highest death count per population
SELECT location, MAX(cast(total_deaths AS int)) AS TotaldeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotaldeathCount DESC


--LET's break things down by continent
SELECT continent, MAX(cast(total_deaths AS int)) AS TotaldeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotaldeathCount DESC


--LET's break things down by continent
SELECT location, MAX(cast(total_deaths AS int)) AS TotaldeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotaldeathCount DESC


--Showing continent with the highest death count per population
SELECT continent, MAX(cast(total_deaths AS int)) AS TotaldeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotaldeathCount DESC



--Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) AS total_death, SUM(CAST(new_deaths as INT))/SUM(new_cases)
FROM PortfolioProject1..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2



--Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition BY  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccination
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccination)
as
(
	SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition BY  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccination
	FROM PortfolioProject1..CovidDeaths dea
	JOIN PortfolioProject1..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccination/population)
FROM PopvsVac



--Temp Table
DROP TABLE If exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition BY  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject1..CovidDeaths dea
	JOIN PortfolioProject1..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition BY  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccination
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated