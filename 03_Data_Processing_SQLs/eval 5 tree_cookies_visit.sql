-- This is SQL used to evaluate similarity of the cookies on webpage level.

CREATE OR REPLACE TABLE
  diff.tree_cookies_per_visit AS
SELECT
  visit_id
FROM
  diff.tree_distinct_cookies
GROUP BY
  visit_id;
ALTER TABLE
  `diff.tree_cookies_per_visit` ADD COLUMN
IF NOT EXISTS name STRUCT< in_0 string,
  in_1 string,
  in_2 string,
  in_3 string,
  in_4 string,
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
  `your-bigquery-data-set.diff.tree_cookies_per_visit` t1
SET
  name.in_0=( 
  SELECT
    ifnull(STRING_AGG(DISTINCT concat(CAST(name AS string),'@',CAST(host AS string) )),
      NULL) 
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_desktop'
    AND t2.visit_id=t1.visit_id ),
  name.in_1=(
  SELECT
    ifnull(STRING_AGG(DISTINCT concat(CAST(name AS string),'@',CAST(host AS string) )),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_1'
    AND t2.visit_id=t1.visit_id ),
  name.in_2=(
  SELECT
    ifnull(STRING_AGG(DISTINCT concat(CAST(name AS string),'@',CAST(host AS string) )),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_2'
    AND t2.visit_id=t1.visit_id ),
  name.in_3=(
  SELECT
    ifnull(STRING_AGG(DISTINCT concat(CAST(name AS string),'@',CAST(host AS string) )),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_old'
    AND t2.visit_id=t1.visit_id ),
  name.in_4=(
  SELECT
    ifnull(STRING_AGG(DISTINCT concat(CAST(name AS string),'@',CAST(host AS string) )),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpmheadless_interaction'
    AND t2.visit_id=t1.visit_id )
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_cookies_per_visit` t1
SET
  name.sim_0_1= diff.fc_sim_array(CONCAT(ifnull(name.in_0,
        ''),'|', ifnull(name.in_1,
        ''))),
  name.sim_0_2= diff.fc_sim_array(CONCAT(ifnull(name.in_0,
        ''),'|', ifnull(name.in_2,
        ''))),
  name.sim_0_3= diff.fc_sim_array(CONCAT(ifnull(name.in_0,
        ''),'|', ifnull(name.in_3,
        ''))),
  name.sim_0_4= diff.fc_sim_array(CONCAT(ifnull(name.in_0,
        ''),'|', ifnull(name.in_4,
        ''))),
  name.sim_1_2= diff.fc_sim_array(CONCAT(ifnull(name.in_1,
        ''),'|', ifnull(name.in_2,
        ''))),
  name.sim_1_3= diff.fc_sim_array(CONCAT(ifnull(name.in_1,
        ''),'|', ifnull(name.in_3,
        ''))),
  name.sim_1_4= diff.fc_sim_array(CONCAT(ifnull(name.in_1,
        ''),'|', ifnull(name.in_4,
        ''))),
  name.sim_2_2= diff.fc_sim_array(CONCAT(ifnull(name.in_2,
        ''),'|', ifnull(name.in_2,
        ''))),
  name.sim_2_3= diff.fc_sim_array(CONCAT(ifnull(name.in_2,
        ''),'|', ifnull(name.in_3,
        ''))),
  name.sim_2_4= diff.fc_sim_array(CONCAT(ifnull(name.in_2,
        ''),'|', ifnull(name.in_4,
        ''))),
  name.sim_3_4= diff.fc_sim_array(CONCAT(ifnull(name.in_3,
        ''),'|', ifnull(name.in_4,
        ''))) --,
  -- depth.sim_all= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_1,'|', depth.in_2,'|', depth.in_3,'|', depth.in_4))
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_cookies_per_visit` t1
SET
  name.sim_all= (
  SELECT
    CAST(ROUND(AVG(Estimate), 2) AS numeric)
  FROM
    UNNEST([name.sim_0_1, name.sim_0_2, name.sim_0_3, name.sim_0_4, name.sim_1_2, name.sim_1_3, name.sim_1_4, name.sim_2_2, name.sim_2_3, name.sim_2_4, name.sim_3_4]) Estimate )
WHERE
  TRUE;