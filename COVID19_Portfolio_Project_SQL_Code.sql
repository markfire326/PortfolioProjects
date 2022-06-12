--SELECT  *
-- FROM `deductive-eye-345712.COVID19_Project.covid_deaths` 
--WHERE continent is not NULL
-- ORDER BY 3,4;

-- SELECT *
-- FROM `deductive-eye-345712.COVID19_Project.covid_vaccinations`
--WHERE continent is not NULL
-- ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO USE

SELECT Location, date,total_cases,new_cases,total_deaths,population
FROM `deductive-eye-345712.COVID19_Project.covid_deaths`
WHERE continent is not NULL
ORDER BY 1,2

--Looking at Total cases vs Total deaths daily, to find the death percentage
--Shows the likelihood of dying if you contract covid in your country

SELECT location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM `deductive-eye-345712.COVID19_Project.covid_deaths`
WHERE continent is not NULL
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of the population has got covid

SELECT location,date,population,total_cases, (total_cases/population)*100 AS ContractingPercentage
FROM `deductive-eye-345712.COVID19_Project.covid_deaths`
WHERE continent is not NULL
ORDER BY 1,2

--Looking for countries with highest infection rate compared to population

SELECT location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentInfectedPopulation
FROM `deductive-eye-345712.COVID19_Project.covid_deaths`
WHERE continent is not NULL
GROUP BY location, population
ORDER BY 4 desc

--Showing countries with highest death count per population (mortality rate)

SELECT location,population,MAX(total_deaths) as TotalDeathCount, MAX((total_deaths/population))*100 AS PercentInfectedPopulation
FROM `deductive-eye-345712.COVID19_Project.covid_deaths`
WHERE continent is not NULL
GROUP BY location, population
ORDER BY 3 desc

--LET'S BREAK IT DOWN BY CONTINENT

--Showing continents with highest death count per population

SELECT continent,MAX(total_deaths) as TotalDeathCount
FROM `deductive-eye-345712.COVID19_Project.covid_deaths`
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global numbers daily

--Number of new cases globally daily

SELECT date,sum(new_cases) as sum_new_cases --total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM `deductive-eye-345712.COVID19_Project.covid_deaths`
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

--Number of new deaths daily and global death percentage

SELECT date,sum(new_cases) as total_cases, sum(new_deaths) as total_Deaths,(sum(new_Deaths)/sum(new_cases))*100 AS GlobalDeathPercentage
FROM `deductive-eye-345712.COVID19_Project.covid_deaths`
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,globaldeathpercentage


--COVID VACCINATIONS TABLE

SELECT *
FROM `deductive-eye-345712.COVID19_Project.covid_vaccinations`
ORDER BY 1,2

--Join Vaccinations table on death table

SELECT *
FROM `deductive-eye-345712.COVID19_Project.covid_vaccinations` as v
INNER JOIN `deductive-eye-345712.COVID19_Project.covid_deaths` as d
ON v.location = d.location
  AND v.date = d.date
ORDER BY 1,2

--Looking at total population vs vaccination

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM `deductive-eye-345712.COVID19_Project.covid_vaccinations` as v
INNER JOIN `deductive-eye-345712.COVID19_Project.covid_deaths` as d
ON v.location = d.location
  AND v.date = d.date
WHERE d.continent is not NULL  
ORDER BY 1,2,3

--Analytical look into total population vs new vaccs using PARTITION BY

SELECT d.continent,d.location, d.date, d.population,v.new_vaccinations,
       sum(v.new_vaccinations) 
          OVER (
                PARTITION BY d.location
                  ORDER BY d.location, d.date) AS DailyVaccinationNumber,
                    --(DailyVaccinationNumber/d.population)*100
FROM `deductive-eye-345712.COVID19_Project.covid_vaccinations` as v
INNER JOIN `deductive-eye-345712.COVID19_Project.covid_deaths` as d
ON v.location = d.location
  AND v.date = d.date
WHERE d.continent is not NULL  
ORDER BY 2,3

--To get percentage DailyVaccination count per population
--Using CTE titled PopVsVac (i.e Population vs Vaccination)

WITH 
PopVsVac AS --(Continent, Location, Date, Population, New_Vaccinations, DailyVaccinationNumber) AS
(
SELECT d.continent,d.location, d.date, d.population,v.new_vaccinations,
       sum(v.new_vaccinations) 
          OVER (
                PARTITION BY d.location
                  ORDER BY d.location, d.date) AS DailyVaccinationNumber
                    --(DailyVaccinationNumber/d.population)*100
FROM `deductive-eye-345712.COVID19_Project.covid_vaccinations` as v
INNER JOIN `deductive-eye-345712.COVID19_Project.covid_deaths` as d
ON v.location = d.location
  AND v.date = d.date
WHERE d.continent is not NULL  
--ORDER BY 2,3
)

SELECT *,(DailyVaccinationNumber/population)*100 as PopVaccinatedPercent
FROM PopVsVac


--TEMP TABLE

--DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
  Continent nvarchar(255),
  Location nvarchar (255),
  Date datetime,
  Population numeric,
  New_Vaccinations numeric,
  DailyVaccinationsNumber numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT d.continent,d.location, d.date, d.population,v.new_vaccinations,
       sum(v.new_vaccinations) 
          OVER (
                PARTITION BY d.location
                  ORDER BY d.location, d.date) AS DailyVaccinationNumber,
                    --(DailyVaccinationNumber/d.population)*100
FROM `deductive-eye-345712.COVID19_Project.covid_vaccinations` as v
INNER JOIN `deductive-eye-345712.COVID19_Project.covid_deaths` as d
ON v.location = d.location
  AND v.date = d.date
WHERE d.continent is not NULL  
ORDER BY 2,3

SELECT *,(DailyVaccinationNumber/population)*100 as PopVaccinatedPercent
FROM #PercentPopulationVaccinated