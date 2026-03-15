# Exploratory Data Analysis

SELECT *
FROM patients_staging;

# How many patients are there in the dataset?

SELECT COUNT(*) as num_of_patients
FROM patients_staging;

# What are the different departments in the hospital?

SELECT DISTINCT department
FROM patients_staging;

# Which patients are currently under treatment?

SELECT patient_id, first_name, last_name
FROM patients_staging
WHERE status = 'Under Treatment';

# How many patients had each diagnosis?

SELECT diagnosis, COUNT(diagnosis) as num_of_diagnosis
FROM patients_staging
GROUP BY diagnosis
ORDER BY num_of_diagnosis DESC;

# Get all the patients who had the most common diagnosis.

SELECT *
FROM patients_staging
WHERE diagnosis = 'Fracture';

# What's the average bill amount and total bill amount per department?

SELECT department, 
ROUND(AVG(bill_amount), 0) as average_bill, 
ROUND(SUM(bill_amount), 0) as total_bill
FROM patients_staging
GROUP BY department
ORDER BY total_bill DESC;

# How many patients were admitted each year?

SELECT YEAR(admission_date) as year, COUNT(patient_id) as admitted_patients
FROM patients_staging
GROUP by YEAR(admission_date)
ORDER BY year ASC;

# How many patients were admitted each month in 2024?
SELECT SUBSTRING(admission_date,1,7) as month,
COUNT(*) as admitted_paients
FROM patients_staging
WHERE SUBSTRING(admission_date,1,7) IS NOT NULL
	AND SUBSTRING(admission_date,1,4) = '2024'
GROUP BY month
ORDER BY month ASC;

# Show the rolling total of patients admitted by month in 2024.

WITH rolling_total AS
(
SELECT SUBSTRING(admission_date,1,7) as month,
COUNT(*) as admitted_patients
FROM patients_staging
WHERE SUBSTRING(admission_date,1,7) IS NOT NULL
	AND SUBSTRING(admission_date,1,4) = '2024'
GROUP BY month
ORDER BY month ASC
)
SELECT month, admitted_patients, SUM(admitted_patients) OVER(ORDER BY month) as rolling_total
FROM rolling_total;

# What day were most patients admitted?

SELECT admission_date, COUNT(patient_id) as admitted_patients
FROM patients_staging
GROUP BY admission_date
ORDER BY admitted_patients DESC
LIMIT 1;

# On the day that most patients were admitted, what was the most common diagnosis?

SELECT diagnosis, COUNT(diagnosis) as num_of_diagnosis
FROM patients_staging
WHERE admission_date = '2025-01-09'
GROUP BY diagnosis
ORDER BY num_of_diagnosis DESC;

# List the patients who were discharged after January 1, 2025.

SELECT patient_id, first_name, last_name
FROM patients_staging
WHERE admission_date > '2025-01-01';

# Calculate the average age of patients receiving each type of treatment.

SELECT diagnosis, AVG(age) as average_age
FROM patients_staging
GROUP BY diagnosis;

# What is the average age of patients by gender?

SELECT gender, AVG(age) as average_age
FROM patients_staging
GROUP BY gender;

# Who are the youngest and oldest patients?

SELECT patient_id, first_name, last_name, age
FROM patients_staging
WHERE age = (SELECT MAX(age) FROM patients)
OR age = (SELECT MIN(age) FROM patients)
ORDER BY age;

# Find the top 5 patients with the highest bill amounts. Include the patient_id, full name and bill_amount.

SELECT patient_id, CONCAT(first_name,' ',last_name), bill_amount
FROM patients_staging
ORDER BY bill_amount DESC
LIMIT 5;

# What percentage of patients were male vs female vs other?

SELECT gender,
ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER (),2) AS percentage
FROM patients_staging
GROUP by gender;

# Find number of patients each department saw in each year.

SELECT department, YEAR(admission_date) AS years, COUNT(patient_id) as patients_seen
FROM patients_staging
GROUP BY department, years
ORDER BY years asc, department;

# Rank departments based on how many patients they saw each year. Only show the top 5 departments for each year.
WITH hospital_year AS
(
SELECT department, YEAR(admission_date) AS years, COUNT(patient_id) AS patients_seen
FROM patients_staging
GROUP BY department, years
ORDER BY years asc, department
), department_year_rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY patients_seen desc) as ranking
FROM hospital_year
ORDER BY ranking asc
)
SELECT *
FROM department_year_rank
WHERE ranking <= 5;

# What is the average length of stay for patients?

SELECT AVG(DATEDIFF(discharge_date, admission_date)) as avg_days_in_hospital
FROM patients_staging;

# Which department has the longest average patient stay?

SELECT department, AVG(DATEDIFF(discharge_date, admission_date)) as avg_days_in_hospital
FROM patients_staging
WHERE discharge_date IS NOT NULL
GROUP BY department
ORDER BY avg_days_in_hospital desc;

# Which age group has the highest hospital bills?

SELECT
CASE
	WHEN age < 18 THEN '0-17'
	WHEN age BETWEEN 18 AND 35 THEN '18-35'
    WHEN age BETWEEN 36 AND 55 THEN '36-55'
    WHEN age BETWEEN 56 AND 75 THEN '56-75'
    ELSE '76+'
END age_group,
AVG(bill_amount) as avg_bill
FROM patients_staging
GROUP BY age_group
ORDER BY avg_bill desc;




