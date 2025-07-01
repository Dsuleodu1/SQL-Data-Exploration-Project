/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


-- Select Data That we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Projects..CovidDeaths1
Where continent is not null
Order by 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Projects..CovidDeaths1
Where Location like '%states%'
Where continent is not null
Order by 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of population innfected with Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From Projects..CovidDeaths1
--Where Location like '%states%'
Where continent is not null
Order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as
	PercentPopulationInfected
From Projects..CovidDeaths1
--Where Location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Projects..CovidDeaths1
--Where Location like '%states
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Projects..CovidDeaths1
--Where Location like '%states
Where continent is not null
Group by continent
Order by TotalDeathCount desc




-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Projects..CovidDeaths1
--Where Location like '%states
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
	(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Projects..CovidDeaths1
--Where Location like '%states%'
Where continent is not null
--Group by date
Order by 1,2





-- Looking at Total Population vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
from projects..CovidDeaths1 dea
Join projects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3



--  Using CTE to perform Calculation on Partition By in previous query


With PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
from projects..CovidDeaths1 dea
Join projects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopsVac



-- Using Temp Table to perform Calculation on Partition By in previous query


DROP table if exist #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255,
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)


Insert into
Select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
from projects..CovidDeaths1 dea
Join projects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations



Create View PercentPopulationVaccinated as
Select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
from projects..CovidDeaths1 dea
Join projects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3



Select *
From PercentPopulationVaccinated