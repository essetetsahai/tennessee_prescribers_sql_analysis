SELECT *
FROM prescriber
LIMIT 5;

SELECT *
FROM prescription
LIMIT 5;


-- 1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, SUM(total_claim_count) AS Sum_of_total_claim_ct
FROM prescription
GROUP BY npi
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;
--Ans: npi ...4483 has the highest sum of total claim count(99,707).


-- 1.Report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.



SELECT pber.npi, nppes_provider_first_name AS First, nppes_provider_last_org_name AS Last, specialty_description, total_claim
FROM prescriber AS pber

INNER JOIN (SELECT npi, SUM(total_claim_count) AS total_claim 
			FROM prescription 
			GROUP BY npi) AS claims
USING (npi)

ORDER BY total_claim DESC
LIMIT 5;

--Bruce Pendley, Famil Practice, has the most number of claims.


--2. a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim_count)
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;

--Family Practice had the most number of claims (9,752,347).


--2. b. Which specialty had the most total number of claims for opioids?

SELECT specialty_description,drug.opioid_drug_flag, SUM(total_claim_count)
FROM prescriber
INNER JOIN prescription
USING(npi)
INNER JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description, drug.opioid_drug_flag
ORDER BY SUM(total_claim_count) DESC
LIMIT 3;

--Nurse Practitioner has the most total number of claims for opioids (900,845).



--3. a. Which drug (generic_name) had the highest total drug cost?

SELECT drug.generic_name, SUM(prescription.total_drug_cost) AS total
FROM drug
INNER JOIN prescription
USING(drug_name)
GROUP BY generic_name
ORDER BY total DESC
LIMIT 3;

-- "INSULIN GLARGINE,HUM.REC.ANLOG" has the higest total drug cost (104,264,066.35).


--3 b. Which drug (generic_name) has the hightest total cost per day? 
--	   Bonus: Round your cost per day column to 2 decimal places. 

SELECT drug.generic_name, 
	   ROUND((SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply)), 2) AS per_day_cost
FROM drug
INNER JOIN prescription
USING(drug_name)
GROUP BY generic_name
ORDER BY per_day_cost DESC
LIMIT 3;

-- "C1 ESTERASE INHIBITOR" has the highest cost per day ($3495.22).


--4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' 
--   which says 'opioid' for drugs which have opioid_drug_flag = 'Y', 
--   says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', 
--   and says 'neither' for all other drugs.

SELECT
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type,
	
FROM drug;

--4. b. Determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
--	 Hint: Format the total costs as MONEY for easier comparision.

SELECT
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type,
	SUM(total_drug_cost::MONEY) AS total
FROM drug
INNER JOIN prescription
USING(drug_name)
GROUP BY drug_type
ORDER BY total DESC;

--More was spent on opioids ($105,080,626.37) than antibiotics($38,435,121.26).


--5. a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

SELECT DISTINCT cbsaname
FROM cbsa
WHERE fipscounty LIKE '47%'

--There are 10 CBSAs in Tennessee.


--b. Which cbsa has the largest combined population? 
--   Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname, SUM(population) AS total_population
FROM cbsa
INNER JOIN population
USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_population DESC;

-- "Nashville-Davidson--Murfreesboro--Franklin, TN" has the higehest population (1,830,410).
-- "Morristown, TN" has the smallest population (116,352).


--c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT county, SUM(population) AS total_popln
FROM population

FULL JOIN cbsa
USING(fipscounty)

FULL JOIN fips_county
USING(fipscounty)

WHERE cbsaname IS NULL 
		AND population IS NOT NULL
GROUP BY county
ORDER BY total_popln DESC
LIMIT 3;

--SEVIER county is the largest county not included in CBSA (95,523)


--6 a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000
ORDER BY total_claim_count;


-- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT prescription.drug_name, total_claim_count, opioid_drug_flag
FROM prescription

LEFT JOIN drug
USING(drug_name)

WHERE total_claim_count >= 3000
ORDER BY total_claim_count;

--Two drugs have opioid drug flag (hydrocodone-acetaminophen and oxycodone hcl)

-- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT prescription.drug_name, total_claim_count, opioid_drug_flag, nppes_provider_first_name AS First, nppes_provider_last_org_name AS Last
FROM prescription

LEFT JOIN drug
USING(drug_name)

LEFT JOIN prescriber
USING(npi)

WHERE total_claim_count >= 3000
ORDER BY total_claim_count;

--David Coffey has the highest total claim count with oxycodone hcl.


