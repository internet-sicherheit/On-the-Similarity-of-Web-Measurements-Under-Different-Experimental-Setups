-- Here we do the main data postprocessing operations (e.g. assigning tracking requests, defining scope, rank buckets etc.)

UPDATE
  `your-bigquery-data-set.diff.callstacks`
SET
  contains_url=( REGEXP_CONTAINS(call_stack, r'(http|https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?'))
WHERE
  TRUE;
  -- transferr trackign requests
UPDATE
  `your-bigquery-data-set.diff.tmp_requests` t1
SET
  is_tracker=(
  SELECT
    CAST(is_tracker AS int)
  FROM
    diff.tmp_requests_tracker t2
  WHERE
    t1.url=t2.url )
WHERE
  TRUE;
UPDATE
  diff.sites
SET
  in_scope=NULL
WHERE
  TRUE;
UPDATE
  diff.sites
SET
  in_scope=TRUE
WHERE
  state_openwpm_interaction_1=2
  AND state_openwpmheadless_interaction=2
  AND state_openwpm_interaction_old=2
  AND state_openwpm_desktop=2
  AND state_openwpm_interaction_2=2;
  # requests
UPDATE
  `your-bigquery-data-set.diff.requests` r
SET
  in_scope=NULL
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.requests` r
SET
  in_scope=1
WHERE
  (
  SELECT
    COUNT(*)
  FROM
    diff.sites s
  WHERE
    r.site_id=s.id
    AND in_scope=TRUE )>0;
UPDATE
  `your-bigquery-data-set.diff.requests` r
SET
  in_scope=0
WHERE
  in_scope IS NULL;
  # cookies
UPDATE
  `your-bigquery-data-set.diff.cookies` r
SET
  in_scope=NULL
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.cookies` r
SET
  in_scope=1
WHERE
  (
  SELECT
    COUNT(*)
  FROM
    diff.sites s
  WHERE
    r.site_id=s.id
    AND in_scope=TRUE )>0;
UPDATE
  `your-bigquery-data-set.diff.cookies` r
SET
  in_scope=0
WHERE
  in_scope IS NULL;
  # responses
UPDATE
  `your-bigquery-data-set.diff.responses` r
SET
  in_scope=NULL
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.responses` r
SET
  in_scope=1
WHERE
  (
  SELECT
    COUNT(*)
  FROM
    diff.sites s
  WHERE
    r.site_id=s.id
    AND in_scope=TRUE )>0;
UPDATE
  `your-bigquery-data-set.diff.responses` r
SET
  in_scope=0
WHERE
  in_scope IS NULL;
  # http_redirects
UPDATE
  `your-bigquery-data-set.diff.http_redirects` r
SET
  in_scope=NULL
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.http_redirects` r
SET
  in_scope=1
WHERE
  (
  SELECT
    COUNT(*)
  FROM
    diff.sites s
  WHERE
    CAST(r.site_id AS int64)=s.id
    AND in_scope=TRUE )>0;
UPDATE
  `your-bigquery-data-set.diff.http_redirects` r
SET
  in_scope=0
WHERE
  in_scope IS NULL;
  # callstacks
UPDATE
  `your-bigquery-data-set.diff.callstacks` r
SET
  in_scope=NULL
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.callstacks` r
SET
  in_scope=TRUE
WHERE
  (
  SELECT
    COUNT(*)
  FROM
    diff.sites s
  WHERE
    CAST(r.site_id AS int64)=s.id
    AND in_scope=TRUE )>0;
UPDATE
  `your-bigquery-data-set.diff.callstacks` r
SET
  in_scope=FALSE
WHERE
  in_scope IS NULL;
  # visits
UPDATE
  `your-bigquery-data-set.diff.visits` r
SET
  in_scope=NULL
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.visits` r
SET
  in_scope=TRUE
WHERE
  (
  SELECT
    COUNT(*)
  FROM
    diff.sites s
  WHERE
    CAST(r.site_id AS int64)=s.id
    AND in_scope=TRUE )>0;
UPDATE
  `your-bigquery-data-set.diff.visits` r
SET
  in_scope=FALSE
WHERE
  in_scope IS NULL;



  ALTER TABLE
  `diff.sites` ADD COLUMN
IF NOT EXISTS rank_bucket int;
UPDATE
  diff.sites
SET
  rank_bucket=0
WHERE
  rank<=5000;


UPDATE
  diff.sites
SET
  rank_bucket=5
WHERE
 rank>5000
  AND rank<=10000;


UPDATE
  diff.sites
SET
  rank_bucket=50
WHERE
 rank>10000
  AND rank<=50000;


UPDATE
  diff.sites
SET
  rank_bucket=250
WHERE
  rank>50000
  AND rank<=250000;
UPDATE
  diff.sites
SET
  rank_bucket=500
WHERE
  rank>250000
  AND rank<=500000;