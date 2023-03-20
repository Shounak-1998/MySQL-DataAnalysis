SELECT * FROM SQLDataExploration..CovidDeaths ORDER BY 3,4

--SELECT * FROM SQLDataExploration..CovidVaccinations ORDER BY 3,4

-- SELECT DATA THAT ARE WE ARE GOING TO USING

SELECT Location, date, total_cases, new_cases, total_deaths, population FROM SQLDataExploration..CovidDeaths ORDER BY 1,2

--Looking for the Total cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 population FROM SQLDataExploration..CovidDeaths Where location like '%India%' ORDER BY 1,2


-- Looking at Total cases vs Population
-- Shows What percentage of poluation got covid

SELECT Location, date, total_cases, total_deaths, population, (total_cases/population)*100 FROM SQLDataExploration..CovidDeaths Where location like '%India%' ORDER BY 1,2


--Highest Infection Rate looking at country compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PersonPopulatedInfected FROM SQLDataExploration..CovidDeaths 
--Where location like '%State%' 
GROUP BY Location, population ORDER BY PersonPopulatedInfected desc

--Showing Countries with Highest death count per Population

SELECT Location, MAX(cast(total_deaths as int)) as HighestDeathRate FROM SQLDataExploration..CovidDeaths 
--Where location like '%State%' 
GROUP BY Location ORDER BY HighestDeathRate desc


-- Where continent is not NULL

SELECT * FROM SQLDataExploration..CovidDeaths WHERE continent is not null ORDER BY 3,4

--Lets Break Thinks down by Continent

SELECT continent, MAX(cast(total_deaths as int)) as TotaldeathCount FROM SQLDataExploration..CovidDeaths 
--Where location like '%State%' 
WHERE continent is not null
GROUP BY continent ORDER BY TotaldeathCount desc

--North America need to seperate with Europe

SELECT location, MAX(cast(total_deaths as int)) as TotaldeathCount FROM SQLDataExploration..CovidDeaths 
--Where location like '%State%' 
WHERE continent is null
GROUP BY location ORDER BY TotaldeathCount desc

-- Showing Continent Showing Highest Death count

SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathRate FROM SQLDataExploration..CovidDeaths 
--Where location like '%State%' 
WHERE continent is not null
GROUP BY continent ORDER BY HighestDeathRate desc

-- Global Number

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
-- total_cases, total_deaths, (total_deaths/total_cases)*100 population 
FROM SQLDataExploration..CovidDeaths
Where continent is not null
--Group by date
ORDER BY 1,2

Select *
from SQLDataExploration..CovidVaccinations

--Join two table with (location and date)

select *
from SQLDataExploration..CovidDeaths dea
JOIN SQLDataExploration..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from SQLDataExploration..CovidDeaths dea
JOIN SQLDataExploration..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent  is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location)
from SQLDataExploration..CovidDeaths dea
JOIN SQLDataExploration..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent  is not null
order by 2,3

--Order by location and dat

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location)
from SQLDataExploration..CovidDeaths dea
JOIN SQLDataExploration..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent  is not null
order by 2,3

--Looking Rooling People Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location,dea.date) 
as RoolingPeopleVaccinated
from SQLDataExploration..CovidDeaths dea
JOIN SQLDataExploration..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent  is not null
order by 2,3


--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RoolingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location,dea.date) 
as RoolingPeopleVaccinated
from SQLDataExploration..CovidDeaths dea
JOIN SQLDataExploration..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent  is not null
--order by 2,3
)
Select *, (RoolingPeopleVaccinated/population)*100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLDataExploration..CovidDeaths dea
Join SQLDataExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLDataExploration..CovidDeaths dea
Join SQLDataExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null







