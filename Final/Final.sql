-- 2)	Merge the tables Demographics, Conditions and TextMessages. 
-- Obtain the final dataset such that we have 1 Row per ID by choosing on the latest date when the text was sent
-- (if sent on multiple days)

SELECT d.contactid,
	d.gendercode,
	d.tri_age,
	d.parentcustomeridname,
	d.tri_imaginecareenrollmentstatus,
	d.address1_stateorprovince,
	d.tri_imaginecareenrollmentemailsentdate,
	d.tri_enrollmentcompletedate,
	d.gender,
	c.tri_name,
	t.SenderName, t.TextSentDate
INTO eeinsidler.final_q2
FROM
	Demographics d
	INNER JOIN
		Conditions c
		ON d.contactid = c.tri_patientid
	INNER JOIN
		Text t
		ON c.tri_patientid = t.tri_contactId


SELECT f.*
INTO eeinsidler.final_q2_max
FROM eeinsidler.final_q2 f
INNER JOIN (SELECT contactid, MAX(TextSentDate) AS MaxTextDate
    FROM eeinsidler.final_q2
    GROUP BY contactid) groupf
ON f.contactid = groupf.contactid
AND f.TextSentDate = groupf.MaxTextDate


SELECT top 10 * FROM eeinsidler.final_q2_max
ORDER BY NEWID()

-- DROP TABLE eeinsidler.final_q2_max