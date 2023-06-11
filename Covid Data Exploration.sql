--------------------------------------------------------
					--DATA EXPLORATION--
--------------------------------------------------------


select * from ProjectPortfolio..CovidDeaths
order by 3, 4

select * from ProjectPortfolio.. CovidVaccinations
order by 3, 4

--Selection of Total Cases

select location, date, total_cases, new_cases, total_deaths, population 
from ProjectPortfolio..CovidDeaths
order by 1, 2

--Death Percentage in India

select location, date, total_cases, population, total_deaths, (total_deaths/total_cases) * 100 DeathPercentage
from ProjectPortfolio..CovidDeaths
where location = 'India'
order by 1, 2

--Infection Percentage based on Location

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as InfectedPercentage
from ProjectPortfolio..CovidDeaths
group by location, population
order by InfectedPercentage desc

--Death Count and Death Percentage (Country wise)

select location, Max(population) as TotalPopulation, Max(cast(total_deaths as int)) as TotalDeathCount, Max(total_deaths/population) *100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Ordering based on Highest to Lowest Death Count

select continent, Max(population) as TotalPopulation, Max(cast(total_deaths as int)) as TotalDeathCount, Max(total_deaths/population) *100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where continent is not null
group by continent
order by 3 desc

--Sum of Total Cases, Total New deaths and Total Death Percentage

select sum(cast(new_cases as int)) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100) as TotalDP
from ProjectPortfolio..CovidDeaths
where continent is not null

--Joining of CovidDeaths and CovidVaccination Data 

select dea.continent, dea.location, dea.date, dea.population, (cast(vac.new_vaccinations as int))
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null
order by 5

--Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,
dea.Date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--Using Common Table Expression(CTE) to perdform Caculation on Partition By in Previous Query

with PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,
dea.Date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)

Select*, (RollingPeopleVaccinated/Population)*100 VacPer 
from PopVsVac

-- Creating View to store data for later visualizations

create view PercentPopulatedVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,
dea.Date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulatedVaccinated
