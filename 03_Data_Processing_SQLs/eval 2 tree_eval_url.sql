-- This SQL is used to create the trees by URL (table tree_eval_url)

CREATE OR REPLACE TABLE
  diff.tree_eval_url AS
SELECT
  tree_url_hash,
  visit_id,
  0 AS in_profiles
FROM
  `your-bigquery-data-set.diff.tree_by_parent`
GROUP BY
  tree_url_hash,
  visit_id;
UPDATE
  diff.tree_eval_url t1
SET
  in_profiles= (
  SELECT
    COUNT(*)
  FROM (
    SELECT
      COUNT(*)
    FROM (
      SELECT
        *
      FROM
        `your-bigquery-data-set.diff.tmp_requests` t2
      WHERE
        t1.tree_url_hash= t2.tree_url_hash
        AND t1.visit_id= t2.visit_id )
    GROUP BY
      browser_visit) )
WHERE
  TRUE; /*,
  0: openwpm_desktop,
  1: openwpm_interaction_1,
  2: openwpm_interaction_2,
  3: openwpm_interaction_old,
  4: openwpmheadless_interaction */
ALTER TABLE
  `diff.tree_eval_url` ADD COLUMN
IF NOT EXISTS freq STRUCT< in_0 int64,
  in_1 int64,
  in_2 int64,
  in_3 int64,
  in_4 int64>;
UPDATE
  diff.tree_eval_url t1
SET
  freq.in_0= (
  SELECT
    COUNT(*)
  FROM
    `your-bigquery-data-set.diff.tmp_requests` t2
  WHERE
    t1.tree_url_hash= t2.tree_url_hash
    AND t1.visit_id=t2.visit_id
    AND browser_id='openwpm_desktop' ),
  freq.in_1= (
  SELECT
    COUNT(*)
  FROM
    `your-bigquery-data-set.diff.tmp_requests` t2
  WHERE
    t1.tree_url_hash= t2.tree_url_hash
    AND t1.visit_id=t2.visit_id
    AND browser_id='openwpm_interaction_1' ),
  freq.in_2= (
  SELECT
    COUNT(*)
  FROM
    `your-bigquery-data-set.diff.tmp_requests` t2
  WHERE
    t1.tree_url_hash= t2.tree_url_hash
    AND t1.visit_id=t2.visit_id
    AND browser_id='openwpm_interaction_2' ),
  freq.in_3= (
  SELECT
    COUNT(*)
  FROM
    `your-bigquery-data-set.diff.tmp_requests` t2
  WHERE
    t1.tree_url_hash= t2.tree_url_hash
    AND t1.visit_id=t2.visit_id
    AND browser_id='openwpm_interaction_old' ),
  freq.in_4= (
  SELECT
    COUNT(*)
  FROM
    `your-bigquery-data-set.diff.tmp_requests` t2
  WHERE
    t1.tree_url_hash= t2.tree_url_hash
    AND t1.visit_id=t2.visit_id
    AND browser_id='openwpmheadless_interaction' )
WHERE
  TRUE; --,
  /* depth_eval,
  0: openwpm_desktop,
  1: openwpm_interaction_1,
  2: openwpm_interaction_2,
  3: openwpm_interaction_old,
  4: openwpmheadless_interaction */
ALTER TABLE
  `diff.tree_eval_url` ADD COLUMN
IF NOT EXISTS depth STRUCT< in_0 string,
  in_1 string,
  in_2 string,
  in_3 string,
  in_4 string,
  eval_0_1 decimal,
  eval_0_2 decimal,
  eval_0_3 decimal,
  eval_0_4 decimal,
  eval_1_2 decimal,
  eval_1_3 decimal,
  eval_1_4 decimal,
  eval_2_2 decimal,
  eval_2_3 decimal,
  eval_2_4 decimal,
  eval_3_4 decimal,
  eval_all decimal>;
UPDATE
  `your-bigquery-data-set.diff.tree_eval_url` t1
SET
  depth.in_0=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(tree_depth AS string)),
      '')
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_desktop'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash ),
  depth.in_1=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(tree_depth AS string)),
      '')
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_interaction_1'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash ),
  depth.in_2=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(tree_depth AS string)),
      '')
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_interaction_2' 
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash ),
  depth.in_3=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(tree_depth AS string)),
      '')
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_interaction_old'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash ),
  depth.in_4=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(tree_depth AS string)),
      '')
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpmheadless_interaction'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash )
WHERE
  TRUE; /* eval_0_1 decimal,
  eval_0_2 decimal,
  eval_0_3 decimal,
  eval_0_4 decimal,
  eval_1_2 decimal,
  eval_1_3 decimal,
  eval_1_4 decimal,
  eval_2_2 decimal,
  eval_2_3 decimal,
  eval_2_4 decimal,
  eval_3_4 decimal,
  eval_all decimal*/
UPDATE
  `your-bigquery-data-set.diff.tree_eval_url` t1
SET
  depth.eval_0_1= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_1)),
  depth.eval_0_2= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_2)),
  depth.eval_0_3= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_3)),
  depth.eval_0_4= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_4)),
  depth.eval_1_2= diff.fc_sim_array(CONCAT(depth.in_1,'|', depth.in_2)),
  depth.eval_1_3= diff.fc_sim_array(CONCAT(depth.in_1,'|', depth.in_3)),
  depth.eval_1_4= diff.fc_sim_array(CONCAT(depth.in_1,'|', depth.in_4)),
  depth.eval_2_2= diff.fc_sim_array(CONCAT(depth.in_2,'|', depth.in_2)),
  depth.eval_2_3= diff.fc_sim_array(CONCAT(depth.in_2,'|', depth.in_3)),
  depth.eval_2_4= diff.fc_sim_array(CONCAT(depth.in_2,'|', depth.in_4)),
  depth.eval_3_4= diff.fc_sim_array(CONCAT(depth.in_3,'|', depth.in_4)) --,
  -- depth.eval_all= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_1,'|', depth.in_2,'|', depth.in_3,'|', depth.in_4))
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_eval_url` t1
SET
  depth.eval_all= (
  SELECT
    ROUND(AVG(Estimate), 2)
  FROM
    UNNEST([depth.eval_0_1, depth.eval_0_2, depth.eval_0_3, depth.eval_0_4, depth.eval_1_2, depth.eval_1_3, depth.eval_1_4, depth.eval_2_2, depth.eval_2_3, depth.eval_2_4, depth.eval_3_4]) Estimate )
WHERE
  TRUE;


 /*,
 -- import meta*/

 ALTER TABLE
  `diff.tree_eval_url` ADD COLUMN
IF NOT EXISTS meta2 string;
UPDATE
  diff.tree_eval_url t1
SET
  meta2= (
  SELECT
    json_extract_array(concat('[',STRING_AGG(DISTINCT TO_JSON_STRING(meta)),']')) [
OFFSET
  (0)]
  FROM (
    SELECT
      meta
    FROM
      diff.tree_by_parent t2
    WHERE
      t1.tree_url_hash=t2.tree_url_hash
      AND t1.visit_id=t2.visit_id ))
WHERE
  TRUE; 
ALTER TABLE
  `diff.tree_eval_url` ADD COLUMN
IF NOT EXISTS meta STRUCT< in_profiles int,
  is_tracker bool,
  resource_type string,
  is_third_party bool,
  method string,
  etld string >;
UPDATE
  diff.tree_eval_url
SET
  meta.in_profiles=CAST(JSON_QUERY(meta2,
      '$.in_profiles') AS int),
  meta.is_tracker=CAST(JSON_QUERY(meta2,
      '$.is_tracker') AS bool),
  meta.resource_type=JSON_QUERY(meta2,
    '$.resource_type'),
  meta.is_third_party=CAST(JSON_QUERY(meta2,
      '$.is_third_party') AS bool),
  meta.method=JSON_QUERY(meta2,
    '$.method'),
  meta.etld=JSON_QUERY(meta2,
    '$.etld')
WHERE
  TRUE;
CREATE OR REPLACE TABLE
  diff.tree_eval_url AS
SELECT
  * EXCEPT(meta2)
FROM
  diff.tree_eval_url;