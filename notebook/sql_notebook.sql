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


-- 1. b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.



