
/*
1st SQL project 
Name | Covid 19 Data Exploration 

*/



-- General view by deaths  

select * 
from PortfolioProject..CovidDeaths
order by 3,4


-- General view by Vaccinations

select * 
from PortfolioProject..CovidVaccinations
order by 3,4


-- Selecting specific data that I'm interetesed in  

Select location, date, total_cases, new_cases, total_deaths, population
from	PortfolioProject..CovidDeaths
order by 1,2


/*
Looking at :
	-Total Cases, 
	-Total Deaths + 
	-likelyhood of dying after geting infected
*/

Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as Percentage
from PortfolioProject..CovidDeaths
where location like '%Italy%'
order by 1,2

/*
Looking at :
	-Total Cases 
	-Population 
	-Percentage of population that got covid 
*/

Select location, date, total_cases, population, round((total_cases/population)*100,2) as Percentage
from PortfolioProject..CovidDeaths
where continent IS NOT NULL AND 
 location like '%Italy%'
order by 1,2


/*
Looking at :
	- countries ordered by the highest infection rate per capita
*/

Select location, population, max(total_cases) as HighetsInfectionCount, max((total_cases/population))*100 as 
Percentage_Population_Infected
from PortfolioProject..CovidDeaths
where continent IS NOT NULL 
group by location, population
order by Percentage_Population_Infected desc 

    
/*
Looking at :
	- countries with the highest death count 
	- Percentage of population deaths
*/

Select location, population, max(cast(total_deaths as int)) as Total_Death_Count, ROUND(max((total_deaths/population))*100,2) as 
Percentage_Population_Death
from PortfolioProject..CovidDeaths
where continent IS NOT NULL 
group by location, population
order by Percentage_Population_Death desc


/*
Looking at :
	- CONTINENTS with the highest death count 
	- Percentage of population deaths
*/

Select continent, max(cast(total_deaths as int)) as Total_Death_Count, ROUND(max((total_deaths/population))*100,5) as 
Percentage_Population_Death
from PortfolioProject..CovidDeaths
where continent IS NOT NULL 
group by continent
order by  Total_Death_Count desc 


/*
Looking at :
	- Total deaths worldwide  
	- Ration of death
		- optional| filtration by date
*/

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND(SUM(cast(new_deaths as int))/SUM(New_Cases)*100,2) as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2



/*
Looking at :
	- Population that has recieved Covid Vacination ordered by Location and Date
*/
 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



/*
CTE 
Looking at :
	- New vaccination ordered by location and date 
	- the cumulative number of vaccinated people
*/

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



/*
Tempt table 
Looking at :
	- New vaccination ordered by location and date 
	- the cumulative number of vaccinated people
*/

Drop table if exists #PErcentPopulationVaccinated
create table #PErcentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)


insert into #PErcentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PErcentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
