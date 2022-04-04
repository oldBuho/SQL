/*
dataset: 
https://console.cloud.google.com/marketplace/details/github/github-repos?filter=solution-type%3Adataset&filter=category%3Aencyclopedic&id=46ee22ab-2ca4-4750-81a7-3ee0f0150dcb

question:
What is the most popular language?
*/


WITH languages_count AS (
    SELECT 
        name, 
        COUNT(DISTINCT repo_name) as language_count
    FROM 
        `bigquery-public-data.github_repos.languages` 
    CROSS JOIN 
        UNNEST(language) as language_name
    GROUP BY 
        name
    ORDER BY 
        language_count DESC)

SELECT 
    name
FROM 
    languages_count
WHERE
    language_count = (SELECT MAX(language_count) FROM languages_count);


