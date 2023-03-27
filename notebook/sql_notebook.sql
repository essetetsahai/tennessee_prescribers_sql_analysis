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

--OR--

SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescription
INNER JOIN prescriber
USING(npi)
INNER JOIN
(
SELECT DISTINCT drug_name,
	opioid_drug_flag
FROM drug
) sub
USING(drug_name)
WHERE opioid_drug_flag = 'Y'
	
GROUP BY specialty_description
ORDER BY total_claims DESC;





-- 2c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?


SELECT specialty_description, COUNT(total_claim_count)
FROM prescriber
LEFT JOIN prescription
USING(npi)
GROUP BY specialty_description
HAVING COUNT(total_claim_count) = 0;


--OR--
(
SELECT DISTINCT specialty_description
FROM prescriber
)
EXCEPT
(
SELECT DISTINCT specialty_description
FROM prescriber
INNER JOIN prescription
USING(npi)
);
---OR---
SELECT DISTINCT specialty_description  
FROM prescriber
WHERE specialty_description NOT IN
		(
			select distinct specialty_description  
			from prescriber pr
			inner join prescription pn 
			on pr.npi= pn.npi 
		)
ORDER BY specialty_description;


-- d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids? 

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
	ELSE 'neither' END AS drug_type
	
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


--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. 
--   Hint: The results from all 3 parts will have 637 rows.

--a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') 
-- 	 in the city of Nashville (nppes_provider_city = 'NASHVILLE'), 
--   where the drug is an opioid (opiod_drug_flag = 'Y'). 
--   Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

------------------------------------------------
------DONT USE--------
-- SELECT pr.npi  , drug.drug_name
-- FROM prescriber AS pr
-- -- INNER JOIN (SELECT npi, drug_name FROM prescription) AS pn
-- -- USING(npi)
-- CROSS JOIN drug 
-- -- INNER JOIN drug AS drg
-- -- USING(drug_name)
-- WHERE specialty_description = 'Pain Management'
-- AND pr.nppes_provider_city = 'NASHVILLE'
-- AND opioid_drug_flag = 'Y';
-------------------------------------------------
SELECT drug_name
FROM drug
WHERE opioid_drug_flag = 'Y'


SELECT pr.npi,  drug.drug_name
FROM prescriber AS pr

CROSS JOIN drug 

WHERE specialty_description = 'Pain Management'
AND pr.nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';





-- b. Next, report the number of claims per drug per prescriber. 
--    Be sure to include all combinations, whether or not the prescriber had any claims. 
--    You should report the npi, the drug name, and the number of claims (total_claim_count).
-- c. Fill in any missing values for total_claim_count with 0.

SELECT pr.npi  , drug.drug_name, COALESCE(total_claim_count,0)
FROM prescriber AS pr

CROSS JOIN drug 

FULL JOIN prescription USING(npi, drug_name)

WHERE specialty_description = 'Pain Management'
AND pr.nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';


 
---------------------------------------------

---PART TWO----

-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?

SELECT COUNT(DISTINCT npi)
FROM prescriber
WHERE NOT EXISTS (SELECT npi FROM prescription WHERE npi = prescriber.npi);

--There are 4,458 npi numbers in prescriber not in prescription table

-- 2.
--     a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

SELECT drug.generic_name, SUM(total_claim_count) AS total
FROM drug

INNER JOIN prescription ptn
USING(drug_name)

INNER JOIN prescriber pbr
USING(npi)

WHERE specialty_description ='Family Practice'
GROUP BY generic_name
ORDER BY total DESC
LIMIT 5;

--"LEVOTHYROXINE SODIUM", "LISINOPRIL", "ATORVASTATIN CALCIUM"...


--     b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT drug.generic_name, SUM(total_claim_count) AS total
FROM drug

INNER JOIN prescription ptn
USING(drug_name)

INNER JOIN prescriber pbr
USING(npi)

WHERE specialty_description ='Cardiology'
GROUP BY generic_name
ORDER BY total DESC
LIMIT 5;

--"ATORVASTATIN CALCIUM", "CARVEDILOL"...

--     c. Which drugs appear in the top five prescribed for both Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.

SELECT fam.generic AS Fam_practice_drug, 
		fam.total AS Total, 
		cardi.generic AS Cardio_drug, 
		cardi.total AS Total
FROM (SELECT drug.generic_name AS generic, SUM(total_claim_count) AS total
		FROM drug

		INNER JOIN prescription ptn
		USING(drug_name)

		INNER JOIN prescriber pbr
		USING(npi)

		WHERE specialty_description ='Family Practice'
		GROUP BY generic_name
		ORDER BY total DESC
		LIMIT 5) AS fam
INNER JOIN (SELECT drug.generic_name AS generic, SUM(total_claim_count) AS total
			FROM drug

			INNER JOIN prescription ptn
			USING(drug_name)

			INNER JOIN prescriber pbr
			USING(npi)

			WHERE specialty_description ='Cardiology' 

			GROUP BY generic_name
			ORDER BY total DESC
			LIMIT 5) AS cardi
USING(generic);




-- Generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.

--     Top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs: Report the npi, the total number of claims, and city.


SELECT pbr.npi, pbr.nppes_provider_city,  ptn.total_claims AS total_claims
FROM prescriber AS pbr
INNER JOIN (SELECT npi, SUM(total_claim_count) AS total_claims
			FROM prescription
			GROUP BY npi
			ORDER BY total_claims DESC) AS ptn
USING(npi)
WHERE nppes_provider_city = 'NASHVILLE'
ORDER BY total_claims DESC
LIMIT 5;


--     b. Memphis.
SELECT pbr.npi, pbr.nppes_provider_city,  ptn.total_claims AS total_claims
FROM prescriber AS pbr
INNER JOIN (SELECT npi, SUM(total_claim_count) AS total_claims
			FROM prescription
			GROUP BY npi
			ORDER BY total_claims DESC) AS ptn
USING(npi)
WHERE nppes_provider_city = 'MEMPHIS'
ORDER BY total_claims DESC
LIMIT 5;

--     c. Combine data for Nashville, Memphis, Knoxville and Chattanooga.

(SELECT pbr.npi, pbr.nppes_provider_city,  ptn.total_claims AS total_claims
FROM prescriber AS pbr
INNER JOIN (SELECT npi, SUM(total_claim_count) AS total_claims
			FROM prescription
			GROUP BY npi
			ORDER BY total_claims DESC) AS ptn
USING(npi)
WHERE nppes_provider_city = 'NASHVILLE'
ORDER BY total_claims DESC
LIMIT 5)
UNION
(SELECT pbr.npi, pbr.nppes_provider_city,  ptn.total_claims AS total_claims
FROM prescriber AS pbr
INNER JOIN (SELECT npi, SUM(total_claim_count) AS total_claims
			FROM prescription
			GROUP BY npi
			ORDER BY total_claims DESC) AS ptn
USING(npi)
WHERE nppes_provider_city = 'MEMPHIS'
ORDER BY total_claims DESC
LIMIT 5)
UNION
(SELECT pbr.npi, pbr.nppes_provider_city,  ptn.total_claims AS total_claims
FROM prescriber AS pbr
INNER JOIN (SELECT npi, SUM(total_claim_count) AS total_claims
			FROM prescription
			GROUP BY npi
			ORDER BY total_claims DESC) AS ptn
USING(npi)
WHERE nppes_provider_city LIKE 'CHAT%'
ORDER BY total_claims DESC
LIMIT 5)
UNION
(SELECT pbr.npi, pbr.nppes_provider_city,  ptn.total_claims AS total_claims
FROM prescriber AS pbr
INNER JOIN (SELECT npi, SUM(total_claim_count) AS total_claims
			FROM prescription
			GROUP BY npi
			ORDER BY total_claims DESC) AS ptn
USING(npi)
WHERE nppes_provider_city = 'KNOXVILLE'
ORDER BY total_claims DESC
LIMIT 5)
ORDER BY nppes_provider_city, total_claims DESC;












