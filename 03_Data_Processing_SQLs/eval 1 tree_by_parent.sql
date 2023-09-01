-- This is SQL used to create the trees by parent(table tree_by_parent). This table contains all requests of a visit and their parent-child relationships.

  -- determine the depth OF each request
DECLARE
  x int64 DEFAULT 0; /*,
  TREE BY PARENT /* convert ARRAY TO COLUMNS  */
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
  UNNEST(parent_array) parent; -- ADD is_root ROWS
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
  is_root IS TRUE;/*
UPDATE
  `your-bigquery-data-set.diff.tree_by_parent`
SET
  parent=-1 parent_url_hash=-1
WHERE
  is_root IS TRUE;*/
UPDATE
  diff.tree_by_parent t1
SET
  parent_url_hash=(
  SELECT
    DISTINCT tree_url_hash
  FROM
    `your-bigquery-data-set.diff.tree_by_parent` t2
  WHERE
    t2.global_uniq_id=t1.parent )
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_by_parent`
SET
  tree_depth=NULL
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_by_parent`
SET
  tree_depth=0
WHERE
  is_root IS TRUE; --AND is_root_frame IS TRUE;
LOOP
SET
  x=(
  SELECT
    MAX(tree_depth)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`);
UPDATE
  `your-bigquery-data-set.diff.tree_by_parent` t1
SET
  tree_depth=(
  SELECT
    MAX(tree_depth)+1
  FROM
    `your-bigquery-data-set.diff.tree_by_parent` t2
  WHERE
    t1.parent=t2.global_uniq_id
    AND tree_depth IS NOT NULL )
WHERE
  parent<global_uniq_id
  AND t1.tree_depth IS NULL;
IF
  ( x=(
    SELECT
      MAX(tree_depth)
    FROM
      `your-bigquery-data-set.diff.tree_by_parent`)) THEN
LEAVE
  ;
END IF
  ; #TODO: DROP tree_depth=''
END LOOP
  ; --- determine the chain OF requests */
ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS chain_stage int;
UPDATE
  `your-bigquery-data-set.diff.tree_by_parent`
SET
  chain_stage=tree_depth
WHERE
  TRUE;
ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS chain string;
UPDATE
  diff.tree_by_parent
SET
  chain=CONCAT(CAST(global_uniq_id AS string), '|', CAST(tree_url_hash AS string))
WHERE
  TRUE;
LOOP
UPDATE
  `your-bigquery-data-set.diff.tree_by_parent` t1
SET
  chain=(
  SELECT
    CONCAT( ifnull(STRING_AGG(DISTINCT CAST(t2.parent AS string)),
        '0'), '<', ifnull(t1.chain,
        ''), '>', ifnull(STRING_AGG(DISTINCT CAST(t2.parent_url_hash AS string)),
        '0') )
  FROM
    `your-bigquery-data-set.diff.tree_by_parent` t2
  WHERE
    CAST(SPLIT(SPLIT(SPLIT(t1.chain,'|')[
        OFFSET
          (0)],"<")[
      OFFSET
        (0)],',')[
    OFFSET
      (0)] AS int64)=t2.global_uniq_id --AND (t1.tree_depth-t2.tree_depth)=1
    AND t2.parent IS NOT NULL),
  chain_stage=chain_stage-1
WHERE
  chain_stage!=0
  AND tree_depth IS NOT NULL;
IF
  ( (
    SELECT
      COUNT(*)
    FROM
      `your-bigquery-data-set.diff.tree_by_parent`
    WHERE
      chain_stage!=0
      AND tree_depth IS NOT NULL)=0) THEN
LEAVE
  ;
END IF
  ;
END LOOP
  ; /*,
  -- DROP ROWS without depths */
DELETE
FROM
  diff.tree_by_parent
WHERE
  tree_depth IS NULL;
ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS chain_global_id string;
UPDATE
  `your-bigquery-data-set.diff.tree_by_parent`
SET
  chain_global_id=SPLIT(chain,'|')[
OFFSET
  (0)]
WHERE
  TRUE;
ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS chain_url string;
UPDATE
  `your-bigquery-data-set.diff.tree_by_parent`
SET
  chain_url=SPLIT(chain,'|')[
OFFSET
  (1)]
WHERE
  TRUE;
ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS children string;
UPDATE
  `your-bigquery-data-set.diff.tree_by_parent` t1
SET
  children=(
  SELECT
    STRING_AGG(DISTINCT CAST(tree_url_hash AS string))
  FROM
    `your-bigquery-data-set.diff.tree_by_parent` t2
  WHERE
    t2.parent=t1.global_uniq_id
    AND t2.tree_depth= t1.tree_depth+1)
WHERE
  TRUE;
ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS children_count int;
UPDATE
  diff.tree_by_parent
SET
  children_count=ifnull(ARRAY_LENGTH(SPLIT(children,',')),
    0 )
WHERE
  TRUE; -- get meta DATA
ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN meta STRUCT< in_profiles int,
  is_tracker bool,
  resource_type string,
  is_third_party bool,
  method string,
  etld string >;
UPDATE
  diff.tree_by_parent t1
SET
  meta.in_profiles =(
  SELECT
    COUNT(*)
  FROM (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_parent t2
    WHERE
      t1.visit_id=t2.visit_id
      AND t1.tree_url_hash=t2.tree_url_hash
    GROUP BY
      browser_id ) ),
  meta.is_tracker=(
  SELECT
    CAST(is_tracker AS bool)
  FROM
    diff.tmp_requests t2
  WHERE
    t1.global_uniq_id=t2.global_uniq_id),
  meta.resource_type=(
  SELECT
    resource_type
  FROM
    diff.tmp_requests t2
  WHERE
    t1.global_uniq_id=t2.global_uniq_id),
  meta.is_third_party=(
  SELECT
    CAST(is_third_party_channel AS bool)
  FROM
    diff.tmp_requests t2
  WHERE
    t1.global_uniq_id=t2.global_uniq_id),
  meta.method=(
  SELECT
    method
  FROM
    diff.tmp_requests t2
  WHERE
    t1.global_uniq_id=t2.global_uniq_id),
  meta.etld=(
  SELECT
    etld
  FROM
    diff.tmp_requests t2
  WHERE
    t1.global_uniq_id=t2.global_uniq_id)
WHERE
  TRUE ; /*,
  calculate chain_url_id*/
ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS chain_url_id int;
UPDATE
  `your-bigquery-data-set.diff.tree_by_parent`
SET
  chain_url_id=farm_fingerprint(chain_url)
WHERE
  TRUE; /*,
  -- DNS*/
ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS dns STRUCT< addresses string,
  used_address string,
  canonical_name string,
  is_TRR int,
  cdn string >;
UPDATE
  diff.tree_by_parent t1
SET
  dns.addresses=(
  SELECT
    dns.addresses
  FROM
    diff.tmp_requests t2
  WHERE
    t1.global_uniq_id=t2.global_uniq_id),
  dns.used_address=(
  SELECT
    dns.used_address
  FROM
    diff.tmp_requests t2
  WHERE
    t1.global_uniq_id=t2.global_uniq_id),
  dns.canonical_name=(
  SELECT
    dns.canonical_name
  FROM
    diff.tmp_requests t2
  WHERE
    t1.global_uniq_id=t2.global_uniq_id),
  dns.is_TRR=(
  SELECT
    dns.is_TRR
  FROM
    diff.tmp_requests t2
  WHERE
    t1.global_uniq_id=t2.global_uniq_id),
  dns.cdn=(
  SELECT
    dns.cdn
  FROM
    diff.tmp_requests t2
  WHERE
    t1.global_uniq_id=t2.global_uniq_id)
WHERE
  TRUE; /* determine children count (includes grandchildren AS well) */

  CREATE OR REPLACE TABLE
  `your-bigquery-data-set.diff.tree_by_parent` AS
SELECT
  *,
  diff.fc_jsconvert_array(chain_global_id) AS chain_array
FROM
  `your-bigquery-data-set.diff.tree_by_parent`;

 ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS sub_nodes STRUCT< total int,
  total_tracker int>;
 



UPDATE
  diff.tree_by_parent t1
SET
  sub_nodes.total=(
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_parent t2
  WHERE
    t1.global_uniq_id IN UNNEST(t2.chain_array)
    AND t1.browser_visit=t2.browser_visit
    AND t2.tree_depth>t1.tree_depth )
WHERE
  TRUE;


UPDATE
  diff.tree_by_parent t1
SET
  sub_nodes.total_tracker=(
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_parent t2
  WHERE
    t1.global_uniq_id IN UNNEST(t2.chain_array)
    AND t1.browser_visit=t2.browser_visit
    AND t2.tree_depth>t1.tree_depth
    AND t2.meta.is_tracker )
WHERE
  TRUE;
 

CREATE OR REPLACE TABLE
  diff.tmp_tracking_roots AS
SELECT
  ARRAY_AGG(global_uniq_id) global_uniq_id,
  browser_visit
FROM
  diff.tree_by_parent
WHERE
  meta.is_third_party=true
  group by browser_visit; 
   
   
 ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS chain_meta STRUCT<  
  has_third_party_parent bool,  
  has_tracker_parent bool>;
 


UPDATE
  diff.tree_by_parent t1
SET
  chain_meta.has_third_party_parent= diff.fc_js_intersection_chain((
    SELECT
      ifnull(t2.global_uniq_id,[])
    FROM
      diff.tmp_tracking_roots t2
      where t2.browser_visit=t1.browser_visit ),
    ifnull(chain_array,[]) )
WHERE
  TRUE;  
  


CREATE OR REPLACE TABLE
  diff.tmp_all_trackers AS
SELECT
  ARRAY_AGG(global_uniq_id) global_uniq_id,
  browser_visit
FROM
  diff.tree_by_parent
WHERE
    meta.is_tracker group by browser_visit; 

 

 

UPDATE
  diff.tree_by_parent t1
SET
  chain_meta.has_tracker_parent= diff.fc_js_intersection_chain((
    SELECT
      ifnull(global_uniq_id,[])
    FROM
      diff.tmp_all_trackers t2
      where t2.browser_visit=t1.browser_visit ),
    ifnull(chain_array,[]) )
WHERE
  TRUE;  
 
  

drop table diff.tmp_all_trackers;

  
  
  /*parent meta data */
ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS parent_meta2 string;
UPDATE
  diff.tree_by_parent t1
SET
  parent_meta2= (
  SELECT
    TO_JSON_STRING(meta)
  FROM (
    SELECT
      meta
    FROM
      diff.tree_by_parent t2
    WHERE
      t2.global_uniq_id=t1.parent ))
WHERE
  TRUE;
ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS parent_meta STRUCT< in_profiles int,
  is_tracker bool,
  resource_type string,
  is_third_party bool,
  method string,
  etld string >;
UPDATE
  diff.tree_by_parent
SET
  parent_meta.in_profiles=CAST(JSON_QUERY(parent_meta2,
      '$.in_profiles') AS int),
  parent_meta.is_tracker=CAST(JSON_QUERY(parent_meta2,
      '$.is_tracker') AS bool),
  parent_meta.resource_type=JSON_QUERY(parent_meta2,
    '$.resource_type'),
  parent_meta.is_third_party=CAST(JSON_QUERY(parent_meta2,
      '$.is_third_party') AS bool),
  parent_meta.method=JSON_QUERY(parent_meta2,
    '$.method'),
  parent_meta.etld=JSON_QUERY(parent_meta2,
    '$.etld')
WHERE
  TRUE;
UPDATE
  diff.tree_by_parent
SET
  parent_meta.etld=REPLACE(parent_meta.etld,'"','')
WHERE
  TRUE;
CREATE OR REPLACE TABLE
  diff.tree_by_parent AS
SELECT
  * EXCEPT(parent_meta2)
FROM
  diff.tree_by_parent;





/*, rank_bucket*/
ALTER TABLE
  `diff.tree_by_parent` ADD COLUMN
IF NOT EXISTS rank_bucket int;
UPDATE
  diff.tree_by_parent
SET
  rank_bucket=(
  SELECT
    rank_bucket
  FROM
    diff.sites
  WHERE
    id=CAST(SPLIT(visit_id,'_')[
    OFFSET 
      (0)] AS int ))
WHERE
  TRUE