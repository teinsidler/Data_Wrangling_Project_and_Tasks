--Verify that whether the counts of each code or value for various variables    are correct as mentioned in the website

-- Based on the use of the term 'Various,' I have done this for three different variables, all of which are ones that I worked with in this assignment.
-- This is in order to demonstrate that my changes did not affect the proper counts.

SELECT
COUNT(CASE WHEN DID350 BETWEEN 1 AND 20 THEN 'Range of Values' END) AS 'Range of Values',
COUNT(CASE WHEN DID350 = 0 THEN 'None' END) AS 'None',
COUNT(CASE WHEN DID350 = 7777 THEN 'Refused' END) AS 'Refused',
COUNT(CASE WHEN DID350 = 9999 THEN 'Don''t Know' END) AS 'Don''t Know',
COUNT(CASE WHEN DID350 is NULL THEN 'Missing' END) AS 'Missing'
FROM eeinsidler.midterm


SELECT DIQ060U AS [Code], COUNT(*) AS [Count],
CASE
    WHEN DIQ060U = 1 THEN 'Month'
    WHEN DIQ060U = 2 THEN 'Year'
    WHEN DIQ060U is NULL THEN 'Missing'
END AS [Value Description]
FROM eeinsidler.midterm
GROUP BY DIQ060U


SELECT DIQ175G AS [Code], COUNT(DIQ175G) AS [Count],
CASE
    WHEN DIQ060U = 16 THEN 'Lack of physical activity'
    WHEN DIQ060U = 0 THEN 'Missing'
END AS [Value Description]
FROM eeinsidler.midterm
GROUP BY DIQ175G