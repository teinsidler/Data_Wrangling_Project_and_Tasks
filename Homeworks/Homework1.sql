-- Make a copy of the Demographics table to use for the HW Assignment


-- Rename all the columns for eg.,
--a)	TriAge to Age
--b)	GenderCode to Gender
--c)	ContactID to ID
--d)	Address1Stateorprovince to State
--e)	TriImagineCareenrollmentemailsentdate to EmailSentdate
--f)	Trienrollmentcompletedate to Completedate
--g)	Calculate the time (in days) to complete enrollment and create a new column to have this data

--DROP TABLE eeinsidler.HW1_QBS181

SELECT contactid AS ID,
    gendercode AS GenderCopy,
    tri_age AS Age,
    parentcustomeridname AS parentID,
    tri_imaginecareenrollmentstatus AS EnrollStatusCode,
    address1_stateorprovince AS AddressState,
    tri_imaginecareenrollmentemailsentdate AS EmailSentDate,
    tri_enrollmentcompletedate AS CompleteDate,
    gender AS GenderInt,
    DATEDIFF(DD, TRY_CONVERT(datetime, tri_imaginecareenrollmentemailsentdate, 101), TRY_CONVERT(datetime, tri_enrollmentcompletedate, 101)) AS EnrollmentCompletionDays
INTO eeinsidler.HW1_QBS181 FROM dbo.Demographics

-- 2.	Create a new column “Enrollment Status”
--a)	Insert Status=Complete :code is 167410011
--b)	Insert Status=Email sent :code is 167410001
--c)	Insert Status=Non responder: Code is 167410004
--d)	Insert Status=Facilitated Enrollment: Code  is 167410005
--e)	Insert Status= Incomplete Enrollments: Code  is 167410002
--f)	Insert Status= Opted Out: Code  is 167410003
--g)	Insert Status= Unprocessed: Code  is 167410000
--h)	Insert Status= Second email sent : Code  is 167410006

ALTER TABLE eeinsidler.HW1_QBS181
    ADD EnrollmentStatus AS
        CASE
            WHEN EnrollStatusCode = 167410011 THEN 'Complete'
            WHEN EnrollStatusCode = 167410001 THEN 'Email sent'
            WHEN EnrollStatusCode = 167410004 THEN 'Non responder'
            WHEN EnrollStatusCode = 167410005 THEN 'Facilitated Enrollment'
            WHEN EnrollStatusCode = 167410002 THEN 'Incomplete Enrollment'
            WHEN EnrollStatusCode = 167410003 THEN 'Opted Out'
            WHEN EnrollStatusCode = 167410000 THEN 'Unprocessed'
            WHEN EnrollStatusCode = 167410006 THEN 'Second email sent'
        END

-- 3.	Create a new Column “Gender”
--a)	Insert Gender=female if code=2
--b)	Insert Gender=male if code=1
--c)	Insert Gender=other if code =167410000
--d)	Insert Gender=Unknown if code =’NULL’

ALTER TABLE eeinsidler.HW1_QBS181
    ADD Gender AS
        CASE
            WHEN GenderInt = 2 THEN 'female'
            WHEN GenderInt = 1 THEN 'male'
            WHEN GenderInt = 167410000 THEN 'other'
            ELSE 'Unknown'
        END

-- 4.	Create a new column “Age group” and create age groups with an interval of 25 yrs.
-- for example 0-25 years as ‘0-25’, 26-50 as “26-50” and so on...
ALTER TABLE eeinsidler.HW1_QBS181
    ADD AgeGroup AS
        CASE
            WHEN Age > 0 AND Age < 26 THEN '0-25'
            WHEN Age > 25 AND Age < 51 THEN '26-50'
            WHEN Age > 50 AND Age < 76 THEN '51-75'
            WHEN Age > 75 AND Age < 101 THEN '76-100'
            WHEN Age >100 THEN '>100'
            ELSE 'Unknown'
        END

-- •	Print random 10 rows to show these changes. Please also include the code
SELECT TOP 10 * FROM eeinsidler.HW1_QBS181
ORDER BY NEWID()