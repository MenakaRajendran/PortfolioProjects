select *
from PortfolioProject.dbo.CovidDeaths
order by 3,4

select *
from PortfolioProject.dbo.CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states'
order by 1,2

select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states'
order by 1,2


select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CasePercentage
from PortfolioProject.dbo.CovidDeaths
Group by Location, population
order by CasePercentage desc

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
Group by Location, population
order by TotalDeathCount desc




--select * 
--from PortfolioProject.dbo.CovidDeaths
--where continent is not NULL
--Order by 3,4

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not NULL
Group by continent
order by TotalDeathCount desc

--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not NULL
--Group by date
order by 1,2 

--select * from PortfolioProject.dbo.CovidDeaths

select * 
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 2,3

--USE CTE

with PopvsVac (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



----TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not NULL
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3

select * from PercentPopulationVaccinated