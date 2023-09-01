-- Here we create the tree structure for the requests


CREATE OR REPLACE TABLE
  diff.tmp_requests AS
SELECT
  *,
  CONCAT(r.browser_id,'-',r.visit_id) browser_visit
FROM
  diff.requests r
WHERE
  in_scope =1;
CREATE OR REPLACE TABLE
  diff.tmp_callstacks AS
SELECT
  *,
  CONCAT(r.browser_id,'-',r.visit_id) browser_visit
FROM
  diff.callstacks r
WHERE
  in_scope=TRUE;
  -- step 0: extract calls from callstack
CREATE OR REPLACE TABLE
  diff.tmp_callstack_js AS
SELECT
  *,
  CONCAT(browser_id,'-',visit_id) browser_visit,
  ROW_NUMBER() OVER() row_number1,
  SPLIT(parents,',||parent||@') parrent_array
FROM (
  SELECT
    DISTINCT SPLIT(SPLIT(url_delimeter, '||:delimeter:||@')[
    OFFSET
      (1)],'||:parents:||')[
  OFFSET
    (0)] AS url,
    CAST(SPLIT(url_delimeter, '||:delimeter:||@')[
    OFFSET
      (0)] AS int64) AS parent_seq,
    SPLIT(url_delimeter, '||:parents:||')[
  OFFSET
    (1)] AS parents,
    *
  FROM (
    SELECT
      CAST(request_id AS int64) AS fired_request_id,
      -1 AS request_id,
      -1 AS parent_request_id,
      pr AS url_delimeter,
      visit_id,
      site_id,
      subpage_id,
      browser_id,
      call_stack
    FROM (
      SELECT
        diff.fc_extractCallStack(call_stack) AS parent,
        visit_id,
        site_id,
        subpage_id,
        browser_id,
        request_id,
        call_stack
      FROM
        diff.tmp_callstacks
      WHERE
        contains_url IS TRUE )
    CROSS JOIN
      UNNEST( parent) AS pr));
CREATE OR REPLACE TABLE
  diff.tmp_callstack_js AS
SELECT
  *,
  REPLACE(parent,'||parent||@','') AS parent_url
FROM
  diff.tmp_callstack_js,
  UNNEST(parrent_array) parent;
  -- step 2.1 assign global uniq request id
CREATE OR REPLACE TABLE
  diff.tmp_requests AS
SELECT
  *,
  ROW_NUMBER() OVER(ORDER BY time_stamp, request_id) AS global_uniq_id
FROM
  `diff.tmp_requests`
ORDER BY
  time_stamp ASC ;
  --step 2.2.1 assign parent_url_global_id
ALTER TABLE
  `diff.tmp_callstack_js` ADD COLUMN
IF NOT EXISTS parent_url_global_id int64;
UPDATE
  diff.tmp_callstack_js c
SET
  parent_url_global_id=(
  SELECT
    MIN(global_uniq_id)
  FROM
    diff.tmp_requests r
  WHERE
    c.browser_id=r.browser_id
    AND c.visit_id=r.visit_id
    AND c.parent_url=r.url
    AND r.request_id<c.fired_request_id)
WHERE
  TRUE;
  -- step 2.2 assign global_uniq_id to callstacks
ALTER TABLE
  `diff.tmp_callstack_js` ADD COLUMN
IF NOT EXISTS global_uniq_id int64;
UPDATE
  diff.tmp_callstack_js c
SET
  global_uniq_id=(
  SELECT
    MIN(global_uniq_id)
  FROM
    diff.tmp_requests r
  WHERE
    c.browser_id=r.browser_id
    AND c.visit_id=r.visit_id
    AND c.url=r.url
    AND r.request_id<c.fired_request_id)
WHERE
  TRUE;
  -- step 2.3 assign original request id to callstacks
UPDATE
  `your-bigquery-data-set.diff.tmp_callstack_js` c2
SET
  request_id= ( -- this is the new request_id (org. request id is now fired_*)
  SELECT
    MIN(request_id)
  FROM
    diff.tmp_requests c
  WHERE
    c2.url=c.url
    AND c2.browser_id=c.browser_id
    AND c.visit_id=c2.visit_id
    AND CAST(c2.fired_request_id AS int64)>c.request_id)
WHERE
  TRUE;
  --step 3 assign parent id in callstacks
UPDATE
  `your-bigquery-data-set.diff.tmp_callstack_js` c1
SET
  parent_request_id= (
  SELECT
    MIN(global_uniq_id)
  FROM
    diff.tmp_callstack_js c2
  WHERE
    c1.visit_id=c2.visit_id
    AND c1.browser_id=c2.browser_id
    AND c1.fired_request_id=c2.fired_request_id
    AND c1.global_uniq_id>c2.global_uniq_id
    AND c2.global_uniq_id IS NOT NULL
    AND c1.global_uniq_id IS NOT NULL )
WHERE
  browser_id='openwpm_interaction_2'
  AND visit_id='3_0' ; /* old method
UPDATE
  `your-bigquery-data-set.diff.tmp_callstack_js` c2
SET
  parent_request_id= (
  SELECT
    c.request_id
  FROM (
    SELECT
      MAX(global_uniq_id) AS q_parent_seq
    FROM
      diff.tmp_callstack_js c
    WHERE
      --c2.fired_request_id=c.fired_request_id
      c2.fired_request_id=c.fired_request_id
      AND c.visit_id=c2.visit_id
      AND c2.browser_id = c.browser_id
      --AND c2.parent_seq > c.parent_seq
      AND c2.global_uniq_id > c.global_uniq_id
      AND (request_id IS NOT NULL
        OR request_id !=-1) )
  INNER JOIN
    diff.tmp_callstack_js c 
  ON
    c2.browser_id=c.browser_id
    AND c2.fired_request_id=c.fired_request_id
    AND c.visit_id=c2.visit_id
  WHERE
    c.global_uniq_id=c2.global_uniq_id )
WHERE
  TRUE;
*/
  # find not_identifiables
  -- step 3.9 assign fired_request_id_global
ALTER TABLE
  `diff.tmp_callstack_js` ADD COLUMN
IF NOT EXISTS fired_request_id_global int64;
UPDATE
  diff.tmp_callstack_js c
SET
  fired_request_id_global= (
  SELECT
    MIN(global_uniq_id)
  FROM
    diff.tmp_requests r
  WHERE
    c.browser_id=r.browser_id
    AND c.visit_id=r.visit_id
    AND c.fired_request_id = r.request_id )
WHERE
  TRUE;
  -- 3.10 farm url_hash
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS url_hash int64;
UPDATE
  diff.tmp_requests
SET
  url_hash = FARM_FINGERPRINT(url)
WHERE
  TRUE;
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS is_root boolean;
UPDATE
  diff.tmp_requests
SET
  is_root = TRUE
WHERE
  global_uniq_id IN (
  SELECT
    MIN(global_uniq_id)
  FROM
    `your-bigquery-data-set.diff.tmp_requests`
  GROUP BY
    browser_visit);
UPDATE
  diff.tmp_requests
SET
  is_root = FALSE
WHERE
  is_root IS NULL;
  -- determine root frame
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS is_root_frame boolean;
UPDATE
  diff.tmp_requests
SET
  is_root_frame = TRUE
WHERE
  global_uniq_id IN (
  SELECT
    MIN(global_uniq_id)
  FROM
    `your-bigquery-data-set.diff.tmp_requests`
  WHERE
    resource_type ='sub_frame'
  GROUP BY
    browser_visit,
    frame_id );
UPDATE
  diff.tmp_requests
SET
  is_root_frame = FALSE
WHERE
  is_root_frame IS NULL;
  -- step 4 create required columns
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS parent_1_inside_callstack string;
ALTER TABLE
  `diff.tmp_callstack_js` ADD COLUMN
IF NOT EXISTS not_identifiable boolean;
UPDATE
  diff.tmp_callstack_js
SET
  not_identifiable = TRUE
WHERE
  (parent_request_id IS NULL
    AND parent_seq != 0)
  OR request_id IS NULL ;
  -- step 5 transfer parents infos to main table.
  -- assign global_uniq_id for fired calls
UPDATE
  diff.tmp_requests AS r
SET
  parent_1_inside_callstack= (
  SELECT
    STRING_AGG(CAST(parent_url_global_id AS string))
  FROM (
    SELECT
      DISTINCT parent_url_global_id -- OLD method: parent_request_id
    FROM
      diff.tmp_callstack_js AS c
    WHERE
      c.global_uniq_id=r.global_uniq_id ))
WHERE
  TRUE;
  -- assign parent_2_final_call
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS parent_2_final_call string;
UPDATE
  diff.tmp_requests r
SET
  parent_2_final_call =(
  SELECT
    STRING_AGG(CAST(c.global_uniq_id AS string))
  FROM (
    SELECT
      DISTINCT global_uniq_id
    FROM
      diff.tmp_callstack_js
    WHERE
      parent_seq=0
      AND fired_request_id_global=r.global_uniq_id ) c )
WHERE
  TRUE;
  -- step 5.3 assign parent_3_redirect for redirects
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS parent_3_redirect string;
UPDATE
  `your-bigquery-data-set.diff.tmp_requests` r1
SET
  parent_3_redirect= (
  SELECT
    CAST(MAX(global_uniq_id) AS string)
  FROM
    `your-bigquery-data-set.diff.tmp_requests` r2
  WHERE
    r1.browser_visit=r2.browser_visit
    AND r1.request_id=r2.request_id
    AND r1.global_uniq_id != r2.global_uniq_id
    AND r1.global_uniq_id>r2.global_uniq_id )
WHERE
  TRUE;
  -- assign parents for root nodes in frame
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS parent_4_frame_root string;
UPDATE
  diff.tmp_requests r1
SET
  parent_4_frame_root =(
  SELECT
    CAST(MIN(global_uniq_id) AS string)
  FROM
    diff.tmp_requests r2
  WHERE
    r1.browser_visit = r2.browser_visit
    AND r1.parent_frame_id=r2.frame_id )
WHERE
  parent_frame_id!=-1
  AND is_root_frame=TRUE;
  -- step 6 concat all parents
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS parent_all string;
UPDATE
  diff.tmp_requests r1
SET
  parent_all=(
  SELECT
    CASE
      WHEN parent = '' THEN NULL
    ELSE
    parent
  END
    parent
  FROM (
    SELECT
      REPLACE(REPLACE(CONCAT( /*ifnull(parent_1_inside_callstack,
              ''),',',*/ifnull(parent_2_final_call,
              ''),',',ifnull(parent_3_redirect,
              ''),',',ifnull(parent_4_frame_root,
              '') ),',,',','),',,',',') AS parent
    FROM
      diff.tmp_requests r2
    WHERE
      r1.global_uniq_id=r2.global_uniq_id ))
WHERE
  TRUE;
UPDATE
  diff.tmp_requests
SET
  parent_all = SUBSTR(parent_all,2)
WHERE
  parent_all LIKE ',%';
UPDATE
  diff.tmp_requests
SET
  parent_all = SUBSTR(parent_all,1, LENGTH(parent_all)-1)
WHERE
  parent_all LIKE '%,';
  -- step 6 assign 1st level nodes TO the parents
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS parent_5_1st_level string;
UPDATE
  diff.tmp_requests r1
SET
  parent_5_1st_level =(
  SELECT
    CAST(MIN(global_uniq_id) AS string)
  FROM
    diff.tmp_requests r2
  WHERE
    r1.frame_id=r2.frame_id
    AND r1.browser_visit=r2.browser_visit)
WHERE
  (parent_all IS NULL
    OR parent_all='')
  AND is_root IS FALSE
  AND is_root_frame IS FALSE;
  -- depth FOR 1st levels
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS tree_depth int64;
UPDATE
  diff.tmp_requests
SET
  tree_depth = 1
WHERE
  parent_5_1st_level IS NOT NULL
  AND parent_frame_id=-1;
  -- concat all parents
UPDATE
  diff.tmp_requests r1
SET
  parent_all=(
  SELECT
    CASE
      WHEN parent = '' THEN NULL
    ELSE
    parent
  END
    parent
  FROM (
    SELECT
      REPLACE(REPLACE(CONCAT(/*ifnull(parent_1_inside_callstack,
              ''),',',*/ifnull(parent_2_final_call,
              ''),',',ifnull(parent_3_redirect,
              ''),',',ifnull(parent_4_frame_root,
              # We do not need this, because root_frame is depends via parent_5_1st_level to its parent # Uncommented! WE NEED IT!
              ''),',',ifnull(parent_5_1st_level,
              '') ),',,',','),',,','') AS parent
    FROM
      diff.tmp_requests r2
    WHERE
      r1.global_uniq_id=r2.global_uniq_id ))
WHERE
  TRUE;
UPDATE
  diff.tmp_requests
SET
  parent_all = SUBSTR(parent_all,2)
WHERE
  parent_all LIKE ',%';
UPDATE
  diff.tmp_requests
SET
  parent_all = SUBSTR(parent_all,1, LENGTH(parent_all)-1)
WHERE
  parent_all LIKE '%,';
UPDATE
  diff.tmp_requests
SET
  parent_all = SUBSTR(parent_all,1, LENGTH(parent_all)-1)
WHERE
  parent_all LIKE '%,';
  -- create parents as array
CREATE OR REPLACE TABLE
  diff.tmp_requests AS
SELECT
  *,
  SPLIT(parent_all) AS parent_array
FROM
  diff.tmp_requests;
  -- step 8 url_scope & tree_url_hash
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS url_scope_noQuery string;
UPDATE
  diff.tmp_requests AS r
SET
  url_scope_noQuery= SPLIT(url,'?')[
OFFSET
  (0)]
WHERE
  TRUE;
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS url_scope string;
UPDATE
  diff.tmp_requests
SET
  url_scope= diff.fc_cleanQueryString(url)
WHERE
  TRUE;
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS tree_url_hash int64;
UPDATE
  diff.tmp_requests
SET
  tree_url_hash = FARM_FINGERPRINT(url_scope)
WHERE
  TRUE;

  --step 9 is_ssl

  ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS is_https bool;
UPDATE
  diff.tmp_requests
SET
  is_https=TRUE
WHERE
  url LIKE 'https%';
UPDATE
  diff.tmp_requests
SET
  is_https=FALSE
WHERE
  is_https IS NULL;


-- dns values 
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS dns STRUCT< addresses string,
  used_address string,
  canonical_name string,
  is_TRR int,
  cdn string  >;
UPDATE
  diff.tmp_requests t1
SET
  dns.addresses= (
  SELECT
    addresses
  FROM
    diff.tmp_dns_responses t2
  WHERE
    t1.request_id=t2.request_id
    AND t1.browser_visit=t2.browser_visit
    AND t2.time_stamp>t1.time_stamp ),
  dns.used_address= (
  SELECT
    used_address
  FROM
    diff.tmp_dns_responses t2
  WHERE
    t1.request_id=t2.request_id
    AND t1.browser_visit=t2.browser_visit
    AND t2.time_stamp>t1.time_stamp ),
  dns.canonical_name= (
  SELECT
    canonical_name
  FROM
    diff.tmp_dns_responses t2
  WHERE
    t1.request_id=t2.request_id
    AND t1.browser_visit=t2.browser_visit
    AND t2.time_stamp>t1.time_stamp ),
  dns.is_TRR= (
  SELECT
    is_TRR
  FROM
    diff.tmp_dns_responses t2
  WHERE
    t1.request_id=t2.request_id
    AND t1.browser_visit=t2.browser_visit
    AND t2.time_stamp>t1.time_stamp ),
  dns.cdn= (
  SELECT
    diff.fc_cdnProvider(canonical_name)
  FROM
    diff.tmp_dns_responses t2
  WHERE
    t1.request_id=t2.request_id
    AND t1.browser_visit=t2.browser_visit
    AND t2.time_stamp>t1.time_stamp ) 
WHERE
  TRUE;
  
  #################################################### TREE CREATION
  ##################################### TREE BY PARENT
  /* convert ARRAY TO COLUMNS
  AND CREATE tree_parent */
CREATE OR REPLACE TABLE
  diff.tree_by_parent AS
SELECT
  browser_visit,
  site_id,
  visit_id,
  browser_id,
  global_uniq_id,
  tree_url_hash,
  CASE parent
    WHEN "" THEN NULL
  ELSE
  CAST(parent AS int)
END
  AS parent,
  0 parent_url_hash,
  0 tree_depth,
  is_root,
  is_root_frame,
  frame_id
FROM
  diff.tmp_requests,
  UNNEST(parent_array) parent;
  -- insert is_root
INSERT INTO
  diff.tree_by_parent
SELECT
  browser_visit,
  site_id,
  visit_id,
  browser_id,
  global_uniq_id,
  tree_url_hash,
  NULL parent,
  NULL parent_url_hash,
  0 tree_depth,
  is_root,
  is_root_frame,
  frame_id
FROM
  diff.tmp_requests
WHERE
  is_root IS TRUE;
  ##################################### TREE BY CHILDREN
ALTER TABLE
  `diff.tmp_requests` ADD COLUMN
IF NOT EXISTS children string;
UPDATE
  diff.tmp_requests req
SET
  children=(
  SELECT
    STRING_AGG(CAST(z.global_uniq_id AS string))
  FROM (
    SELECT
      DISTINCT CAST(global_uniq_id AS string) AS global_uniq_id
    FROM
      diff.tree_by_parent tree
    WHERE
      req.browser_visit=tree.browser_visit
      AND req.global_uniq_id = CAST(tree.parent AS integer)
      AND tree.global_uniq_id != req.global_uniq_id ) z )
WHERE
  TRUE;
  -- create children_array
CREATE OR REPLACE TABLE
  diff.tmp_requests AS
SELECT
  *,
  SPLIT(children) AS children_array
FROM
  diff.tmp_requests;