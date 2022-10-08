select * from covidDeaths$
order by 3,4
select * from CovidVaccinations$
order by 3,4

--select Data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population from COVID..CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths
select location,date,total_cases,total_deaths,population,(total_deaths/total_cases)*100 death_percentage
from COVID..CovidDeaths$
where location like 'India'
order by 6 desc

--Looking at total cases vs population
select location,date,total_cases,population,(total_cases/population)*100 cases_percentage
from CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate vs population
select location,population,max(total_cases) highest_infection_count,max(total_cases/population)*100 max_cases_percentage
from CovidDeaths$
group by location,population
order by max_cases_percentage desc

--Countries with highest death count per population
select location,max(cast(total_deaths as int)) total_death_count
from CovidDeaths$
where continent is not null
group by location
order by total_death_count desc

--Let"s break things down by continent
select location,max(cast(total_deaths as int)) total_death_count
from CovidDeaths$
where continent is null
group by location
order by total_death_count desc

--continent with highest death count per population
select continent,max(cast(total_deaths as int)) total_death_count,max(cast(total_deaths as int)/population) total_death_per_population
from CovidDeaths$
where continent is not null
group by continent
order by total_death_count desc



--GLOBAL NUMBERS
select date,sum(new_cases) total_cases,sum(cast(new_deaths as int)) total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 death_percentage 
from COVID..CovidDeaths$
--where location like 'India' and 
where continent is not null
group by date
order by 1,2 desc

--total new cases and total new death and the death percentage
select sum(new_cases) total_cases,sum(cast(new_deaths as int)) total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 death_percentage 
from COVID..CovidDeaths$
--where location like 'India' and 
where continent is not null



--looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) rolling_people_vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with popvsvac (continent,location,date,population,new_vaccinations, rolling_people_vaccinated) as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) rolling_people_vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null)
select *, (rolling_people_vaccinated/population)*100
from popvsvac


--TEMP TABLE

drop table if exists percentpopulationvaccinated
CREATE TABLE percentpopulationvaccinated
(continent nvarchar(255),location nvarchar(255),date datetime,population numeric,new_vaccinations numeric,rolling_people_vaccinated numeric)
insert into percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) rolling_people_vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *,(rolling_people_vaccinated/population)*100 
from percentpopulationvaccinated

--creating view to store data for later visualizations

create view percent_population_vaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) rolling_people_vaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from percent_population_vaccinated


