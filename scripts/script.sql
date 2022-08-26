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
SELECT  CASE(WHEN pos = 'OF')

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
--7) From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--8) Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--9) Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

--10) Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

-- Open-ended questions

--11) Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

--12) In this question, you will explore the connection between number of wins and attendance.

--13) Does there appear to be any correlation between attendance at home games and number of wins?
--14) Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.
--15) It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?