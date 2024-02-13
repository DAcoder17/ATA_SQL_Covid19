
SELECT * 
From COVID19..CovidDeaths$
Where continent is not NULL
order by 3,4

--SELECT * 
--From COVID19..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
From COVID19..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From COVID19..CovidDeaths$
Where location like '%Col%'
order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as PopulationInfectedPercentage
From COVID19..CovidDeaths$
Where location like '%Col%'
order by 1,2

--Looking at Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From COVID19..CovidDeaths$
--Where location like '%Col%'
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From COVID19..CovidDeaths$
--Where location like '%Col%'
Where continent is not NULL
Group by location
order by TotalDeathCount desc

--Let's break things down by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From COVID19..CovidDeaths$
--Where location like '%Col%'
Where continent is not NULL
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest deatch counts
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From COVID19..CovidDeaths$
--Where location like '%Col%'
Where continent is not NULL
Group by continent
order by TotalDeathCount desc

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From COVID19..CovidDeaths$
--Where location like '%Col%'
Where continent is not null
--Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--Use CTE

With PopvsVac (coninent, lacation, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *
From PopvsVac

-- Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Select *
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

Select *
From PercentPopulationVaccinated