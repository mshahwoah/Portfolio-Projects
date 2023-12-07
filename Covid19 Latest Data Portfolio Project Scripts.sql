select continent, count(*) as row_count
from portfolioproject.covidvaccinations c 
group by continent;

select continent, count(*) as row_count
from portfolioproject.coviddeaths
group by continent;

select *
from portfolioproject.coviddeaths c
order by 3,4

-- Below is the query to exclude null rows in continent column if null statement in it.

select *
from portfolioproject.coviddeaths c
where continent is not null
order by 3,4

select *
from portfolioproject.covidvaccinations c
order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject.coviddeaths c
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject.coviddeaths c
order by 1,2

-- Looking Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from portfolioproject.coviddeaths c
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from portfolioproject.coviddeaths c
where location like '%Malaysia%'
order by date desc

-- Looking at Total Cases vs Population
-- Shows percentage of Population
select location, date, total_cases, population, (total_cases/population)*100 as Positive_Population_Percentage
from portfolioproject.coviddeaths c
where location like '%Malaysia%'
order by total_cases asc

select continent, location, date, total_cases, population, (total_cases/population)*100 as Positive_Population_Percentage
from portfolioproject.coviddeaths c
where location like '%World%'
order by total_cases asc

-- Looking at Country with Highest Infection Rate to Population
select location, population, max(total_cases) as Highest_Infection, max((total_cases/population))*100 as Positive_Population_Percentage
from portfolioproject.coviddeaths c
group by location, population
order by Positive_Population_Percentage desc

-- Showing Countries with Highest Death count per Population
select location, max(total_deaths) as Total_Death_Count
from portfolioproject.coviddeaths c
group by location
order by Total_Death_Count desc

-- Excludes grouping continent like 'World', 'European', 'Asia', etc using trim formula

select location, max(total_deaths) as Total_Death_Count
from portfolioproject.coviddeaths c
where trim(continent) <> ''
group by location
order by Total_Death_Count desc


-- 'cast' is using to convert the data type. For e.g.: varchar to int
#select location, max(cast(total_deaths as int)) as Total_Death_Count
#from portfolioproject.coviddeaths c
#where trim(continent) <> ''
#group by location
#order by Total_Death_Count desc

-- Breakdown by continent
-- Showing continents with the highest death count per population
select continent, max(total_deaths) as Total_Death_Count
from portfolioproject.coviddeaths c
where trim(continent) <> ''
group by continent
order by Total_Death_Count desc

-- Breaking down to Global Numbers
select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, sum(new_deaths)/sum(new_cases)*100 as Death_Percentage
from portfolioproject.coviddeaths c
where trim(continent) <> ''
order by 1,2

-- Looking total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as People_Vaccinated
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where trim(dea.continent) <> ''
order by 2,3

-- Let's use temporary named, CTE (Common Table Expression)
with PopvsVac (continent, location, date, population, new_vaccinations, People_Vaccinated) as (

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as People_Vaccinated
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where trim(dea.continent) <> ''
)
select *, (People_Vaccinated/Population)*100
from PopvsVac

-- Let's use temp table
-- Create a global temporary table
create temporary table PopulationVaccinatedPercentage (
continent varchar(50),
location varchar(50),
date varchar(50),
population double,
new_vaccinations double,
people_vaccinated double)

-- Insert data into the global temporary table
insert into PopulationVaccinatedPercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as people_vaccinated
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where trim(dea.continent) <> ''

-- Query from the global temporary table
select *, (people_vaccinated/population)*100 as population_vaccinated
from PopulationVaccinatedPercentage

-- Drop the global temporary table
drop table if exists PopulationVaccinatedPercentage

-- Create View to store data for later visualizations
create view PopulationVaccinatedPercentage as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as People_Vaccinated
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where trim(dea.continent) <> ''

select *
from populationvaccinatedpercentage p
