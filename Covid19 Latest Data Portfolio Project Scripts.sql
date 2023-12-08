-- Counts the number of rows in the covidvaccinations table grouped by continent.
select continent, count(*) as row_count
from portfolioproject.covidvaccinations c 
group by continent;

-- Counts the number of rows in the coviddeaths table grouped by continent.
select continent, count(*) as row_count
from portfolioproject.coviddeaths
group by continent;

-- Retrieves all columns from the coviddeaths table and orders the result by the third and fourth columns.
select *
from portfolioproject.coviddeaths c
order by 3,4

-- Retrieves rows from the coviddeaths table where the continent columns is not null statement in it and orders the result by the third and fourth columns.
select *
from portfolioproject.coviddeaths c
where continent is not null
order by 3,4

-- Retrieves all columns from the covidvaccinations table and orders the result by the third and fourth columns.
select *
from portfolioproject.covidvaccinations c
order by 3,4

-- Select Data that we are going to be using
-- Retrieves specific columns from the coviddeaths table and orders the result by the third and fourth columns.
select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject.coviddeaths c
order by 3,4

-- Retrieves specific columns from the coviddeaths table and orders the result by the first and second columns.
select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject.coviddeaths c
order by 1,2

-- Looking Total Cases vs Total Deaths
-- Calculates the death percentage and retrieves specific columns from the coviddeaths table, ordering the result by the first and second columns.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from portfolioproject.coviddeaths c
order by 1,2

-- Retrieves specific columns for Malaysia from the coviddeaths table, calculates death percentage, and orders the result by date in descending order.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from portfolioproject.coviddeaths c
where location like '%Malaysia%'
order by date desc

-- Looking at Total Cases vs Population
-- Calculates the positive population percentage for Malaysia, retrieving specific columns from the coviddeaths table and ordering the result by total cases in ascending order.
select location, date, total_cases, population, (total_cases/population)*100 as Positive_Population_Percentage
from portfolioproject.coviddeaths c
where location like '%Malaysia%'
order by total_cases asc

-- Calculates the positive population percentage for the world, retrieving specific columns from the coviddeaths table and ordering the result by total cases in ascending order.
select continent, location, date, total_cases, population, (total_cases/population)*100 as Positive_Population_Percentage
from portfolioproject.coviddeaths c
where location like '%World%'
order by total_cases asc

-- Looking at Country with Highest Infection Rate to Population
-- Calculates the highest infection and positive population percentage, grouping the result by location and population.
select location, population, max(total_cases) as Highest_Infection, max((total_cases/population))*100 as Positive_Population_Percentage
from portfolioproject.coviddeaths c
group by location, population
order by Positive_Population_Percentage desc

-- Showing Countries with Highest Death count per Population
-- Finds the location with the highest total death count, grouping the result by location.
select location, max(total_deaths) as Total_Death_Count
from portfolioproject.coviddeaths c
group by location
order by Total_Death_Count desc

-- Excludes grouping continent like 'World', 'European', 'Asia', etc using trim formula
-- Finds the location with the highest total death count, excluding rows where the continent is null or empty, and grouping the result by location.
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
-- Finds the continent with the highest total death count, excluding rows where the continent is null or empty, and grouping the result by continent.
select continent, max(total_deaths) as Total_Death_Count
from portfolioproject.coviddeaths c
where trim(continent) <> ''
group by continent
order by Total_Death_Count desc

-- Breaking down to Global Numbers
-- Calculates total cases, total deaths, and death percentage for non-null continents.
select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, sum(new_deaths)/sum(new_cases)*100 as Death_Percentage
from portfolioproject.coviddeaths c
where trim(continent) <> ''
order by 1,2

-- Looking total population vs vaccinations
-- Calculates the running total of people vaccinated, retrieving specific columns from the coviddeaths and covidvaccinations tables, and ordering the result by location and date.
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as People_Vaccinated
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where trim(dea.continent) <> ''
order by 2,3

-- Let's use temporary named, CTE (Common Table Expression)
-- Uses a Common Table Expression (CTE) to calculate the running total of people vaccinated and retrieve specific columns from the coviddeaths and covidvaccinations tables, including the percentage calculation.
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
-- Creates a temporary table named PopulationVaccinatedPercentage with specified columns.
create temporary table PopulationVaccinatedPercentage (
continent varchar(50),
location varchar(50),
date varchar(50),
population double,
new_vaccinations double,
people_vaccinated double)

-- Inserts data into the PopulationVaccinatedPercentage temporary table.
insert into PopulationVaccinatedPercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as people_vaccinated
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where trim(dea.continent) <> ''

-- Retrieves data from the PopulationVaccinatedPercentage temporary table and calculates the population vaccination percentage.
select *, (people_vaccinated/population)*100 as population_vaccinated
from PopulationVaccinatedPercentage

-- Drops the temporary table named PopulationVaccinatedPercentage if it exists.
drop table if exists PopulationVaccinatedPercentage

-- Creates a view named PopulationVaccinatedPercentage with a similar calculation as the temporary table to store data for later visualizations
create view PopulationVaccinatedPercentage as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as People_Vaccinated
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where trim(dea.continent) <> ''

-- Retrieves data from the PopulationVaccinatedPercentage view.
select *
from populationvaccinatedpercentage p
