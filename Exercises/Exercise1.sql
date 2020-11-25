-- 1.	Find the data types for each table Demographics, PhoneCall, Phonecall_Encounters,Conditions

-- Demographics: nvarchar and float
-- PhoneCall: varchar 
--Phonecall_Encounters,Conditions: nvarchar and float

-- 2.	How do we fix this error? Conversion failed when converting the nvarchar value 'NULL' to data type int.
select * from Demographics where try_convert(int,gendercode)=2

--OR

select try_convert(int,gendercode) from Demographics where try_convert(int,gendercode)=2

-- 3.	How do we fix this error permanently?

-- Create a new column of values as integers, update the table

alter table table_name
add column_name int
update table_name
set column_name = values
