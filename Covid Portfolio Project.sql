select * from dbo.CovidDeaths 
order by 3, 4

select * from dbo.CovidVaccinations
order by 3, 4

--To alter datatype, but use cast
alter table dbo.CovidDeath
alter column new_cases float

select location, date, total_cases, new_cases, total_deaths, population 
from dbo.CovidDeaths 
order by 1, 2

--Total cases vs Total deaths
-- shows likelihood of dying if you contract covid in United states-- can change the country if you want

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths 
where location like '%states%'
order by 1, 2

--Looking at total cases vs population
--shows what percentage of population got covid 
select location, date, total_cases, population, (total_cases/NULLIF (population, 0))*100 as DeathPercentage
from dbo.CovidDeaths 
--where location like '%states%'
order by 1, 2

--looking at countries with highest infection rate compared to population 
select location, population , Max(cast(total_cases as int)) as HighestInfectioncount, Max(total_cases/NULLIF (population, 0))*100
as PercentPopulationInfected
from dbo.CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--showing countires with highest death count per population
select location, Max(cast(total_Deaths as int)) as TotalDeathCount 
from dbo.CovidDeaths where continent is not null
group by location
order by TotalDeathcount desc

--Breaking it down by continent- using '' since the data has blank space isntead of null. 

select continent, Max(cast(total_Deaths as int)) as TotalDeathCount 
from dbo.CovidDeaths 
where continent is not null
group by continent 
order by TotalDeathcount desc

-- showing continents with the highest death count per population 

select location, Max(cast(total_Deaths as int)) as TotalDeathCount 
from dbo.CovidDeaths 
where  continent is  null
group by location
order by TotalDeathcount desc

--Global Numbers
select  SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(New_deaths as int))/SUM((Nullif(New_cases ,0))) *100 as Deathpercentage
from dbo.CovidDeaths 
where continent is not null
--group by date
order by 1, 2 


--joining two table
--looking at total population vs vaccinations
select dea.continent,dea.location, dea.date, dea.population, vacc.new_vaccinations,
Sum(cast(vacc.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths Dea
Join dbo.CovidVaccinations Vacc
	on dea.location = Vacc.location
	and dea.date = Vacc.date
where dea.continent is not null
order by 2,3

--using cte

With PopulationVSVaccination (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent,dea.location, dea.date, dea.population, vacc.new_vaccinations,
Sum(cast(vacc.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths Dea
Join dbo.CovidVaccinations Vacc
	on dea.location = Vacc.location
	and dea.date = Vacc.date
where dea.continent is not null )

Select *, (RollingPeopleVaccinated/Population)*100
from PopulationVSVaccination



--creating view to store data for visulation 

Create View PopulationVSVaccination as 
select dea.continent,dea.location, dea.date, dea.population, vacc.new_vaccinations,
Sum(cast(vacc.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths Dea
Join dbo.CovidVaccinations Vacc
	on dea.location = Vacc.location
	and dea.date = Vacc.date
where dea.continent is not null 
