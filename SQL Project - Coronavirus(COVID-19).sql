*/ Covid 19 Data Exploration 
Source Our World in Data: Coronavirus(COVID-19) Deaths
link data = https://ourworldindata.org/covid-deaths


--- Covid Deaths 
Select * 
From CovidPortofolioProject..Deaths

-- Select Data

Select Location, date, new_cases, total_cases, total_deaths, population
From CovidPortofolioProject..Deaths
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortofolioProject..Deaths
where continent is not null
order by 1,2

-- Shows Likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortofolioProject..Deaths
Where location like '%Indonesia%'
and continent is not null
order by 1,2

-- Total Cases vs Population 

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidPortofolioProject..Deaths
where continent is not null
order by 1,2

-- Shows what percentage of population infected with Covid 

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidPortofolioProject..Deaths
Where location like '%Indonesia%'
and continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfection, 
MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidPortofolioProject..Deaths
Where continent is not null
Group by location, population
order by PercentPopulationInfected DESC

-- Countries with Highest Death Count per population 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidPortofolioProject..Deaths
where continent is not null 
Group by location 
order by TotalDeathCount DESC

-- Continent with Highest Death Count per population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From CovidPortofolioProject..Deaths
where continent is not null 
Group by continent
order by TotalDeathCount DESC

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From CovidPortofolioProject..Deaths
Where continent is not null
order by 1,2


--- Covid Vaccinations 


Select * 
From CovidPortofolioProject..Vaksin

-- Combine 2 table 

Select *
From CovidPortofolioProject..Deaths as dea
Join CovidPortofolioProject..Vaksin as vac
	On dea.location = vac.location 
	and dea.date = vac.date 

-- total population vs vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidPortofolioProject..Deaths as dea
Join CovidPortofolioProject..Vaksin as vac
	On dea.location = vac.location 
	and dea.date = vac.date 
	Where dea.continent is not null
order by 2,3

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortofolioProject..Deaths dea
Join CovidPortofolioProject..Vaksin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  
order by 2,3

-- USE CTE (Common Table Expresion)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortofolioProject..Deaths dea
Join CovidPortofolioProject..Vaksin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

----- Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortofolioProject..Deaths dea
Join CovidPortofolioProject..Vaksin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

-- View Table PercentPopulationVaccinated
Select * 
From PercentPopulationVaccinated2
