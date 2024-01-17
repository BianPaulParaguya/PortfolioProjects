Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Location, date, total_cases, new_cases,total_deaths, population
--From PortfolioProject..CovidDeaths 
--order by 1,2

--cast converts nvarchar to float or any other type of variable

-- looking at total cases vs total deaths 
-- shows likelihoof that someones dies if they get covid in united states
Select Location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float))*100 AS death_to_case_Ratio
From PortfolioProject..CovidDeaths  
Where location like '%states%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
Select Location, date, total_cases, population, (CAST(total_cases AS float)/population)*100 as Percentage_Of_Infected
From PortfolioProject..CovidDeaths  
Where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population
Select Location, date, MAX(CAST(total_cases AS float)) AS HighestInfectionCount, population, (MAX(CAST(total_cases AS float))/population)*100 AS Percentage_Of_Infected
From PortfolioProject..CovidDeaths  
--Where location like '%states%'
GROUP BY 
    Location, date, population
order by Percentage_Of_Infected Desc

-- showing countries with highest death count per population
Select Location, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
From PortfolioProject..CovidDeaths  
--Where location like '%states%'
where continent is not null
GROUP BY location
order by TotalDeathCount Desc

-- geolocation grouping
Select location, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
From PortfolioProject..CovidDeaths  
--Where location like '%states%'
where continent is null
GROUP BY location
order by TotalDeathCount Desc


-- showing continents with highest death count per population
Select continent, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
From PortfolioProject..CovidDeaths  
--Where location like '%states%'
where continent is not null
GROUP BY continent
order by TotalDeathCount Desc

-- global numbers
Select date, SUM (new_cases)as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths, SUM(cast (new_deaths as int))/SUM
(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group By date
order by 1, 2

--looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) over (Partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


-- use CTE 
With PopVsVac  (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) over (Partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac

--temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) over (Partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualization

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) over (Partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
from PercentPopulationVaccinated