-- 1.	How many patients had hypertension and belonged to Dartmouth-Hitchcock
-- a.	959 (957 at Dartmouth-Hitchcock, 1 at Dartmouth-Hitchcock Primary Care, and 1 at Dartmouth-Hitchcock Pulmonary Clinic).

select parentcustomeridname, count(tri_name) as num_disease from Demographics a
inner JOIN
Conditions b
on
a.contactid=b.tri_patientid
where parentcustomeridname like '%th-Hitchcock%'
and tri_name='Hypertension'
group by parentcustomeridname


-- 2.	What is the average age of each patient having Hypertension,COPD, and CHF?
--a.	COPD: 45.28971962616822 years old
--b.	Hypertension: 53.21677074041035 years old
--c.	Congestive Heart Failure: 44.56382978723404 old

select tri_name, avg(tri_age) as avg_age from Demographics a
inner JOIN
Conditions b
on
a.contactid=b.tri_patientid
where tri_name ='COPD' or tri_name='Hypertension' or tri_name='Congestive Heart Failure'
group by tri_name


-- 3.	How many Male and Female patients had Hypertension, COPD, and CHF?
-- a.	Hypertension: 179 males, 251 females
-- b.	COPD: 32 males, 29 females
-- c.	CHF: 32 males, 27 females

select tri_name, gendercode, count(gendercode) as num_gender from Demographics a
inner JOIN
Conditions b
on
a.contactid=b.tri_patientid
where tri_name ='COPD' or tri_name='Hypertension' or tri_name='Congestive Heart Failure'
group by tri_name, gendercode
