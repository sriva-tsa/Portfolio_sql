--quick view of the datasets imported

Select * from Indian_census.dbo.Census1

Select * from Indian_census.dbo.Census2

--Row count

Select count(*) from Indian_census.dbo.Census1

Select count(*) from Indian_census.dbo.Census2

--data related to jharkhand and bihar

Select * from Indian_census.dbo.Census1
where state in('Jharkhand','Bihar')
order by district

Total population of india

select sum(population) as totalpopulation
from Indian_census.dbo.Census2

--average growth %

select AVG(Growth)*100 from Indian_census.dbo.Census1

--Average growth by state

Select state,avg(growth)*100 as growthbystate
from Indian_census.dbo.Census1
group by State

--Average sex ratio 

Select state,round(avg(sex_ratio),0) as growthbySexratio
--->> O here implies that we are rounding decimal point
from Indian_census.dbo.Census1   
group by State 
order by growthbySexratio desc;

--Average literacy rate

Select state,avg(Literacy) as AVGliteracyrate
from Indian_census.dbo.Census1
group by State
having avg(Literacy) > 90

------Highest growth ratio----------------
--using top function below as ssms doesn't support limit

select top 3 state,avg(Growth)*100 as avggrowth
from Indian_census.dbo.Census1
group by state
order by avggrowth desc

----Bottom 3 states showing lowest sex ratio

select top 3 state,avg(sex_ratio) as avgsexratio
from Indian_census.dbo.Census1
group by state
order by avgsexratio asc

--Top and bottom 3 states in literacy

drop table if exists #topstates
create table #topstates
( state nvarchar(255),
  topstate float
)

insert into #topstates
select state,round(avg(literacy),0) avg_literacy_ratio 
from Indian_census.dbo.Census1
group by state order by avg_literacy_ratio desc;

select * from #topstates order by #topstates.topstate desc;

select top 3 * from #topstates order by #topstates.topstate desc;


drop table if exists #bottomstates
create table #bottomstates
( state nvarchar(255),
  bottomstate float
)

insert into #bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio 
from Indian_census.dbo.Census1
group by state order by avg_literacy_ratio desc;

select * from #bottomstates order by #bottomstates.bottomstate asc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;

--Subquerying both the below statements to display it as a single table

select * from(
select top 3 * from #topstates order by #topstates.topstate desc) a
union
select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b

--states starting with letter 'a'

select distinct State
from Indian_census.dbo.Census1
where state like 'a%'

--where letter is starting with a and b

select distinct State
from Indian_census.dbo.Census1
where state like 'a%' or state like 'b%'

--where letter is starting with a and ending with u
select distinct State
from Indian_census.dbo.Census1
where state like 't%' and state like '%u'

--Joining census 1 and census 2

select a.District,a.State,Sex_Ratio,Population
from Indian_census.dbo.Census1 a
inner join 
Indian_census.dbo.Census2 b
on a.district = b.district

--male = population/sexratio+1
--females = population-population/sexratio+1

select t.District,t.State,t.population/(t.sexratio+1) males,
(t.Population*t.sexratio)/(t.sexratio+1) females
from 
(
select a.District,a.State,Sex_Ratio/1000 sexratio,Population
from Indian_census.dbo.Census1 a
inner join 
Indian_census.dbo.Census2 b
on a.district = b.district
)t

--total males and femnales
select e.State,sum(e.males) as malesum,sum(e.females) as femalesum
from 
(
select t.District,t.State,t.population/(t.sexratio+1) males,
(t.Population*t.sexratio)/(t.sexratio+1) females
from 
(
select a.District,a.State,Sex_Ratio/1000 sexratio,Population
from Indian_census.dbo.Census1 a
inner join 
Indian_census.dbo.Census2 b
on a.district = b.district
)t
)e
group by e.State

--total literacy ratio
 
select state,sum(literate_people) total_literate_pop,
sum(illiterate_people) total_lliterate_pop from 
(
select c.district,c.state,round(c.literacy_ratio*c.population,0)literate_people,
round((1-c.literacy_ratio)* c.population,0) illiterate_people from
(
select a.district,a.State,Literacy/100 as literacy_ratio,Population
from Indian_census.dbo.Census1 a
inner join 
Indian_census.dbo.Census2 b
on a.district = b.district
)c
)d	
group by d.State

--Population in previous census

select sum(e.previous) as previouscensus,sum(e.currentt) as currentcensus
from
(
select d.State,sum(d.previous_census) as previous,
sum(d.current_census) as currentt
from
(
select c.District,c.State,round(c.population/(1+c.Growth),0) as previous_census,
c.population as  current_census
from
(
select a.District,a.State,a.Growth,Population
from Indian_census.dbo.Census1 a
inner join 
Indian_census.dbo.Census2 b
on a.district = b.district
)c)d
group by d.State
) e


--Population VS area

select g.totalarea/g.previouscensus as previouscensuspopulation,
g.totalarea/g.currentcensus as currentcensuspopulation 
from
(
select p.totalarea,o.*
from
(
select '1' as keyy,f.*
from
(
select sum(Area_km2) totalarea from Indian_census.dbo.Census2
)f
)p
inner join 
(
select '1' as keyy, n.*
from
(
select sum(e.previous) as previouscensus,sum(e.currentt) as currentcensus
from
(
select d.State,sum(d.previous_census) as previous,
sum(d.current_census) as currentt
from
(
select c.District,c.State,round(c.population/(1+c.Growth),0) as previous_census,
c.population as  current_census
from
(
select a.District,a.State,a.Growth,Population
from Indian_census.dbo.Census1 a
inner join 
Indian_census.dbo.Census2 b
on a.district = b.district
)c)d
group by d.State
) e 
) n
) o

on p.keyy=p.keyy
)g


--Use of window function 

output top 3 districts from each state with highest literacy rate

select a.* from
(select district,state,literacy,
rank() over(partition by state order by literacy desc) rnk from project..data1) a
where a.rnk in (1,2,3) order by state