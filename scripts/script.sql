-- 1) What range of years for baseball games played does the provided database cover? 1871-2016

SELECT MIN(yearid) as first_year, Max(yearid) AS final_year
FROM appearances;

-- 2) Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
--Eddie Gaedel, 1 game, St. Louis Browns

SELECT CONCAT (namefirst, ' ', namelast) AS name, height, a.g_all, a.teamid
FROM people AS p
Inner Join appearances AS a
On p.playerid = a.playerid
GROUP BY name, a.g_all, a.teamid, height
ORDER BY height;

--3) Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors? David Price
SELECT CONCAT(namefirst, ' ', namelast) AS name, SUM(s.salary) AS total_salary
FROM people AS p
LEFT JOIN salaries as s
ON p.playerid = s.playerid
LEFT JOIN collegeplaying AS c
ON p.playerid = c.playerid
LEFT JOIN schools AS sc
ON c.schoolid = sc.schoolid
WHERE sc.schoolname = 'Vanderbilt University'
GROUP BY name
ORDER BY total_salary DESC;


--4) Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT SUM(po) AS putouts,
CASE WHEN pos = 'OF' THEN 'Outfield'
     WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
     WHEN pos IN ('P', 'C') THEN 'Battery'
     ELSE 'Other' END AS position
FROM fielding
WHERE yearid = '2016'
GROUP BY position;

--5) Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends? 
--Homeruns tend to stay similar after 1950, Strikouts rise steadily after 1920
SELECT decade, ROUND(AVG(so), 2) AS average_strikeouts, ROUND(AVG(hr), 2) AS            average_homer
FROM (
     SELECT yearid, yearid / 10 * 10 AS decade, so, hr
     FROM batting) AS so_by_decade
GROUP BY decade
ORDER BY decade;

--6) Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
--Chris Owings with 91.3%

SELECT  CONCAT(namefirst, ' ', namelast) AS name, (b.sb + b.cs) AS                       total_attempt, (CAST(b.sb AS numeric) / (b.sb + CAST(b.cs AS numeric))) AS successful_stolen
FROM people AS p
INNER JOIN batting as b
ON p.playerid = b.playerid
WHERE (b.sb + b.cs) >= 20
      AND yearid = '2016'
GROUP BY name, b.sb, b.cs
ORDER BY successful_stolen DESC;
--7) From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? SEA with 116
SELECT teamid, w as wins
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
      AND wswin = 'N'
Group by teamid, w
Order by wins desc;
--What is the smallest number of wins for a team that did win the world series?
--LAN with 63 wins
SELECT teamid, w as wins
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
      AND wswin = 'Y'
Group by teamid, w
Order by wins;
--Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. less games in 1981 due to a players strike
SELECT yearid, g as games
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
      AND wswin = 'Y'
Group by yearid, g
order by games;
--Then redo your query, excluding the problem year. 
SELECT teamid, w as wins
FROM teams
WHERE wswin = 'Y' 
        AND yearid BETWEEN '1970' AND '2016'
        AND yearid <> '1981'
Group by teamid, w
Order by wins;


--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SELECT teamid, w as wins
FROM teams
WHERE wswin = 'Y' 
        AND yearid BETWEEN '1970' AND '2016'
        AND yearid <> '1981'
Group by teamid, w
Order by wins;



--8) Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance.
--LOS03 LAN, 45719
SELECT park, team, (attendance/games) AS avg_attendance
FROM homegames
WHERE games >= 10
      AND year = 2016
GROUP BY park, team, attendance, games
ORDER BY avg_attendance DESC;

--Repeat for the lowest 5 average attendance.
--STP01 TBA 15878
SELECT park, team, (attendance/games) AS avg_attendance
FROM homegames
WHERE games >= 10
      AND year = 2016
GROUP BY park, team, attendance, games
ORDER BY avg_attendance;

--9) Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
--DAVEY Johnson BAL, CIN, LAN, NYN, WAS
--Jim Leyland COL, DET, FLO, PIT

WITH NL AS(
     SELECT playerid
     FROM awardsmanagers
     WHERE awardid = 'TSN Manager of the Year'
           AND lgid = 'NL'),
           AL AS(
     SELECT playerid
     FROM awardsmanagers
     WHERE awardid = 'TSN Manager of the Year'
           AND lgid = 'AL')
SELECT DISTINCT CONCAT (p.namefirst, ' ', p.namelast) AS name, m.teamid
FROM people as p
LEFT JOIN managers as m
ON p.playerid = m.playerid
INNER JOIN NL AS n
ON p.playerid = n.playerid
INNER JOIN AL AS a
ON p.playerid = a.playerid
WHERE n.playerid = a.playerid;

--10) Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
SELECT CONCAT (p.namefirst, ' ', p.namelast) AS name, b.hr
FROM people AS p
LEFT JOIN batting as b
ON p.playerid = b. playerid
WHERE p.debut > '01-01-2006'
      AND b.hr >=1
      AND b.yearid = '2016'
GROUP BY name, b.hr
HAVING b.hr = MAX(hr)
ORDER BY b.hr DESC;



-- Open-ended questions

--11) Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.
SELECT s.yearid, s.teamid, SUM(s.salary) as team_salary, t.w as wins
FROM salaries AS s
LEFT JOIN teams as t
ON s.teamid = t.teamid
   AND s.yearid = t.yearid
WHERE s.yearid >= 2000
GROUP BY s.yearid, s.teamid, wins
ORDER BY s.yearid, team_salary DESC, wins;
--12) In this question, you will explore the connection between number of wins and attendance.

--a) Does there appear to be any correlation between attendance at home games and number of wins?
--b) Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.
--13) It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?