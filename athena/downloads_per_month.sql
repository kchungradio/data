-- count downloads by month, grouping by ip, agent, key (unique visitor per file)
SELECT month, count(*) AS downloads
FROM
    (SELECT RemoteIp,
            UserAgent,
            Key,
            SUBSTRING(RequestDateTime, 4, 8) AS month -- Mmm/YYYY
    FROM "s3_access_logs"."radio_archive_20191109"
    WHERE (lower(key) LIKE '%.mp3' OR lower(key) LIKE '%.wav') -- audio file
      AND regexp_like(RequestURI_operation, 'GET|HEAD') -- GET request
      AND Requester LIKE '-' -- not from aws user
      AND NOT regexp_like(UserAgent, 'Elastic|aws') -- not from aws console
      AND RemoteIp NOT LIKE '172.31%' -- not from inside aws
      AND HttpStatus LIKE '2%' -- successful http request
    GROUP BY  1, 2, 3, 4)
GROUP BY  1
ORDER BY date_parse(month, '%b/%Y') ASC;
