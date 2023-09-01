-- This SQL is used to create a table that contains only the cookies that are in scope.


CREATE OR REPLACE TABLE
  diff.tmp_cookies AS
SELECT
  ROW_NUMBER() OVER() AS row_id,
  * EXCEPT(id)
FROM
  diff.cookies
WHERE
  in_scope=1;

CREATE OR REPLACE TABLE
  diff.tmp_cookies AS
SELECT
  *,
  NET.REG_DOMAIN(host) host_etld
FROM
  diff.tmp_cookies;


UPDATE
  diff.tmp_cookies c
SET
  is_third_party=(
  SELECT
    cast((c.host_etld = s.site) as int64)
  FROM
    diff.sites s
  WHERE
    c.site_id=s.id)
WHERE
  TRUE; 

 
UPDATE
  diff.tmp_cookies c
SET
  is_third_party=1
  where is_third_party is null;



ALTER TABLE
  `diff.tmp_cookies` ADD COLUMN
IF NOT EXISTS is_tracker bool; -- identifies tracking cookies
UPDATE
  diff.tmp_cookies c
SET
  c.is_tracker = TRUE
WHERE
  LENGTH(CAST(value AS BYTES))>7
  AND DATE_DIFF( expiry, time_stamp, DAY) > 89
  AND TRUE IN(
  SELECT
    ABS(1-(LENGTH(CAST(c2.value AS BYTES))/LENGTH(CAST(c.value AS BYTES))))<0.25
  FROM
    diff.tmp_cookies c2
  WHERE
    c.visit_id=c2.visit_id
    AND c.name=c2.name
    AND c.browser_id!=c2.browser_id ) ; -- sets the rest AS 0
UPDATE
  diff.tmp_cookies
SET
  is_tracker = FALSE
WHERE
  is_tracker IS NULL;
CREATE OR REPLACE TABLE
  diff.tree_distinct_cookies AS
SELECT
  ROW_NUMBER() OVER() AS row_id,
  visit_id,
  name,
  host
FROM
  diff.tmp_cookies
GROUP BY
  name,
  visit_id,
  host;
 
ALTER TABLE
  `diff.tree_distinct_cookies` ADD COLUMN
IF NOT EXISTS meta STRUCT< in_profiles int64,
  is_host_only bool,
  is_third_party bool,
  is_tracker bool,
  is_session bool >;


 

update diff.tree_distinct_cookies c1
set meta.is_tracker=(

select cast(max(cast (is_tracker as int64)) as bool) from diff.tmp_cookies c2 where c1.name=c2.name and c2.host=c2.host and c1.visit_id=c2.visit_id

)
where true;



update diff.tree_distinct_cookies c1
set meta.is_session=(

select cast(max(cast (is_session as int64)) as bool) from diff.tmp_cookies c2 where c1.name=c2.name and c2.host=c2.host and c1.visit_id=c2.visit_id

)
where true;


UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` c1
SET
  meta.in_profiles=(
  SELECT
    COUNT(*)
  FROM (
    SELECT
      browser_id
    FROM
      diff.tmp_cookies c2
    WHERE
      c1.name=c2.name
      AND c1.host=c2.host
      AND c1.visit_id=c2.visit_id
    GROUP BY
      browser_id) )
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` c1
SET
  meta.is_host_only=(
  SELECT
    DISTINCT CAST(is_host_only AS bool)
  FROM
    diff.tmp_cookies c2
  WHERE
    c1.name=c2.name
    AND c1.host=c2.host
    AND c1.visit_id=c2.visit_id )
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` c1
SET
  meta.is_third_party=(
  SELECT
    DISTINCT CAST(is_third_party AS bool)
  FROM
    diff.tmp_cookies c2
  WHERE
    c1.name=c2.name
    AND c1.host=c2.host
    AND c1.visit_id=c2.visit_id )
WHERE
  TRUE; /*,
  -- CREATE sims*/
ALTER TABLE
  `diff.tree_distinct_cookies` ADD COLUMN
IF NOT EXISTS is_secure STRUCT< in_0 string,
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
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  is_secure.in_0=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_secure AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_desktop'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host),
  is_secure.in_1=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_secure AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_1'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  is_secure.in_2=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_secure AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_2'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  is_secure.in_3=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_secure AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_old'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  is_secure.in_4=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_secure AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpmheadless_interaction'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host )
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  is_secure.sim_0_1= diff.fc_sim_array(CONCAT(ifnull(is_secure.in_0,
        ''),'|', ifnull(is_secure.in_1,
        ''))),
  is_secure.sim_0_2= diff.fc_sim_array(CONCAT(ifnull(is_secure.in_0,
        ''),'|', ifnull(is_secure.in_2,
        ''))),
  is_secure.sim_0_3= diff.fc_sim_array(CONCAT(ifnull(is_secure.in_0,
        ''),'|', ifnull(is_secure.in_3,
        ''))),
  is_secure.sim_0_4= diff.fc_sim_array(CONCAT(ifnull(is_secure.in_0,
        ''),'|', ifnull(is_secure.in_4,
        ''))),
  is_secure.sim_1_2= diff.fc_sim_array(CONCAT(ifnull(is_secure.in_1,
        ''),'|', ifnull(is_secure.in_2,
        ''))),
  is_secure.sim_1_3= diff.fc_sim_array(CONCAT(ifnull(is_secure.in_1,
        ''),'|', ifnull(is_secure.in_3,
        ''))),
  is_secure.sim_1_4= diff.fc_sim_array(CONCAT(ifnull(is_secure.in_1,
        ''),'|', ifnull(is_secure.in_4,
        ''))),
  is_secure.sim_2_2= diff.fc_sim_array(CONCAT(ifnull(is_secure.in_2,
        ''),'|', ifnull(is_secure.in_2,
        ''))),
  is_secure.sim_2_3= diff.fc_sim_array(CONCAT(ifnull(is_secure.in_2,
        ''),'|', ifnull(is_secure.in_3,
        ''))),
  is_secure.sim_2_4= diff.fc_sim_array(CONCAT(ifnull(is_secure.in_2,
        ''),'|', ifnull(is_secure.in_4,
        ''))),
  is_secure.sim_3_4= diff.fc_sim_array(CONCAT(ifnull(is_secure.in_3,
        ''),'|', ifnull(is_secure.in_4,
        ''))) --,
  -- depth.sim_all= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_1,'|', depth.in_2,'|', depth.in_3,'|', depth.in_4))
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  is_secure.sim_all= (
  SELECT
    CAST(ROUND(AVG(Estimate), 2) AS numeric)
  FROM
    UNNEST([is_secure.sim_0_1, is_secure.sim_0_2, is_secure.sim_0_3, is_secure.sim_0_4, is_secure.sim_1_2, is_secure.sim_1_3, is_secure.sim_1_4, is_secure.sim_2_2, is_secure.sim_2_3, is_secure.sim_2_4, is_secure.sim_3_4]) Estimate )
WHERE
  TRUE;
ALTER TABLE
  `diff.tree_distinct_cookies` ADD COLUMN
IF NOT EXISTS is_session STRUCT< in_0 string,
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
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  is_session.in_0=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_session AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_desktop'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host),
  is_session.in_1=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_session AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_1'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  is_session.in_2=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_session AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_2'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  is_session.in_3=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_session AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_old'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  is_session.in_4=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_session AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpmheadless_interaction'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host )
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  is_session.sim_0_1= diff.fc_sim_array(CONCAT(ifnull(is_session.in_0,
        ''),'|', ifnull(is_session.in_1,
        ''))),
  is_session.sim_0_2= diff.fc_sim_array(CONCAT(ifnull(is_session.in_0,
        ''),'|', ifnull(is_session.in_2,
        ''))),
  is_session.sim_0_3= diff.fc_sim_array(CONCAT(ifnull(is_session.in_0,
        ''),'|', ifnull(is_session.in_3,
        ''))),
  is_session.sim_0_4= diff.fc_sim_array(CONCAT(ifnull(is_session.in_0,
        ''),'|', ifnull(is_session.in_4,
        ''))),
  is_session.sim_1_2= diff.fc_sim_array(CONCAT(ifnull(is_session.in_1,
        ''),'|', ifnull(is_session.in_2,
        ''))),
  is_session.sim_1_3= diff.fc_sim_array(CONCAT(ifnull(is_session.in_1,
        ''),'|', ifnull(is_session.in_3,
        ''))),
  is_session.sim_1_4= diff.fc_sim_array(CONCAT(ifnull(is_session.in_1,
        ''),'|', ifnull(is_session.in_4,
        ''))),
  is_session.sim_2_2= diff.fc_sim_array(CONCAT(ifnull(is_session.in_2,
        ''),'|', ifnull(is_session.in_2,
        ''))),
  is_session.sim_2_3= diff.fc_sim_array(CONCAT(ifnull(is_session.in_2,
        ''),'|', ifnull(is_session.in_3,
        ''))),
  is_session.sim_2_4= diff.fc_sim_array(CONCAT(ifnull(is_session.in_2,
        ''),'|', ifnull(is_session.in_4,
        ''))),
  is_session.sim_3_4= diff.fc_sim_array(CONCAT(ifnull(is_session.in_3,
        ''),'|', ifnull(is_session.in_4,
        ''))) --,
  -- depth.sim_all= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_1,'|', depth.in_2,'|', depth.in_3,'|', depth.in_4))
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  is_session.sim_all= (
  SELECT
    CAST(ROUND(AVG(Estimate), 2) AS numeric)
  FROM
    UNNEST([is_session.sim_0_1, is_session.sim_0_2, is_session.sim_0_3, is_session.sim_0_4, is_session.sim_1_2, is_session.sim_1_3, is_session.sim_1_4, is_session.sim_2_2, is_session.sim_2_3, is_session.sim_2_4, is_session.sim_3_4]) Estimate )
WHERE
  TRUE;
ALTER TABLE
  `diff.tree_distinct_cookies` ADD COLUMN
IF NOT EXISTS is_http_only STRUCT< in_0 string,
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
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  is_http_only.in_0=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_http_only AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_desktop'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host),
  is_http_only.in_1=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_http_only AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_1'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  is_http_only.in_2=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_http_only AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_2'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  is_http_only.in_3=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_http_only AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_old'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  is_http_only.in_4=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(is_http_only AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpmheadless_interaction'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host )
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  is_http_only.sim_0_1= diff.fc_sim_array(CONCAT(ifnull(is_http_only.in_0,
        ''),'|', ifnull(is_http_only.in_1,
        ''))),
  is_http_only.sim_0_2= diff.fc_sim_array(CONCAT(ifnull(is_http_only.in_0,
        ''),'|', ifnull(is_http_only.in_2,
        ''))),
  is_http_only.sim_0_3= diff.fc_sim_array(CONCAT(ifnull(is_http_only.in_0,
        ''),'|', ifnull(is_http_only.in_3,
        ''))),
  is_http_only.sim_0_4= diff.fc_sim_array(CONCAT(ifnull(is_http_only.in_0,
        ''),'|', ifnull(is_http_only.in_4,
        ''))),
  is_http_only.sim_1_2= diff.fc_sim_array(CONCAT(ifnull(is_http_only.in_1,
        ''),'|', ifnull(is_http_only.in_2,
        ''))),
  is_http_only.sim_1_3= diff.fc_sim_array(CONCAT(ifnull(is_http_only.in_1,
        ''),'|', ifnull(is_http_only.in_3,
        ''))),
  is_http_only.sim_1_4= diff.fc_sim_array(CONCAT(ifnull(is_http_only.in_1,
        ''),'|', ifnull(is_http_only.in_4,
        ''))),
  is_http_only.sim_2_2= diff.fc_sim_array(CONCAT(ifnull(is_http_only.in_2,
        ''),'|', ifnull(is_http_only.in_2,
        ''))),
  is_http_only.sim_2_3= diff.fc_sim_array(CONCAT(ifnull(is_http_only.in_2,
        ''),'|', ifnull(is_http_only.in_3,
        ''))),
  is_http_only.sim_2_4= diff.fc_sim_array(CONCAT(ifnull(is_http_only.in_2,
        ''),'|', ifnull(is_http_only.in_4,
        ''))),
  is_http_only.sim_3_4= diff.fc_sim_array(CONCAT(ifnull(is_http_only.in_3,
        ''),'|', ifnull(is_http_only.in_4,
        ''))) --,
  -- depth.sim_all= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_1,'|', depth.in_2,'|', depth.in_3,'|', depth.in_4))
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  is_http_only.sim_all= (
  SELECT
    CAST(ROUND(AVG(Estimate), 2) AS numeric)
  FROM
    UNNEST([is_http_only.sim_0_1, is_http_only.sim_0_2, is_http_only.sim_0_3, is_http_only.sim_0_4, is_http_only.sim_1_2, is_http_only.sim_1_3, is_http_only.sim_1_4, is_http_only.sim_2_2, is_http_only.sim_2_3, is_http_only.sim_2_4, is_http_only.sim_3_4]) Estimate )
WHERE
  TRUE;
ALTER TABLE
  `diff.tree_distinct_cookies` ADD COLUMN
IF NOT EXISTS same_site STRUCT< in_0 string,
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
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  same_site.in_0=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(same_site AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_desktop'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host),
  same_site.in_1=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(same_site AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_1'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  same_site.in_2=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(same_site AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_2'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  same_site.in_3=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(same_site AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_old'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  same_site.in_4=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(same_site AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpmheadless_interaction'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host )
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  same_site.sim_0_1= diff.fc_sim_array(CONCAT(ifnull(same_site.in_0,
        ''),'|', ifnull(same_site.in_1,
        ''))),
  same_site.sim_0_2= diff.fc_sim_array(CONCAT(ifnull(same_site.in_0,
        ''),'|', ifnull(same_site.in_2,
        ''))),
  same_site.sim_0_3= diff.fc_sim_array(CONCAT(ifnull(same_site.in_0,
        ''),'|', ifnull(same_site.in_3,
        ''))),
  same_site.sim_0_4= diff.fc_sim_array(CONCAT(ifnull(same_site.in_0,
        ''),'|', ifnull(same_site.in_4,
        ''))),
  same_site.sim_1_2= diff.fc_sim_array(CONCAT(ifnull(same_site.in_1,
        ''),'|', ifnull(same_site.in_2,
        ''))),
  same_site.sim_1_3= diff.fc_sim_array(CONCAT(ifnull(same_site.in_1,
        ''),'|', ifnull(same_site.in_3,
        ''))),
  same_site.sim_1_4= diff.fc_sim_array(CONCAT(ifnull(same_site.in_1,
        ''),'|', ifnull(same_site.in_4,
        ''))),
  same_site.sim_2_2= diff.fc_sim_array(CONCAT(ifnull(same_site.in_2,
        ''),'|', ifnull(same_site.in_2,
        ''))),
  same_site.sim_2_3= diff.fc_sim_array(CONCAT(ifnull(same_site.in_2,
        ''),'|', ifnull(same_site.in_3,
        ''))),
  same_site.sim_2_4= diff.fc_sim_array(CONCAT(ifnull(same_site.in_2,
        ''),'|', ifnull(same_site.in_4,
        ''))),
  same_site.sim_3_4= diff.fc_sim_array(CONCAT(ifnull(same_site.in_3,
        ''),'|', ifnull(same_site.in_4,
        ''))) --,
  -- depth.sim_all= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_1,'|', depth.in_2,'|', depth.in_3,'|', depth.in_4))
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  same_site.sim_all= (
  SELECT
    CAST(ROUND(AVG(Estimate), 2) AS numeric)
  FROM
    UNNEST([same_site.sim_0_1, same_site.sim_0_2, same_site.sim_0_3, same_site.sim_0_4, same_site.sim_1_2, same_site.sim_1_3, same_site.sim_1_4, same_site.sim_2_2, same_site.sim_2_3, same_site.sim_2_4, same_site.sim_3_4]) Estimate )
WHERE
  TRUE;
ALTER TABLE
  `diff.tree_distinct_cookies` ADD COLUMN
IF NOT EXISTS path STRUCT< in_0 string,
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
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  path.in_0=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(path AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_desktop'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host),
  path.in_1=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(path AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_1'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  path.in_2=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(path AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_2'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  path.in_3=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(path AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpm_interaction_old'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host ),
  path.in_4=(
  SELECT
    ifnull(STRING_AGG(DISTINCT CAST(path AS string)),
      NULL)
  FROM
    `your-bigquery-data-set.diff.tmp_cookies`t2
  WHERE
    t2.browser_id='openwpmheadless_interaction'
    AND t2.visit_id=t1.visit_id
    AND t1.name=t2.name
    AND t1.host=t2.host )
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  path.sim_0_1= diff.fc_sim_array(CONCAT(ifnull(path.in_0,
        ''),'|', ifnull(path.in_1,
        ''))),
  path.sim_0_2= diff.fc_sim_array(CONCAT(ifnull(path.in_0,
        ''),'|', ifnull(path.in_2,
        ''))),
  path.sim_0_3= diff.fc_sim_array(CONCAT(ifnull(path.in_0,
        ''),'|', ifnull(path.in_3,
        ''))),
  path.sim_0_4= diff.fc_sim_array(CONCAT(ifnull(path.in_0,
        ''),'|', ifnull(path.in_4,
        ''))),
  path.sim_1_2= diff.fc_sim_array(CONCAT(ifnull(path.in_1,
        ''),'|', ifnull(path.in_2,
        ''))),
  path.sim_1_3= diff.fc_sim_array(CONCAT(ifnull(path.in_1,
        ''),'|', ifnull(path.in_3,
        ''))),
  path.sim_1_4= diff.fc_sim_array(CONCAT(ifnull(path.in_1,
        ''),'|', ifnull(path.in_4,
        ''))),
  path.sim_2_2= diff.fc_sim_array(CONCAT(ifnull(path.in_2,
        ''),'|', ifnull(path.in_2,
        ''))),
  path.sim_2_3= diff.fc_sim_array(CONCAT(ifnull(path.in_2,
        ''),'|', ifnull(path.in_3,
        ''))),
  path.sim_2_4= diff.fc_sim_array(CONCAT(ifnull(path.in_2,
        ''),'|', ifnull(path.in_4,
        ''))),
  path.sim_3_4= diff.fc_sim_array(CONCAT(ifnull(path.in_3,
        ''),'|', ifnull(path.in_4,
        ''))) --,
  -- depth.sim_all= diff.fc_sim_array(CONCAT(depth.in_0,'|', depth.in_1,'|', depth.in_2,'|', depth.in_3,'|', depth.in_4))
WHERE
  TRUE;
UPDATE
  `your-bigquery-data-set.diff.tree_distinct_cookies` t1
SET
  path.sim_all= (
  SELECT
    CAST(ROUND(AVG(Estimate), 2) AS numeric)
  FROM
    UNNEST([path.sim_0_1, path.sim_0_2, path.sim_0_3, path.sim_0_4, path.sim_1_2, path.sim_1_3, path.sim_1_4, path.sim_2_2, path.sim_2_3, path.sim_2_4, path.sim_3_4]) Estimate )
WHERE
  TRUE;





























