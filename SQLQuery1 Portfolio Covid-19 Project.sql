

/*

Covid-19 Data Exploration Portfoilio Project


Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


--Tables used for Data Exploration

Select *
From [Portfolio Project]..CovidDeaths
Where Continent is not null
Order By 3,4

Select *
From [Portfolio Project]..CovidVaccinations
Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 1,2


--Total Cases Vs Total Deaths

--Showcases the possible percentage of dying if you contract covid

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 1,2

--Showcases the possible percentage of dying in the United States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2



--Total Cases Vs Population


-- Percentage of Population that contracted Covid

Select Location, date, total_cases,(total_cases/population)*100 as Contracted_Covid
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 1,2

-- Percentage of Population in the United States that contracted Covid

Select Location, date, total_cases,(total_cases/population)*100 as Contracted_Covid
From [Portfolio Project]..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2


--Countries with the highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/population))*100 as 
Percent_Population_Infected
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group By Location, Population
Order By Percent_Population_Infected desc


--Countries with the highest infection rate compared to population by date

Select Location, Population, date, MAX(total_cases) as HigestInfectionCount, 
MAX((total_cases/population))*100 as 
Percent_Population_Infected
From [Portfolio Project]..CovidDeaths
--Where continent is not null
Group By Location, Population, date
Order By Percent_Population_Infected desc


--Countries with the highest death count per population

Select Location, Max(Cast(Total_deaths as int)) as Total_Death_Count
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group By Location
Order By Total_Death_Count desc


-- Percentage of Death by Countries

Select location,
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by location
Order By 2 DESC 



-- Viewing Covid-19 Data by Contients

-- Order of Contients by highest death count per population

Select continent, Max(Cast(Total_deaths as int)) as Total_Death_Count
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group By continent
Order By Total_Death_Count desc


-- Global Numbers for Death Pearcentage by Date

Select date, Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by date
Order By 1,2


-- Total Global Numbers for Death Percentage

Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order By 1,2



-- Joining tables CovidDeaths and CovidVaccinations based on location and date

Select *
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea. location = vac. location
and dea. date = vac. date



--Total Vaccinations by Country and Date

SELECT dea.location, dea.date, vac.total_vaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea. location = vac. location
and dea. date = vac. date
Where dea.continent is not null and vac.total_vaccinations is not null
Order by 1,2,3 desc



-- Total Population VS Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea. location = vac. location
and dea. date = vac. date
Where dea.continent is not null
Order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea. location = vac. location
and dea. date = vac. date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as TotalPercentagePeopleVaccinated
From PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location varchar(255), Date datetime, 
Population Numeric,
New_vaccinations Numeric,
RollingPeopleVaccinated Numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea. location = vac. location
and dea. date = vac. date

Select *, (RollingPeopleVaccinated/Population)*100
From  #PercentPopulationVaccinated



--Creating Views for data visulisations


--View One

--Rolling count of people vaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea. location = vac. location
and dea. date = vac. date
Where dea.continent is not null

--View Two

--Countries with the highest infection rate compared to population

Create View PercentofPopulationInfected as
Select Location, Population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/population))*100 as 
Percent_Population_Infected
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group By Location, Population
--Order By Percent_Population_Infected desc


--View Three

--The possibile percentage of dying if you contract covid

Create View DeathPossibilityPercentage as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
--Order by 1,2


--View Four

--Global Numbers by total death percentage

Create View GlobalDeathPercentage as
Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
--Order By 1,2


























