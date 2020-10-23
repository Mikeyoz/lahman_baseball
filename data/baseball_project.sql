/* question 1
select min(yearid) as start_date, max(yearid) as end_date
from teams

/* question 2
WITH shortest_player AS (SELECT *
						FROM people
						ORDER BY height
						LIMIT 1),
sp_total_games AS (SELECT *
				  FROM shortest_player
				  LEFT JOIN appearances
				  USING(playerid))
SELECT DISTINCT(name), namelast, namefirst, height, g_all as games_played, sp_total_games.yearid
FROM sp_total_games
LEFT JOIN teams
USING(teamid)

--second way of doing #2
Select namefirst, namelast, height, appearances.g_all, teams.name
FROM people
JOIN appearances
ON people.playerid = appearances.playerid
JOIN teams
ON teams.teamid = appearances.teamid
WHERE height = 43
GROUP BY people.namefirst, people.namelast, people.height, appearances.teamid, teams.name,appearances.g_all ;

--question #3
SELECT distinct concat(p.namefirst, ' ', p.namelast) as name, sc.schoolname,
sum(sa.salary) OVER (partition by concat(p.namefirst, ' ', p.namelast))::numeric::money as total_salary
FROM (people p JOIN collegeplaying cp ON p.playerid = cp.playerid)
JOIN schools sc ON cp.schoolid = sc.schoolid
JOIN salaries sa ON p.playerid = sa.playerid
where cp.schoolid = 'vandy'
group by name, schoolname, sa.salary, sa.yearid
ORDER BY total_salary desc

--question #4 
SELECT SUM(po) as put_out,
	   CASE WHEN pos='OF' THEN 'outfield'
	   	   	WHEN pos='1B' OR pos='2B' OR pos='3B' OR pos='SS' THEN 'infield'
	   	    ELSE 'battery' END AS position_group
FROM fielding
WHERE yearid=2016
GROUP BY position_group
ORDER BY SUM(po) DESC

-- question #5
SELECT yearid/10 * 10 AS decade, 
	ROUND(((SUM(so)::float/SUM(g))::numeric), 2) AS avg_so_per_game,
	ROUND(((SUM(so)::float/SUM(ghome))::numeric), 2) AS avg_so_per_ghome
FROM teams
WHERE yearid >= 1920 
GROUP BY decade

--second way of doing #5
SELECT yearid/10*10 as decade, ROUND(AVG(HR/g), 2) as avg_HR_per_game,ROUND(AVG(so/g), 2) as avg_so_per_game
FROM teams
WHERE yearid>=1920
GROUP BY decade
ORDER BY decade


--question #6
SELECT DISTINCT(batting.playerid) as player, namefirst, namelast, teamid, SUM(cs+sb) as sb_attempts, SUM((sb::float/(sb::float+cs::float)))*100 AS sb_success, yearid
FROM batting
LEFT JOIN people
ON batting.playerid = people.playerid
WHERE yearid = '2016' AND cs > 0 AND sb > 0 AND (cs + sb)>=20
GROUP BY player, namefirst, namelast, yearid, teamid
ORDER BY sb_success desc
LIMIT 1;

--question #7
--part1
SELECT yearid, sum(w) as wins, wswin, franchid
from teams 
WHERE wswin IS NOT null
and wswin = 'N'
and yearid between 1970 and 2016
group by wswin, franchid, yearid
order by wins DESC
limit 1;
--largest = SEA, 116 wins for 2001

--part2 
SELECT yearid, sum(w) as wins, wswin, franchid
from teams 
WHERE wswin IS NOT null
and wswin = 'N'
and yearid between 1970 and 2016
group by wswin, franchid, yearid
order by wins
limit 1;
--smallest = TOR, 37 win for 1981

--part3
SELECT yearid, sum(w) as wins, wswin, franchid
from teams 
WHERE wswin IS NOT null
and wswin = 'Y'
and yearid between 1970 and 2016
group by wswin, franchid, yearid
order by wins;
-- players strike in 1981

--part4 
WITH base_ball AS (
	SELECT yearid, w, wswin, franchid, rank() over (partition by yearid order by w desc)
	from teams 
	WHERE wswin IS NOT null
	and yearid between 1970 and 2016
	and yearid != 1981
),
baseball_wins as 
	(SELECT*
	FROM base_ball
	where rank = 1
	AND wswin = 'Y')
	
SELECT (count(*)::float/45)*100 as percent_wins 
FROM baseball_wins

--question #8
SELECT DISTINCT p.park_name, h.team,
	(h.attendance/h.games) as avg_attendance, t.name		
FROM homegames as h JOIN parks as p ON h.park = p.park
LEFT JOIN teams as t on h.team = t.teamid AND t.yearid = h.year
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;

--question #9
WITH manager_both AS (SELECT playerid, al.lgid AS al_lg, nl.lgid AS nl_lg,
					  al.yearid AS al_year, nl.yearid AS nl_year,
					  al.awardid AS al_award, nl.awardid AS nl_award
	FROM awardsmanagers AS al INNER JOIN awardsmanagers AS nl
	USING(playerid)
	WHERE al.awardid LIKE 'TSN%'
	AND nl.awardid LIKE 'TSN%'
	AND al.lgid LIKE 'AL'
	AND nl.lgid LIKE 'NL')
	
SELECT DISTINCT(people.playerid), namefirst, namelast, managers.teamid,
		managers.yearid AS year, managers.lgid
FROM manager_both AS mb LEFT JOIN people USING(playerid)
LEFT JOIN salaries USING(playerid)
LEFT JOIN managers USING(playerid)
WHERE managers.yearid = al_year OR managers.yearid = nl_year;






