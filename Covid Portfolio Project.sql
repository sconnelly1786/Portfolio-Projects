

SELECT * FROM PortfolioProject..CovidVaccinations
WHERE continent is not null
order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2;

--Looking at the total cases vs population
--Shows what percentage of population got COVID

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2;


--Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
GROUP BY Location, Population
Order by PercentPopulationInfected desc

--Showing the countries with the highest death count per population
SELECT Location, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--Where location like '%states%'
GROUP BY Location, Population
Order by TotalDeathCount desc


--Showing continents with the highest death count

SELECT continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--Where location like '%states%'
GROUP BY continent
Order by TotalDeathCount desc

--Global Numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as INT)) AS TotalDeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
GROUP BY date
Order by 1,2

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--Use CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 FROM PopvsVac

--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100 FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3