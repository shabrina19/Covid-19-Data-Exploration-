-- Covid-19 Data Exploration

Select*
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- Select Data
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases, Total Deaths and Death Percentage
-- Shows likelihood of dying if you contract covid in Indonesia
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location='Indonesia' and continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population get Covid
Select Location, date, population, total_cases,  (total_cases/population)*100 as percent_population_infected
From PortfolioProject..CovidDeaths
order by 1,2

--Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as highest_infection_count,  MAX((total_cases/population))*100 as percent_population_infected
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by percent_population_infected desc

-- Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by total_death_count desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by total_death_count desc


-- GLOBAl NUMBERS

-- Percentage of deaths by date
Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

-- Total global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Total Population vs Vaccinations (Percentage of Population that has received at least one Covid Vaccine)
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
	dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null and dea.location like '%bania%'
Order by 2,3


-- Using CTE to perform calculation on partition by in previous query
With PopulationVSVaccination (Continent, Location, Date, Population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
	dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
)
SELECT *, (rolling_people_vaccinated/Population)*100
From PopulationVSVaccination


-- Using Temp Table to perform calculation on partition by in previous query

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
	dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date=vac.date

SELECT *, (rolling_people_vaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view for visualizations
use PortfolioProject -- This is my database name
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
	dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated



-- QUERY FOR TABLEAU VIZUALIZATION 

-- 1 Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- 2 Total death count by continent
Select location, SUM(cast(new_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income','High income','Lower middle income','Low income')  -- Take out values that don't need to include in continents
Group by location order by total_death_count desc

-- 3 Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as highest_infection_count,  MAX((total_cases/population))*100 as percent_population_infected
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by percent_population_infected desc

--4 Looking at Countries with Highest Infection Rate compared to Population no continent null
Select Location, population,date, MAX(total_cases) as highest_infection_count,  MAX((total_cases/population))*100 as percent_population_infected
From PortfolioProject..CovidDeaths
Group by location, population,date
order by percent_population_infected desc