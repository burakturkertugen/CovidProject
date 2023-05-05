Select * from PotfolioProjectCovid..CovidDeaths



--Shows Total Cases / Population
Select location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected From PotfolioProjectCovid..CovidDeaths
where continent is not null
order by 1,2


--Shows Highest Infection Rate / Population
Select location, MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population)*100) as PercentPopulationInfected From PotfolioProjectCovid..CovidDeaths
where continent is not null
GROUP BY location, population
order by 4 DESC


--Shows Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PotfolioProjectCovid..CovidDeaths
where continent is not null
GROUP BY location
order by TotalDeathCount DESC

--Showing Total Deaths by CONTINENT
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PotfolioProjectCovid..CovidDeaths
where continent is not null
GROUP BY continent
order by TotalDeathCount DESC


--GLOBAL NUMBERS

Select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PotfolioProjectCovid..CovidDeaths
where continent is not null
--group by date
order by 1,2



--JOINING THE TWO TABLES -- COVIDDEATHS -- COVIDVACCINATION

--Total population and vaccination
--CTE Statement

With PopvsVac (continent, location, date, population,new_vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,	dea.date)
as PeopleVaccinated
from PotfolioProjectCovid..CovidDeaths dea
Inner join	PotfolioProjectCovid..CovidVaccinations$ vac
on dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

)
Select *, (PeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
from PopvsVac




--TEMP TABLE

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,	dea.date)
as PeopleVaccinated
from PotfolioProjectCovid..CovidDeaths dea
Inner join	PotfolioProjectCovid..CovidVaccinations$ vac
on dea.location = vac.location
AND dea.date = vac.date
--where dea.continent is not null
--order by 2,3


Select *, (PeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
from #percentpopulationvaccinated

--creating view to store data for later visualization


CREATE VIEW percentpopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,	dea.date)
as PeopleVaccinated
from PotfolioProjectCovid..CovidDeaths dea
Inner join	PotfolioProjectCovid..CovidVaccinations$ vac
on dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated