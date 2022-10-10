/*
Covid 19 Data Exploration 
Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
Use Covid_Database

Select *
From [dbo].[Covid Death]
Where continent is not null

Select *
From [dbo].[Covid Vacination]
Where continent is not null


Select Location, date, total_cases, new_cases, total_deaths, population
From Covid_Database..[Covid Death] 
Where continent is not null 


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [dbo].[Covid Death]
Where location = 'Pakistan'
and continent is not null


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [dbo].[Covid Death]


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [dbo].[Covid Death]
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [dbo].[Covid Death]
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [dbo].[Covid Death]
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Global Number

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [dbo].[Covid Death]
where continent is not null 
--Group By date


--Looking at total populationn vs Vacinated population
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [dbo].[Covid Death] dea
Join [dbo].[Covid Vacination] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].[Covid Death] dea
Join [dbo].[Covid Vacination] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query
--TEMP Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


--Creating view to store data for visualization
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].[Covid Death] dea
Join [dbo].[Covid Vacination] vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 


Select * from PercentPopulationVaccinated