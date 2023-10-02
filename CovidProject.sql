Select * 
From CovidPortofolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select * 
From CovidPortofolioProject..CovidVaccinations
order by 3,4

---COVID DEATHS
--Select data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidPortofolioProject..CovidDeaths
order by 1,2

---- looking at Total Cases vs Total Deaths 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortofolioProject..CovidDeaths
order by 1,2

-- looking at Total Cases vs Total Deaths United States 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortofolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- looking at Total Cases vs Total Deaths Indonesia
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortofolioProject..CovidDeaths
Where location like '%indo%'
order by 1,2

---- Looking at Total Cases vs Population 
-- Shows that percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From CovidPortofolioProject..CovidDeaths
order by 1,2

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From CovidPortofolioProject..CovidDeaths
---Where location like '%states%'
order by 1,2

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From CovidPortofolioProject..CovidDeaths
Where continent is not null
Where location like '%indonesia%'
order by 1,2

--Looking at countries with highest infection rate compared to population 

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From CovidPortofolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by PercentagePopulationInfected desc


-- Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortofolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT (BENUA)
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortofolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers per hari
Select date,  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From CovidPortofolioProject..CovidDeaths
Where continent is not null
group by date 
order by 1,2

-- TOTAL SEMUA
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From CovidPortofolioProject..CovidDeaths
Where continent is not null
--group by date 
order by 1,2

---- COVID VACCINATIONS

Select * 
From CovidPortofolioProject..CovidVaccinations

-- menggabungkan 2 table 
Select *
From CovidPortofolioProject..CovidDeaths as dea
Join CovidPortofolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date 

-- total population vs vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidPortofolioProject..CovidDeaths as dea
Join CovidPortofolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date 
	Where dea.continent is not null
order by 2,3

-- total population vs vaccinations 
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortofolioProject..CovidDeaths dea
Join CovidPortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  
order by 2,3

-- USE CTE (common table expresion)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortofolioProject..CovidDeaths dea
Join CovidPortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table 
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
From CovidPortofolioProject..CovidDeaths dea
Join CovidPortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


----- Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortofolioProject..CovidDeaths dea
Join CovidPortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

-- Melihat Table PercentPopulationVaccinated
Select * 
From PercentPopulationVaccinated