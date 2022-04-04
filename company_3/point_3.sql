/*
dataset: 
https://console.cloud.google.com/marketplace/details/github/github-repos?filter=solution-type%3Adataset&filter=category%3Aencyclopedic&id=46ee22ab-2ca4-4750-81a7-3ee0f0150dcb

question:
What is the repository with the most copies?
*/

WITH repo_copies AS (
    SELECT
        f.repo_name,
        SUM(c.copies) AS sum_copies
    FROM 
        `bigquery-public-data.github_repos.files`  AS f
    INNER JOIN 
        `bigquery-public-data.github_repos.contents`  AS c
        ON f.id = c.id
    GROUP BY
        f.repo_name)

SELECT
    repo_name
FROM 
    repo_copies
WHERE sum_copies = (SELECT MAX(sum_copies) FROM repo_copies);