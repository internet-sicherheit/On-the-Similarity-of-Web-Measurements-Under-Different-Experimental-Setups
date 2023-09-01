-- This SQL is used to create the trees by request chain (table tree_by_chain). It is one of the main tables used in the evaluation.

  -- CREATE tree BY chain
CREATE OR REPLACE TABLE
  diff.tree_by_chain AS
SELECT
ROW_NUMBER() OVER() AS row_id,
  visit_id,
  tree_url_hash,
  ARRAY_LENGTH(SPLIT((chain_url),'>'))-1 depth,
  chain_url_id,
  MAX(global_uniq_id) max_global_uniq_id
FROM
  `your-bigquery-data-set.diff.tree_by_parent`
GROUP BY
  chain_url,
  tree_url_hash,
  chain_url_id,
  visit_id ; /*,
  -- transfer meta DATA
ALTER TABLE
  `diff.tree_by_chain` ADD COLUMN
IF NOT EXISTS meta STRUCT< in_profiles int,
  is_tracker bool,
  resource_type string,
  is_third_party bool,
  method string,
  etld string >; */ /*,
  get meta DATA*/
ALTER TABLE
  `diff.tree_by_chain` ADD COLUMN
IF NOT EXISTS meta2 string;
UPDATE
  diff.tree_by_chain t
SET
  meta2= (
  SELECT
    TO_JSON_STRING(meta)
  FROM
    diff.tree_by_parent t3
  WHERE
    t3.global_uniq_id=t.max_global_uniq_id )
WHERE
  TRUE;
ALTER TABLE
  `diff.tree_by_chain` ADD COLUMN
IF NOT EXISTS meta STRUCT< in_profiles int,
  is_tracker bool,
  resource_type string,
  is_third_party bool,
  method string,
  etld string >;
UPDATE
  diff.tree_by_chain
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
  diff.tree_by_chain AS
SELECT
  * EXCEPT(meta2)
FROM
  diff.tree_by_chain; /*
UPDATE
  diff.tree_by_chain t1
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
      browser_id ) )
WHERE
  TRUE,
  meta.is_tracker=(
  SELECT
    DISTINCT meta.is_tracker
  FROM
    diff.tree_by_parent t2
  WHERE
    t1.tree_url_hash=t2.tree_url_hash),
  meta.resource_type=(
  SELECT
    DISTINCT meta.resource_type
  FROM
    diff.tree_by_parent t2
  WHERE
    t1.tree_url_hash=t2.tree_url_hash),
  meta.is_third_party=(
  SELECT
    DISTINCT meta.is_third_party
  FROM
    diff.tree_by_parent t2
  WHERE
    t1.tree_url_hash=t2.tree_url_hash),
  meta.method=(
  SELECT
    DISTINCT meta.method
  FROM
    diff.tree_by_parent t2
  WHERE
    t1.tree_url_hash=t2.tree_url_hash),
  meta.etld=(
  SELECT
    DISTINCT meta.etld
  FROM
    diff.tree_by_parent t2
  WHERE
    t1.tree_url_hash=t2.tree_url_hash)
WHERE
  TRUE ;
UPDATE
  diff.tree_by_chain t1
SET
  in_profiles_chain_url= (
  SELECT
    COUNT(*)
  FROM (
    SELECT
      COUNT(*)
    FROM (
      SELECT
        *
      FROM
        `your-bigquery-data-set.diff.tree_by_parent` t2
      WHERE
        t1.tree_url_hash= t2.tree_url_hash
        AND t1.visit_id= t2.visit_id
        AND t1.chain_url= t2.chain_url )
    GROUP BY
      browser_visit))
WHERE
  TRUE; /*,
  -- get params fr0m request*/ /*,
  0: openwpm_desktop,
  1: openwpm_interaction_1,
  2: openwpm_interaction_2,
  3: openwpm_interaction_old,
  4: openwpmheadless_interaction */
ALTER TABLE
  `diff.tree_by_chain` ADD COLUMN
IF NOT EXISTS freq STRUCT< in_0 int64,
  in_1 int64,
  in_2 int64,
  in_3 int64,
  in_4 int64,
  seen_in_profiles int>;
UPDATE
  diff.tree_by_chain t1
SET
  freq.in_0= (
  SELECT
    COUNT(*)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent` t2
  WHERE
    t1.tree_url_hash= t2.tree_url_hash
    AND t1.visit_id=t2.visit_id
    AND browser_id='openwpm_desktop' ),
  freq.in_1= (
  SELECT
    COUNT(*)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent` t2
  WHERE
    t1.tree_url_hash= t2.tree_url_hash
    AND t1.visit_id=t2.visit_id
    AND browser_id='openwpm_interaction_1' ),
  freq.in_2= (
  SELECT
    COUNT(*)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent` t2
  WHERE
    t1.tree_url_hash= t2.tree_url_hash
    AND t1.visit_id=t2.visit_id
    AND browser_id='openwpm_interaction_2' ),
  freq.in_3= (
  SELECT
    COUNT(*)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent` t2
  WHERE
    t1.tree_url_hash= t2.tree_url_hash
    AND t1.visit_id=t2.visit_id
    AND browser_id='openwpm_interaction_old' ),
  freq.in_4= (
  SELECT
    COUNT(*)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent` t2
  WHERE
    t1.tree_url_hash= t2.tree_url_hash
    AND t1.visit_id=t2.visit_id
    AND browser_id='openwpmheadless_interaction' ),
  freq.seen_in_profiles= (
  SELECT
    COUNT(*)
  FROM (
    SELECT
      COUNT(*)
    FROM
      `your-bigquery-data-set.diff.tree_by_parent` t2
    WHERE
      t1.tree_url_hash= t2.tree_url_hash
      AND t1.visit_id=t2.visit_id
    GROUP BY
      browser_id ))
WHERE
  TRUE;
ALTER TABLE
  `diff.tree_by_chain` ADD COLUMN
IF NOT EXISTS children STRUCT< in_0 string,
  in_1 string,
  in_2 string,
  in_3 string,
  in_4 string,
  ct_0 int,
  ct_1 int,
  ct_2 int,
  ct_3 int,
  ct_4 int,
  ct_avg_all decimal,
  sim_0_1 decimal,
  sim_0_2 decimal,
  sim_0_3 decimal,
  sim_0_4 decimal,
  sim_1_2 decimal,
  sim_1_3 decimal,
  sim_1_4 decimal,
  sim_2_2 decimal,
  sim_2_3 decimal,
  sim_2_4 decimal,
  sim_3_4 decimal,
  sim_all decimal >;
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  children.in_0=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(children AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_desktop'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth),
  children.in_1=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(children AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_interaction_1'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth ),
  children.in_2=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(children AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_interaction_2'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth ),
  children.in_3=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(children AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_interaction_old'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth ),
  children.in_4=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(children AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpmheadless_interaction'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth )
WHERE
  TRUE; /*,
  similarity OF children */
UPDATE
  diff.tree_by_chain
SET
  children.ct_0 = ifnull(ARRAY_LENGTH(SPLIT(children.in_0,',')),
    0),
  children.ct_1 = ifnull(ARRAY_LENGTH(SPLIT(children.in_1,',')),
    0),
  children.ct_2 = ifnull(ARRAY_LENGTH(SPLIT(children.in_2,',')),
    0),
  children.ct_3 = ifnull(ARRAY_LENGTH(SPLIT(children.in_3,',')),
    0),
  children.ct_4 = ifnull(ARRAY_LENGTH(SPLIT(children.in_4,',')),
    0)
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  children.ct_avg_all= (
  SELECT
    CAST(ROUND(AVG(Estimate), 2) AS numeric)
  FROM
    UNNEST([children.ct_0, children.ct_1, children.ct_2, children.ct_3, children.ct_4]) Estimate )
WHERE
  TRUE; /*,
  similarity OF children */
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  children.sim_0_1= diff.fc_sim_array(CONCAT(ifnull(children.in_0,
        ''),'|', ifnull(children.in_1,
        ''))),
  children.sim_0_2= diff.fc_sim_array(CONCAT(ifnull(children.in_0,
        ''),'|', ifnull(children.in_2,
        ''))),
  children.sim_0_3= diff.fc_sim_array(CONCAT(ifnull(children.in_0,
        ''),'|', ifnull(children.in_3,
        ''))),
  children.sim_0_4= diff.fc_sim_array(CONCAT(ifnull(children.in_0,
        ''),'|', ifnull(children.in_4,
        ''))),
  children.sim_1_2= diff.fc_sim_array(CONCAT(ifnull(children.in_1,
        ''),'|', ifnull(children.in_2,
        ''))),
  children.sim_1_3= diff.fc_sim_array(CONCAT(ifnull(children.in_1,
        ''),'|', ifnull(children.in_3,
        ''))),
  children.sim_1_4= diff.fc_sim_array(CONCAT(ifnull(children.in_1,
        ''),'|', ifnull(children.in_4,
        ''))),
  children.sim_2_2= diff.fc_sim_array(CONCAT(ifnull(children.in_2,
        ''),'|', ifnull(children.in_2,
        ''))),
  children.sim_2_3= diff.fc_sim_array(CONCAT(ifnull(children.in_2,
        ''),'|', ifnull(children.in_3,
        ''))),
  children.sim_2_4= diff.fc_sim_array(CONCAT(ifnull(children.in_2,
        ''),'|', ifnull(children.in_4,
        ''))),
  children.sim_3_4= diff.fc_sim_array(CONCAT(ifnull(children.in_3,
        ''),'|', ifnull(children.in_4,
        ''))) --,
  -- depth.eval_all= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_1,'|', depth.in_2,'|', depth.in_3,'|', depth.in_4))
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  children.sim_all= (
  SELECT
    CAST(ROUND(AVG(Estimate), 2) AS numeric)
  FROM
    UNNEST([children.sim_0_1, children.sim_0_2, children.sim_0_3, children.sim_0_4, children.sim_1_2, children.sim_1_3, children.sim_1_4, children.sim_2_2, children.sim_2_3, children.sim_2_4, children.sim_3_4]) Estimate )
WHERE
  TRUE; /*,
  -- determine parents */
ALTER TABLE
  `diff.tree_by_chain` ADD COLUMN
IF NOT EXISTS parent STRUCT< in_0 string,
  in_1 string,
  in_2 string,
  in_3 string,
  in_4 string,
  in_total int,
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
  eval_all decimal >;
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  parent.in_0=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(parent_url_hash AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_desktop'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth),
  parent.in_1=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(parent_url_hash AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_interaction_1'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth ),
  parent.in_2=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(parent_url_hash AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_interaction_2'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth ),
  parent.in_3=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(parent_url_hash AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_interaction_old'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth ),
  parent.in_4=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(parent_url_hash AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpmheadless_interaction'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth )
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  parent.eval_0_1= diff.fc_sim_array(CONCAT(ifnull(parent.in_0,
        ''),'|', ifnull(parent.in_1,
        ''))),
  parent.eval_0_2= diff.fc_sim_array(CONCAT(ifnull(parent.in_0,
        ''),'|', ifnull(parent.in_2,
        ''))),
  parent.eval_0_3= diff.fc_sim_array(CONCAT(ifnull(parent.in_0,
        ''),'|', ifnull(parent.in_3,
        ''))),
  parent.eval_0_4= diff.fc_sim_array(CONCAT(ifnull(parent.in_0,
        ''),'|', ifnull(parent.in_4,
        ''))),
  parent.eval_1_2= diff.fc_sim_array(CONCAT(ifnull(parent.in_1,
        ''),'|', ifnull(parent.in_2,
        ''))),
  parent.eval_1_3= diff.fc_sim_array(CONCAT(ifnull(parent.in_1,
        ''),'|', ifnull(parent.in_3,
        ''))),
  parent.eval_1_4= diff.fc_sim_array(CONCAT(ifnull(parent.in_1,
        ''),'|', ifnull(parent.in_4,
        ''))),
  parent.eval_2_2= diff.fc_sim_array(CONCAT(ifnull(parent.in_2,
        ''),'|', ifnull(parent.in_2,
        ''))),
  parent.eval_2_3= diff.fc_sim_array(CONCAT(ifnull(parent.in_2,
        ''),'|', ifnull(parent.in_3,
        ''))),
  parent.eval_2_4= diff.fc_sim_array(CONCAT(ifnull(parent.in_2,
        ''),'|', ifnull(parent.in_4,
        ''))),
  parent.eval_3_4= diff.fc_sim_array(CONCAT(ifnull(parent.in_3,
        ''),'|', ifnull(parent.in_4,
        ''))) --,
  -- depth.eval_all= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_1,'|', depth.in_2,'|', depth.in_3,'|', depth.in_4))
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  parent.eval_all= (
  SELECT
    CAST(ROUND(AVG(Estimate), 2) AS numeric)
  FROM
    UNNEST([parent.eval_0_1, parent.eval_0_2, parent.eval_0_3, parent.eval_0_4, parent.eval_1_2, parent.eval_1_3, parent.eval_1_4, parent.eval_2_2, parent.eval_2_3, parent.eval_2_4, parent.eval_3_4]) Estimate )
WHERE
  TRUE; /*--- transfer DNS
ALTER TABLE
  `diff.tree_by_chain` ADD COLUMN
IF NOT EXISTS dns2 string;
UPDATE
  diff.tree_by_chain t
SET
  dns2= (
  SELECT
    TO_JSON_STRING(dns)
  FROM
    diff.tree_by_parent t3
  WHERE
    t3.global_uniq_id=t.max_global_uniq_id )
WHERE
  TRUE;
ALTER TABLE
  `diff.tree_by_chain` ADD COLUMN
IF NOT EXISTS dns STRUCT< addresses string,
  used_address string,
  canonical_name string,
  is_TRR int,
  time_stamp datetime >;
UPDATE
  diff.tree_by_chain
SET
  dns.addresses=CAST(JSON_QUERY(dns2,
      '$.addresses') AS string),
  dns.used_address=CAST(JSON_QUERY(dns2,
      '$.used_address') AS string),
  dns.canonical_name=CAST(JSON_QUERY(dns2,
      '$.canonical_name') AS string),
  dns.is_TRR=CAST(JSON_QUERY(dns2,
      '$.is_TRR') AS int)
WHERE
  TRUE;
CREATE OR REPLACE TABLE
  diff.tree_by_chain AS
SELECT
  * EXCEPT(dns2)
FROM
  diff.tree_by_chain;*/ /*,
  0: openwpm_desktop,
  1: openwpm_interaction_1,
  2: openwpm_interaction_2,
  3: openwpm_interaction_old,
  4: openwpmheadless_interaction */
ALTER TABLE
  `diff.tree_by_chain` ADD COLUMN
IF NOT EXISTS dns STRUCT< in_0 string,
  in_1 string,
  in_2 string,
  in_3 string,
  in_4 string,
  eval_0_1 string,
  eval_0_2 string,
  eval_0_3 string,
  eval_0_4 string,
  eval_1_2 string,
  eval_1_3 string,
  eval_1_4 string,
  eval_2_3 string,
  eval_2_4 string,
  eval_3_4 string,
  eval_all string >;
UPDATE
  diff.tree_by_chain
SET
  dns.eval_0_1= '[{ "addresses" : null, "used_address" : null, "canonical_name" : null, "is_TRR" : null }]',
  dns.eval_0_2= '[{ "addresses" : null, "used_address" : null, "canonical_name" : null, "is_TRR" : null }]',
  dns.eval_0_3= '[{ "addresses" : null, "used_address" : null, "canonical_name" : null, "is_TRR" : null }]',
  dns.eval_0_4= '[{ "addresses" : null, "used_address" : null, "canonical_name" : null, "is_TRR" : null }]',
  dns.eval_1_2= '[{ "addresses" : null, "used_address" : null, "canonical_name" : null, "is_TRR" : null }]',
  dns.eval_1_3= '[{ "addresses" : null, "used_address" : null, "canonical_name" : null, "is_TRR" : null }]',
  dns.eval_1_4= '[{ "addresses" : null, "used_address" : null, "canonical_name" : null, "is_TRR" : null }]',
  dns.eval_2_3= '[{ "addresses" : null, "used_address" : null, "canonical_name" : null, "is_TRR" : null }]',
  dns.eval_2_4= '[{ "addresses" : null, "used_address" : null, "canonical_name" : null, "is_TRR" : null }]',
  dns.eval_3_4= '[{ "addresses" : null, "used_address" : null, "canonical_name" : null, "is_TRR" : null }]',
  dns.eval_all= '[{ "addresses" : null, "used_address" : null, "canonical_name" : null, "is_TRR" : null }]'
WHERE
  TRUE ;
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  dns.in_0= (
  SELECT
    ifnull( CONCAT('[',STRING_AGG(DISTINCT CAST(to_json_STRING(dns) AS string), ',' ),']'),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_desktop'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth),
  dns.in_1=(
  SELECT
    ifnull( CONCAT('[',STRING_AGG(DISTINCT CAST(to_json_STRING(dns) AS string), ',' ),']'),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_interaction_1'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth),
  dns.in_2=(
  SELECT
    ifnull( CONCAT('[',STRING_AGG(DISTINCT CAST(to_json_STRING(dns) AS string), ',' ),']'),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_interaction_2'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth),
  dns.in_3=(
  SELECT
    ifnull( CONCAT('[',STRING_AGG(DISTINCT CAST(to_json_STRING(dns) AS string), ',' ),']'),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpm_interaction_old'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth),
  dns.in_4=(
  SELECT
    ifnull( CONCAT('[',STRING_AGG(DISTINCT CAST(to_json_STRING(dns) AS string), ',' ),']'),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`t2
  WHERE
    t2.browser_id='openwpmheadless_interaction'
    AND t2.visit_id=t1.visit_id
    AND t1.tree_url_hash=t2.tree_url_hash
    AND t1.depth=t2.tree_depth)
WHERE
  TRUE;
UPDATE
  diff.tree_by_chain
SET
  dns.in_0= diff.fc_removeBlankDns(dns.in_0),
  dns.in_1= diff.fc_removeBlankDns(dns.in_1),
  dns.in_2= diff.fc_removeBlankDns(dns.in_2),
  dns.in_3= diff.fc_removeBlankDns(dns.in_3),
  dns.in_4= diff.fc_removeBlankDns(dns.in_4)
WHERE
  TRUE ; /*,
  -- fc_jsonUpdate IS FUNCTION TO UPD4TE JS0N R0WS see its UDF,
  #,
  -- addresses */
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  dns.eval_0_1= diff.fc_jsonModify(dns.eval_0_1,
    'addresses',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ) ) ),
    0 ),
  dns.eval_0_2= diff.fc_jsonModify(dns.eval_0_2,
    'addresses',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ) ) ),
    0 ),
  dns.eval_0_3= diff.fc_jsonModify(dns.eval_0_3,
    'addresses',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ) ) ),
    0 ),
  dns.eval_0_4= diff.fc_jsonModify(dns.eval_0_4,
    'addresses',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ) ) ),
    0 ),
  dns.eval_1_2= diff.fc_jsonModify(dns.eval_1_2,
    'addresses',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ) ) ),
    0 ),
  dns.eval_1_3= diff.fc_jsonModify(dns.eval_1_3,
    'addresses',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ) ) ),
    0 ),
  dns.eval_1_4= diff.fc_jsonModify(dns.eval_1_4,
    'addresses',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ) ) ),
    0 ),
  dns.eval_2_3= diff.fc_jsonModify(dns.eval_2_3,
    'addresses',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ) ) ),
    0 ),
  dns.eval_2_4= diff.fc_jsonModify(dns.eval_2_4,
    'addresses',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ) ) ),
    0 ),
  dns.eval_3_4= diff.fc_jsonModify(dns.eval_3_4,
    'addresses',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.addresses'),
          '' ) ) ),
    0 )
WHERE
  TRUE; -- used_address */
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  dns.eval_0_1= diff.fc_jsonModify(dns.eval_0_1,
    'used_address',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ) ) ),
    0 ),
  dns.eval_0_2= diff.fc_jsonModify(dns.eval_0_2,
    'used_address',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ) ) ),
    0 ),
  dns.eval_0_3= diff.fc_jsonModify(dns.eval_0_3,
    'used_address',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ) ) ),
    0 ),
  dns.eval_0_4= diff.fc_jsonModify(dns.eval_0_4,
    'used_address',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ) ) ),
    0 ),
  dns.eval_1_2= diff.fc_jsonModify(dns.eval_1_2,
    'used_address',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ) ) ),
    0 ),
  dns.eval_1_3= diff.fc_jsonModify(dns.eval_1_3,
    'used_address',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ) ) ),
    0 ),
  dns.eval_1_4= diff.fc_jsonModify(dns.eval_1_4,
    'used_address',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ) ) ),
    0 ),
  dns.eval_2_3= diff.fc_jsonModify(dns.eval_2_3,
    'used_address',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ) ) ),
    0 ),
  dns.eval_2_4= diff.fc_jsonModify(dns.eval_2_4,
    'used_address',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ) ) ),
    0 ),
  dns.eval_3_4= diff.fc_jsonModify(dns.eval_3_4,
    'used_address',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.used_address'),
          '' ) ) ),
    0 )
WHERE
  TRUE; -- canonical_name */
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  dns.eval_0_1= diff.fc_jsonModify(dns.eval_0_1,
    'canonical_name',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ) ) ),
    0 ),
  dns.eval_0_2= diff.fc_jsonModify(dns.eval_0_2,
    'canonical_name',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ) ) ),
    0 ),
  dns.eval_0_3= diff.fc_jsonModify(dns.eval_0_3,
    'canonical_name',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ) ) ),
    0 ),
  dns.eval_0_4= diff.fc_jsonModify(dns.eval_0_4,
    'canonical_name',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ) ) ),
    0 ),
  dns.eval_1_2= diff.fc_jsonModify(dns.eval_1_2,
    'canonical_name',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ) ) ),
    0 ),
  dns.eval_1_3= diff.fc_jsonModify(dns.eval_1_3,
    'canonical_name',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ) ) ),
    0 ),
  dns.eval_1_4= diff.fc_jsonModify(dns.eval_1_4,
    'canonical_name',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ) ) ),
    0 ),
  dns.eval_2_3= diff.fc_jsonModify(dns.eval_2_3,
    'canonical_name',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ) ) ),
    0 ),
  dns.eval_2_4= diff.fc_jsonModify(dns.eval_2_4,
    'canonical_name',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ) ) ),
    0 ),
  dns.eval_3_4= diff.fc_jsonModify(dns.eval_3_4,
    'canonical_name',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.canonical_name'),
          '' ) ) ),
    0 )
WHERE
  TRUE; -- is_TRR */
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  dns.eval_0_1= diff.fc_jsonModify(dns.eval_0_1,
    'is_TRR',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ) ) ),
    0 ),
  dns.eval_0_2= diff.fc_jsonModify(dns.eval_0_2,
    'is_TRR',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ) ) ),
    0 ),
  dns.eval_0_3= diff.fc_jsonModify(dns.eval_0_3,
    'is_TRR',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ) ) ),
    0 ),
  dns.eval_0_4= diff.fc_jsonModify(dns.eval_0_4,
    'is_TRR',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_0)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ) ) ),
    0 ),
  dns.eval_1_2= diff.fc_jsonModify(dns.eval_1_2,
    'is_TRR',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ) ) ),
    0 ),
  dns.eval_1_3= diff.fc_jsonModify(dns.eval_1_3,
    'is_TRR',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ) ) ),
    0 ),
  dns.eval_1_4= diff.fc_jsonModify(dns.eval_1_4,
    'is_TRR',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_1)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ) ) ),
    0 ),
  dns.eval_2_3= diff.fc_jsonModify(dns.eval_2_3,
    'is_TRR',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ) ) ),
    0 ),
  dns.eval_2_4= diff.fc_jsonModify(dns.eval_2_4,
    'is_TRR',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_2)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ) ) ),
    0 ),
  dns.eval_3_4= diff.fc_jsonModify(dns.eval_3_4,
    'is_TRR',
    diff.fc_sim_array(CONCAT(ifnull(json_value(json_extract_array(dns.in_3)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ),'|', ifnull(json_value(json_extract_array(dns.in_4)[
          OFFSET
            (0)],
            '$.is_TRR'),
          '' ) ) ),
    0 )
WHERE
  TRUE;
  -- EVAL ALL ADDRESSES
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  dns.eval_all= (
  SELECT
    diff.fc_jsonModify(dns.eval_all,
      'addresses',
      CAST(ROUND(AVG(Estimate), 2) AS numeric),
      0)
  FROM
    UNNEST([ CAST(json_value(json_extract_array(dns.eval_0_1)[
        OFFSET
          (0)],
          '$.addresses')AS numeric), CAST(json_value(json_extract_array(dns.eval_0_1)[
        OFFSET
          (0)],
          '$.addresses') AS numeric), CAST(json_value(json_extract_array(dns.eval_0_2)[
        OFFSET
          (0)],
          '$.addresses')AS numeric), CAST(json_value(json_extract_array(dns.eval_0_3)[
        OFFSET
          (0)],
          '$.addresses')AS numeric), CAST(json_value(json_extract_array(dns.eval_0_4)[
        OFFSET
          (0)],
          '$.addresses')AS numeric), CAST(json_value(json_extract_array(dns.eval_1_2)[
        OFFSET
          (0)],
          '$.addresses')AS numeric), CAST(json_value(json_extract_array(dns.eval_1_3)[
        OFFSET
          (0)],
          '$.addresses')AS numeric), CAST(json_value(json_extract_array(dns.eval_1_4)[
        OFFSET
          (0)],
          '$.addresses')AS numeric), CAST(json_value(json_extract_array(dns.eval_2_3)[
        OFFSET
          (0)],
          '$.addresses')AS numeric), CAST(json_value(json_extract_array(dns.eval_3_4)[
        OFFSET
          (0)],
          '$.addresses')AS numeric)]) Estimate )
WHERE
  TRUE;





  -- EVAL ALL used_address
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  dns.eval_all= (
  SELECT
    diff.fc_jsonModify(dns.eval_all,
      'used_address',
      CAST(ROUND(AVG(Estimate), 2) AS numeric),
      0)
  FROM
    UNNEST([ CAST(json_value(json_extract_array(dns.eval_0_1)[
        OFFSET
          (0)],
          '$.used_address')AS numeric), CAST(json_value(json_extract_array(dns.eval_0_1)[
        OFFSET
          (0)],
          '$.used_address') AS numeric), CAST(json_value(json_extract_array(dns.eval_0_2)[
        OFFSET
          (0)],
          '$.used_address')AS numeric), CAST(json_value(json_extract_array(dns.eval_0_3)[
        OFFSET
          (0)],
          '$.used_address')AS numeric), CAST(json_value(json_extract_array(dns.eval_0_4)[
        OFFSET
          (0)],
          '$.used_address')AS numeric), CAST(json_value(json_extract_array(dns.eval_1_2)[
        OFFSET
          (0)],
          '$.used_address')AS numeric), CAST(json_value(json_extract_array(dns.eval_1_3)[
        OFFSET
          (0)],
          '$.used_address')AS numeric), CAST(json_value(json_extract_array(dns.eval_1_4)[
        OFFSET
          (0)],
          '$.used_address')AS numeric), CAST(json_value(json_extract_array(dns.eval_2_3)[
        OFFSET
          (0)],
          '$.used_address')AS numeric), CAST(json_value(json_extract_array(dns.eval_3_4)[
        OFFSET
          (0)],
          '$.used_address')AS numeric)]) Estimate )
WHERE
  TRUE;







  -- EVAL ALL canonical_name
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  dns.eval_all= (
  SELECT
    diff.fc_jsonModify(dns.eval_all,
      'canonical_name',
      CAST(ROUND(AVG(Estimate), 2) AS numeric),
      0)
  FROM
    UNNEST([ CAST(json_value(json_extract_array(dns.eval_0_1)[
        OFFSET
          (0)],
          '$.canonical_name')AS numeric), CAST(json_value(json_extract_array(dns.eval_0_1)[
        OFFSET
          (0)],
          '$.canonical_name') AS numeric), CAST(json_value(json_extract_array(dns.eval_0_2)[
        OFFSET
          (0)],
          '$.canonical_name')AS numeric), CAST(json_value(json_extract_array(dns.eval_0_3)[
        OFFSET
          (0)],
          '$.canonical_name')AS numeric), CAST(json_value(json_extract_array(dns.eval_0_4)[
        OFFSET
          (0)],
          '$.canonical_name')AS numeric), CAST(json_value(json_extract_array(dns.eval_1_2)[
        OFFSET
          (0)],
          '$.canonical_name')AS numeric), CAST(json_value(json_extract_array(dns.eval_1_3)[
        OFFSET
          (0)],
          '$.canonical_name')AS numeric), CAST(json_value(json_extract_array(dns.eval_1_4)[
        OFFSET
          (0)],
          '$.canonical_name')AS numeric), CAST(json_value(json_extract_array(dns.eval_2_3)[
        OFFSET
          (0)],
          '$.canonical_name')AS numeric), CAST(json_value(json_extract_array(dns.eval_3_4)[
        OFFSET
          (0)],
          '$.canonical_name')AS numeric)]) Estimate )
WHERE
  TRUE;





  -- EVAL ALL is_TRR
UPDATE
  `your-bigquery-data-set.diff.tree_by_chain` t1
SET
  dns.eval_all= (
  SELECT
    diff.fc_jsonModify(dns.eval_all,
      'is_TRR',
      CAST(ROUND(AVG(Estimate), 2) AS numeric),
      0)
  FROM
    UNNEST([ CAST(json_value(json_extract_array(dns.eval_0_1)[
        OFFSET
          (0)],
          '$.is_TRR')AS numeric), CAST(json_value(json_extract_array(dns.eval_0_1)[
        OFFSET
          (0)],
          '$.is_TRR') AS numeric), CAST(json_value(json_extract_array(dns.eval_0_2)[
        OFFSET
          (0)],
          '$.is_TRR')AS numeric), CAST(json_value(json_extract_array(dns.eval_0_3)[
        OFFSET
          (0)],
          '$.is_TRR')AS numeric), CAST(json_value(json_extract_array(dns.eval_0_4)[
        OFFSET
          (0)],
          '$.is_TRR')AS numeric), CAST(json_value(json_extract_array(dns.eval_1_2)[
        OFFSET
          (0)],
          '$.is_TRR')AS numeric), CAST(json_value(json_extract_array(dns.eval_1_3)[
        OFFSET
          (0)],
          '$.is_TRR')AS numeric), CAST(json_value(json_extract_array(dns.eval_1_4)[
        OFFSET
          (0)],
          '$.is_TRR')AS numeric), CAST(json_value(json_extract_array(dns.eval_2_3)[
        OFFSET
          (0)],
          '$.is_TRR')AS numeric), CAST(json_value(json_extract_array(dns.eval_3_4)[
        OFFSET
          (0)],
          '$.is_TRR')AS numeric)]) Estimate )
WHERE
  TRUE;


/*, rank_bucket*/
ALTER TABLE
  `diff.tree_by_chain` ADD COLUMN
IF NOT EXISTS rank_bucket int;
UPDATE
  diff.tree_by_chain
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

  