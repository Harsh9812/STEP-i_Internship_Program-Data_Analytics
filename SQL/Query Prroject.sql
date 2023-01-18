-- 1. Create a table named ‘matches’ with appropriate data types 
--    for columns
create table matches (
id int,
city varchar,
date timestamp,
player_of_match varchar,
venue varchar,
neytral_venue int,
team1 varchar,
team2 varchar,
toss_winner varchar,
toss_decision varchar,
winner varchar,
result varchar,
result_margin int,
eliminator varchar,
method varchar,
umpire1 varchar,
umpire2 varchar);

-- 2. Create a table named ‘deliveries’ with appropriate 
--    data types for columns
create table deliveries (
id int,
inning int,
over int,
ball int,
batsman varchar,
non_striker varchar,
bowler varchar,
batsman_runs int,
extra_runs int,
total_runs int,
is_wicket int,
dismissal_kind varchar,
player_dismissed varchar,
fielder varchar,
extras_type varchar,
batting_team varchar,
bowling_team varchar );

-- 3. Import data from CSV file ’IPL_matches.csv’ attached 
--    in resources to ‘matches’
copy matches from 
'C:\Program Files\PostgreSQL\15\data_copy\IPL_matches.csv' 
delimiter ',' csv header;

-- 4. Import data from CSV file ’IPL_Ball.csv’ attached 
--    in resources to ‘deliveries’
copy deliveries from 
'C:\Program Files\PostgreSQL\15\data_copy\IPL_Ball.csv'
delimiter ',' csv header;

select * from matches;
select * from deliveries;

-- 5. Select the top 20 rows of the deliveries table.
select * from deliveries limit 20;

-- 6. Select the top 20 rows of the matches table.
select * from matches limit 20;

-- 7. Fetch data of all the matches played on 2nd May 2013.
select * from matches where date = '2008-05-02';

-- combine details of Matches and Deliveries
select
a.*,
b.*
from matches as a
full join deliveries as b
on a.id = b.id
where date = '2008-05-02';

--8. Fetch data of all the matches where the margin of victory 
--   is more than 100 runs.
select * from matches where result = 'runs' and result_margin > 100;

-- combine details of Matches and Deliveries
select
a.*,
b.*
from deliveries as a
full join matches as b
on a.id = b.id
where result_margin > 100;

-- 9. Fetch data of all the matches where the final scores of both
--    teams tied and order it in descending order of the date.
select * from matches where result = 'tie' order by date desc;

-- combine details of Matches and Deliveries
select
a.*,
b.*
from deliveries as a
full join matches as b
on a.id = b.id
where result = 'tie'
order by b.date desc, a.inning asc, a.over asc, a.ball asc;

-- 10. Get the count of cities that have hosted an IPL match.
select count(distinct city) from matches;
select city, count(distinct city) from matches group by city;
select city, count(city) from matches group by city;

/* 11. create table deliveries_v02 with all the columns 
of the table 'deliveries' and an additional 
column ball_result containing values boundary, 
dot or other depending on the total_run */

create table deliveries_vo2 as select *,
case when total_runs >= 4 then 'Boundary'
when total_runs = 0 then 'Dot'
else 'other'
end as ball_result
from deliveries;

select * from deliveries_vo2;

/*12. write a query to fetch the total number of 
boundaries and dot balls from the deliveries_v02 table. */

select ball_result, count(*) from deliveries_vo2 
group by ball_result;

/*13. Write a query to fetch the total number of 
boundaries scored by each team from the deliveries_v02 
table and order it in descending order of the 
number of boundries scored.*/

select batting_team, 
count(*) from deliveries_vo2 
where ball_result = 'Boundary' 
group by batting_team order by count desc;

/* 14. Write a query to fetch the total number 
of dot balls bowled by each team and order it in 
descending order of the total number of dot balls bowled. */

select bowling_team, count(*) from deliveries_vo2 
where ball_result = 'Dot' 
group by bowling_team 
order by count desc;

/*15. Write a query to fetch the total number 
of dismissals by dismissal kinds 
where dismissal kind is not known */

select dismissal_kind, 
count(*) from deliveries where dismissal_kind = 'NA' 
group by dismissal_kind;

/*16. write a query to get the top 5 bowlers 
who conceded maximum extra runs from the deliveries table */

select * from deliveries;

select bowler, max(extra_runs) from deliveries 
group by bowler limit 5;

/* 17. write a query to create a table named 
deliveries_vo3 with all the columns of deliveries_v02 table 
and two additional column (named venue and match_date) 
of venue and date from the table matches */

create table deliveries_vo3 as select
a.*,
b.venue,
b.date
from deliveries_vo2 as a
left join matches as b
on a.id = b.id;

select * from deliveries_vo3;

/* 18. Write a query to fetch the total runs scored 
for each venue and order it in the descending order 
of total runs scored */

select venue, sum(total_runs) as Total_Runs_Scored 
from deliveries_vo3 group by venue 
order by Total_Runs_Scored desc; 

/*19. Write a query to fetch the year wise total runs 
scored at Eden Gardens and order it in the descending 
order of total runs scored.*/
select * from matches;

-- Tip : Hume alg se Year ka column nhi diya hua to hume
-- Date waale column se Year ko extract krna h

select extract(Year from date) as IPL_Year from deliveries_vo3;

select extract(Year from date) as IPL_Year, 
sum(total_runs) as Total_runs_scored from deliveries_vo3 
where venue = 'Eden Gardens' group by IPL_Year 
order by Total_runs_scored desc;

/*20. Get unique team 1 names from the matches table, 
you will notice that there are two entires for 
rising pune supergiant one with Rising Pune Supergiant 
and another one with Rising Pune Supergiants*/

select distinct team1, team2 from matches;
select distinct team1 from matches;

create table matches_corrected as select *, 
replace(team1,'Rising Pune Supergiants','Rising Pune Supergiant') 
as team1_correction,
replace(team2,'Rising Pune Supergiants','Rising Pune Supergiant') 
as team2_Correction from matches;

select distinct team1_correction from matches_corrected;

/*21. create a new table deliveries_v04 with the first column 
as ball_id containing information of 
match_id, inning, over and ball separated by '-' 
For ex. 335982-1-0-1 match id-inning-over-ball) 
and rest of the columns same as deliveries_v03 */

select * from deliveries;

select id || '-' || inning || '-' || over ||'-' || ball 
as ball_id from deliveries_vo3

create table delivering_vo4 as select 
concat(id,'-',inning,'-',over,'-',ball) 
as ball_id from deliveries_vo3

/*22. compare the total count of rows and total count 
of distinct ball_id in deliveries_vo4 */

select * from delivering_vo4;
select count(distinct ball_id) from delivering_vo4;
select count(*) from delivering_vo4;


