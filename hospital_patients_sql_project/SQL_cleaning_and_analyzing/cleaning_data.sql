# Cleaning dataset

# To begin cleaning the data I first locate and delete any duplicates tables.

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY patient_id, first_name, last_name, age, gender, phone, email, department, diagnosis, treatment, admission_date, discharge_date, 'status', bill_amount) AS row_num
FROM patients
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `patients_staging` (
  `patient_id` text,
  `first_name` text,
  `last_name` text,
  `age` int DEFAULT NULL,
  `gender` text,
  `phone` text,
  `email` text,
  `department` text,
  `diagnosis` text,
  `treatment` text,
  `admission_date` text,
  `discharge_date` text,
  `status` text,
  `bill_amount` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO patients_staging
SELECT *,
ROW_NUMBER() OVER(PARTITION BY patient_id, first_name, last_name, age, gender, phone, email, department, diagnosis, treatment, admission_date, discharge_date, 'status', bill_amount) AS row_num
FROM patients;

DELETE
FROM patients_staging 
WHERE row_num > 1;

ALTER TABLE patients_staging
DROP COLUMN row_num;


# Now that the duplicates have been deleted, I want to standardize the data. The patients table has some formatting issues to fix.

SELECT *
FROM patients_staging;

SELECT DISTINCT(TRIM(diagnosis))
FROM patients_staging;

UPDATE patients_staging
SET diagnosis = TRIM(diagnosis);

SELECT DISTINCT department
FROM patients_staging;

SELECT department
FROM patients_staging 
WHERE department LIKE 'Ortho%'
GROUP BY department;

UPDATE patients_staging
SET department = 'Orthopedics'
WHERE department LIKE 'Ortho%';

SELECT DISTINCT treatment, TRIM(TRAILING '.' FROM treatment)
FROM patients_staging;

UPDATE patients_staging
SET treatment = TRIM(TRAILING '.' FROM treatment)
WHERE treatment LIKE 'Discharged%';

SELECT patient_ID, admission_date
FROM patients_staging;

SELECT admission_date, str_to_date(admission_date, '%m/%d/%Y')
FROM patients_staging
WHERE admission_date LIKE '%/%/%';

UPDATE patients_staging
SET admission_date = str_to_date(admission_date, '%m/%d/%Y')
WHERE admission_date LIKE '%/%/%';

UPDATE patients_staging
SET discharge_date = str_to_date(discharge_date, '%m/%d/%Y')
WHERE discharge_date LIKE '%/%/%';

ALTER TABLE patients_staging
MODIFY COLUMN admission_date DATE,
MODIFY COLUMN discharge_date DATE;

SELECT *
FROM patients_staging
WHERE patient_id IS NULL OR ' ';



