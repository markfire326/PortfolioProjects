/*
Queries used for Tableau Viz for COVID Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From `deductive-eye-345712.COVID19_Project.covid_deaths`
--Where location = 'Nigeria'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
--From`deductive-eye-345712.COVID19_Project.covid_deaths`
--Where location = 'Nigeria'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(new_deaths) as TotalDeathCount
From `deductive-eye-345712.COVID19_Project.covid_deaths`
--Where location = 'Nigeria'
Where continent is null 
and location not in ('World', 'European Union', 'International','Upper middle income','High income','Lower middle income','Low income' )
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From `deductive-eye-345712.COVID19_Project.covid_deaths`
--Where location = 'Nigeria'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From `deductive-eye-345712.COVID19_Project.covid_deaths`
--Where location = 'Nigeria'
Group by Location, Population, date
order by PercentPopulationInfected desc