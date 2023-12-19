use portfolio_proj;
select * from coviddeaths limit 3000;
select count(*) from covidvaccinations;

select location,date,total_cases,new_cases,total_deaths,population
from coviddeaths order by 1,2 ;

-- total cases vs total deaths
-- likelihood of dying if a person contracts covid in that country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from coviddeaths where location='Africa' order by 1,2;

-- total cases vs total population
-- shows what percentage of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as percentpopulationinfected
from coviddeaths order by 1,2;

-- countries with highest infection rate
select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as percentpopulationinfected
from coviddeaths group by location,population order by 1,2;

-- countries with highest death count per population
select location,max(cast(total_deaths as unsigned)) as TotalDeathCount
from coviddeaths group by location order by TotalDeathCount desc;

-- global numbers (Covid cases per day worldwide)
select date,sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,(sum(new_deaths)/sum(new_cases)) * 100 as DeathPercentage
from  covidDeaths group by date;

-- total population vs vaccination
with PopvsVac(continent,location,date,population,new_vaccination,rollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on vac.date=dea.date
and vac.location=dea.location
where dea.continent is not null)
select *,(rollingPeopleVaccinated/population) as PercentPopulationVaccinated from PopvsVac;

-- temp table creation
drop table if exists PercentPopulationVaccinated;
create temporary table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccination nvarchar(255),
rollingPeopleVaccinated numeric
);

insert into PercentPopulationVaccinated(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on vac.date=dea.date
and vac.location=dea.location
where dea.continent is not null
);
select * , (rollingPeopleVaccinated/population)*100 as percpopulationvaccinated from PercentPopulationVaccinated;

-- view table creation for storing data which can be used for visualizations
create view PopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on vac.date=dea.date
and vac.location=dea.location
where dea.continent is not null;
select * from PopulationVaccinated;

drop view if exists totalCovidCasesGlobally;
create view totalCovidCasesGlobally as
select location,sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,(sum(new_deaths)/sum(new_cases)) * 100 as DeathPercentage
from  covidDeaths group by location;
select * from totalCovidCasesGlobally;
