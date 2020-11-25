-- 1.   List the number of patients in each chronic condition. Only include patients with more than 100 conditions
-- Logged the condition 100 times, not 100 unique conditions
SELECT tri_name, COUNT(contactid) AS number_chronic FROM Demographics a
INNER JOIN
Conditions b
ON
a.contactid=b.tri_patientid
WHERE tri_name NOT LIKE '%Activity Monitoring%'
GROUP BY tri_name
HAVING COUNT(contactid)>100

-- 2.   What is average height of both an inpatient and an outpatient where patient’s age is over 65
SELECT IN_OUT, AVG(MEAS_VALUE) AS AVG_HEIGHT
FROM
(
SELECT 'Inpatient' AS 'IN_OUT', NEW_PAT_ENC_CSN_ID, DOB_CATEGORY FROM Inpatient
UNION
SELECT 'Outpatient' AS 'IN_OUT', NEW_PAT_ENC_CSN_ID, PATIENT_DOB_CATEGORY FROM Outpatient
) a
INNER JOIN Flowsheets
ON
a.NEW_PAT_ENC_CSN_ID = Flowsheets.PAT_ENC_CSN_ID
WHERE DISP_NAME LIKE 'Height'
AND DOB_CATEGORY LIKE '%Over 64%'
GROUP BY a.IN_OUT

-- 3.   What are the average height and weight of a patient suffering with Hypertension?
SELECT AVG(PAT_HEIGHT) AS HYP_HEIGHT, AVG(PAT_WEIGHT) AS HYP_WEIGHT
FROM
(
    SELECT * FROM Dx
    WHERE DX_NAME LIKE '%Hypertension%'
) hypertension
INNER JOIN
(
    SELECT height.PAT_ENC_CSN_ID, PAT_HEIGHT, PAT_WEIGHT
    FROM

    (
        SELECT PAT_ENC_CSN_ID, MEAS_VALUE AS PAT_HEIGHT FROM Flowsheets
        WHERE DISP_NAME LIKE '%Height%'
        GROUP BY PAT_ENC_CSN_ID, MEAS_VALUE
        
    ) height
    INNER JOIN
    (
        SELECT PAT_ENC_CSN_ID, MEAS_VALUE AS PAT_WEIGHT FROM Flowsheets
        WHERE DISP_NAME LIKE 'Weight'
        GROUP BY PAT_ENC_CSN_ID, MEAS_VALUE
    ) weight_table
    ON
    height.PAT_ENC_CSN_ID = weight_table.PAT_ENC_CSN_ID
) height_weight
ON
hypertension.NEW_PAT_ENC_CSN_ID=height_weight.PAT_ENC_CSN_ID

-- Calculate the BMI and then compare it with actual BMI in the data
SELECT AVG(PAT_BMI) AS HYP_BMI
FROM
(
    SELECT * FROM Dx
    WHERE DX_NAME LIKE '%Hypertension%'
) hypertension
INNER JOIN
(
    SELECT PAT_ENC_CSN_ID, MEAS_VALUE AS PAT_BMI
    FROM Flowsheets
    WHERE DISP_NAME LIKE '%BMI (Calculated)%'
    GROUP BY PAT_ENC_CSN_ID, MEAS_VALUE
        
) BMI
ON
hypertension.NEW_PAT_ENC_CSN_ID=BMI.PAT_ENC_CSN_ID

-- Simpler Method
SELECT AVG(MEAS_VALUE) AS HYP_BMI
FROM
Dx
INNER JOIN
Flowsheets
ON
Dx.NEW_PAT_ENC_CSN_ID=Flowsheets.PAT_ENC_CSN_ID
WHERE DISP_NAME LIKE '%BMI (Calculated)%'
AND DX_NAME LIKE '%Hypertension%'
