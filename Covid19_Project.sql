/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
USE CovidProject
GO

--Check data
SELECT *
FROM CovidDeaths;

SELECT *
FROM CovidVaccinations;

-- Start explore data with CovidDeaths table
-- Sort by location and date
SELECT continent, location, date, population
FROM CovidDeaths
ORDER BY 2,3;


-- Filter continent column IS NOT NULL
SELECT continent, location, date, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 2,3;

-- Looking for new_cases and new_deaths
SELECT continent, location, date, population, new_cases, new_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 2,3 DESC;


-- Looking for highest cases and deaths on location
SELECT location, MAX(total_cases) as TotalCases, MAX(total_deaths) as TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalCases DESC;

--Looking for percent of total_deaths/total_cases
SELECT continent, location, date, population, total_cases, total_deaths, ROUND(CONVERT(float,(total_deaths/total_cases)*100),2) as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND total_cases >= total_deaths
ORDER BY DeathPercentage DESC;

--Looking for Sum(new_cases) and Sum (new_Deaths) and DeathPercentage
SELECT SUM(new_cases) as Total_Cases_World, SUM(new_deaths) as Total_Deaths_World, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL

-- Looking for VietNam covid

SELECT continent, location, date, population, total_cases, total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL AND location = 'Vietnam'
ORDER BY total_cases DESC;


-- Start explore data with CovidVaccinations table
-- Sort by location and date
SELECT *
FROM CovidVaccinations
ORDER BY 3,4;

--Looking for new_test and new_vaccinations 
SELECT continent, location, date, new_tests, new_vaccinations
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3;

--Looking for total_tests and total_vaccinations 
SELECT continent, location, date, total_tests, total_vaccinations
FROM CovidVaccinations
WHERE continent IS NOT NULL	
ORDER BY 3;

--Looking for VaccinationPercentage
SELECT continent, location, date, total_tests, total_vaccinations, ROUND(CONVERT(float,(total_vaccinations/total_tests)*100),2) as VaccinationPercentage
FROM CovidVaccinations
WHERE continent IS NOT NULL	
ORDER BY VaccinationPercentage DESC;

--Looking for max tests and max vaccinations per location
SELECT location, MAX(total_tests) as TotalTests, MAX(total_vaccinations) as TotalVaccinations
FROM CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalTests DESC;

--Looking total_tests , total_vaccinations and vaccinationpercentage
 SELECT SUM(new_tests) as TotalTests , SUM(new_vaccinations) as TotalVaccinations, (SUM(new_vaccinations)/SUM(new_tests))*100 as VaccinationPercentage
 FROM CovidVaccinations
 WHERE continent IS NOT NULL;

 --JOIN CovidDeaths and CovidVaccinations table
 SELECT D.continent, D.location, D.date, D.population,D.total_cases,D.total_deaths, V.new_tests, V.new_vaccinations, SUM(V.new_vaccinations) OVER (Partition by D.location ORDER BY D.location, D.date) as RollingVacinated
 FROM CovidDeaths as D
 JOIN CovidVaccinations as V ON D.location = V.location AND D.date = V.date
 WHERE D.continent IS NOT NULL

 --Use CTE
 WITH PopvsVac (Continent, Location, Date, Population, Total_cases, Total_deaths, New_tests, New_vaccinations, RollingPeopleVaccinated) AS
 (
 SELECT D.continent, D.location, D.date, D.population,D.total_cases,D.total_deaths, V.new_tests, V.new_vaccinations, SUM(V.new_vaccinations) OVER (Partition by D.location ORDER BY D.location, D.date) as RollingPeopleVaccinated
 FROM CovidDeaths as D
 JOIN CovidVaccinations as V ON D.location = V.location AND D.date = V.date
 WHERE D.continent IS NOT NULL
 )
 SELECT *, (RollingPeopleVaccinated/Population)*100 as Percentage
 FROM PopvsVac

 -- TEMP TABLE and Use Drop Table if has anychange query
 DROP TABLE IF exists #Processed_Data
 CREATE TABLE #Processed_Data
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date Datetime,
 Population numeric,
 Total_cases numeric, 
 Total_deaths numeric, 
 New_tests numeric,
 New_vaccinations numeric, 
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #Processed_Data
 SELECT D.continent, D.location, D.date, D.population,D.total_cases,D.total_deaths, V.new_tests, V.new_vaccinations, SUM(V.new_vaccinations) OVER (Partition by D.location ORDER BY D.location, D.date) as RollingPeopleVaccinated
 FROM CovidDeaths as D
 JOIN CovidVaccinations as V ON D.location = V.location AND D.date = V.date
 WHERE D.continent IS NOT NULL

 SELECT *, (RollingPeopleVaccinated/Population)*100 as Percentage
 FROM #Processed_Data

 --CREATE VIEW TABLE to store data for later visualizations
 
 CREATE VIEW Cleaned_Data AS
 SELECT D.continent, D.location, D.date, D.population, D.new_cases, D.new_deaths, D.total_cases, D.total_deaths, V.new_tests, V.new_vaccinations, V.total_vaccinations, SUM(V.new_vaccinations) OVER (Partition by D.location ORDER BY D.location, D.date) as RollingPeopleVaccinated
 FROM CovidDeaths as D
 JOIN CovidVaccinations as V ON D.location = V.location AND D.date = V.date
 WHERE D.continent IS NOT NULL

 SELECT *
 FROM Cleaned_Data
