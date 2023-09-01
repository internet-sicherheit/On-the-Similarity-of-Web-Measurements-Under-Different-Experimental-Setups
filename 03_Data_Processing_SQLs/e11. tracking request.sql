-- This SQL is used to generate the results for tracking requests.

  /*,
  --e11.0 volume tracking requests*/
SELECT
  *,
  ROUND(tracker/total,2) pct
FROM (
  SELECT
    COUNT(*) tracker,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain ) total
  FROM
    diff.tree_by_chain
  WHERE
    meta.is_tracker); /*,
  --e11.1 avg children OF tracking requests */
SELECT
  COUNT(*),
  AVG(children.ct_avg_all),
  meta.is_tracker
FROM
  diff.tree_by_chain
WHERE
  children.ct_0>0
  OR children.ct_1>0
  OR children.ct_2>0
  OR children.ct_3>0
  OR children.ct_4>0
GROUP BY
  meta.is_tracker; /*,
  e11.1 sim OF children*/
SELECT
  'is tracker' AS label,
  AVG(children.sim_all) avg,
  MIN(children.sim_all) min,
  MAX(children.sim_all) max,
  stddev(children.sim_all) sd
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  meta.is_tracker
  AND ( children.ct_0>0
    OR children.ct_1>0
    OR children.ct_2>0
    OR children.ct_3>0
    OR children.ct_4>0)
UNION ALL
SELECT
  'not tracker' AS label,
  AVG(children.sim_all) avg,
  MIN(children.sim_all) min,
  MAX(children.sim_all) max,
  stddev(children.sim_all) sd
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  meta.is_tracker=FALSE
  AND ( children.ct_0>0
    OR children.ct_1>0
    OR children.ct_2>0
    OR children.ct_3>0
    OR children.ct_4>0); /*,
  -e11.3 sim OF parent */
SELECT
  'is tracker' AS label,
  AVG(parent.eval_all) avg,
  MIN(parent.eval_all) min,
  MAX(parent.eval_all) max,
  stddev(parent.eval_all) sd
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  meta.is_tracker
UNION ALL
SELECT
  'not tracker' AS label,
  AVG(parent.eval_all) avg,
  MIN(parent.eval_all) min,
  MAX(parent.eval_all) max,
  stddev(parent.eval_all) sd
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  meta.is_tracker=FALSE; /*,
  --e11.4 distribution OF trackers IN depths*/
SELECT
  tracker,
  total,
  depth,
  ROUND(tracker/total,2) pct
FROM (
  SELECT
    COUNT(*) tracker,
    depth,
    (
    SELECT
      COUNT(*) total
    FROM
      diff.tree_by_chain
    WHERE
      meta.is_tracker) total
  FROM
    diff.tree_by_chain
  WHERE
    meta.is_tracker
  GROUP BY
    depth
  ORDER BY
    depth); /*,
  --e11.5,
  are parents also tracking requests*/
SELECT
  COUNT(*) total,
  ROUND(COUNT(*)/(
    SELECT
      COUNT(*) total
    FROM
      diff.tree_by_parent
    WHERE
      meta.is_tracker ),2) pct,
  parent_meta.is_tracker AS is_tracker
FROM
  diff.tree_by_parent
WHERE
  meta.is_tracker
  AND tree_depth>1
GROUP BY
  parent_meta.is_tracker; /*,
  e11.6 are parents first 0r third party?*/
SELECT
  COUNT(*) total,
  ROUND(COUNT(*)/(
    SELECT
      COUNT(*) total
    FROM
      diff.tree_by_parent
    WHERE
      meta.is_tracker ),2) pct,
  parent_meta.is_third_party AS is_third_party
FROM
  diff.tree_by_parent
WHERE
  meta.is_tracker
  AND tree_depth>1
GROUP BY
  parent_meta.is_third_party; /*,
  --e11.7,
  which resources trigger tracking nodes*/
SELECT
  COUNT(*) total,
  ROUND(COUNT(*)/(
    SELECT
      COUNT(*) total
    FROM
      diff.tree_by_parent
    WHERE
      meta.is_tracker ),2) pct,
  parent_meta.resource_type AS resource_type
FROM
  diff.tree_by_parent
WHERE
  meta.is_tracker
  AND tree_depth>1
GROUP BY
  parent_meta.resource_type
ORDER BY
  pct; /*,
  --e11.8 resource type first-
  OR third party?*/
SELECT
  COUNT(*) total,
  ROUND(COUNT(*)/(
    SELECT
      COUNT(*) total
    FROM
      diff.tree_by_parent
    WHERE
      meta.is_tracker ),2) pct,
  parent_meta.is_third_party is_third_party,
  parent_meta.resource_type AS resource_type
FROM
  diff.tree_by_parent
WHERE
  meta.is_tracker
  AND tree_depth>1
GROUP BY
  parent_meta.resource_type,
  parent_meta.is_third_party
ORDER BY
  pct; /*,
  -- e11.9 chain_meta differences BETWEEN first-party
  AND third-party triggering*/
WITH
  stats_total AS (
  SELECT
    COUNT(*) total_tracker,
    browser_visit
  FROM
    diff.tree_by_parent
  WHERE
    meta.is_tracker
  GROUP BY
    browser_visit)
SELECT
  SAFE_DIVIDE(triggered_tracker,
    total_tracker) pct,
  browser_visit,
  has_third_party_parent,
  triggered_tracker,
  total_tracker
FROM (
  SELECT
    COUNT(*)+SUM(sub_nodes.total_tracker) triggered_tracker,
    chain_meta.has_third_party_parent,
    t1.browser_visit browser_visit,
    s1.total_tracker
  FROM
    diff.tree_by_parent t1
  INNER JOIN
    stats_total s1
  ON
    s1.browser_visit=t1.browser_visit
  WHERE
    meta.is_tracker
    AND chain_meta.has_tracker_parent=FALSE
  GROUP BY
    chain_meta.has_third_party_parent,
    t1.browser_visit,
    s1.total_tracker )
ORDER BY
  browser_visit,
  has_third_party_parent;
CREATE OR REPLACE TABLE
  diff.tmp_tracker_first AS
SELECT
  *
FROM
  `your-bigquery-data-set._c5b6574eae1819b16fd596d2b4a5a5ca709574cb.anona83e36efe48f6774c03dc12c5100d5eaf69dc128` ; --replace this
WITH
  above temp TABLE
INSERT INTO
  diff.tmp_tracker_first
SELECT
  0 AS pct,
  browser_visit,
  FALSE has_third_party_parent,
  triggered_tracker,
  total_tracker
FROM
  diff.tmp_tracker_first
WHERE
  has_third_party_parent=TRUE
  AND pct=1.0;
INSERT INTO
  diff.tmp_tracker_first
SELECT
  0 AS pct,
  browser_visit,
  TRUE has_third_party_parent,
  triggered_tracker,
  total_tracker
FROM
  diff.tmp_tracker_first
WHERE
  has_third_party_parent=FALSE
  AND pct=1.0; -- this the result!
SELECT
  AVG(pct) avg,
  MIN(pct) min,
  MAX(pct) max,
  stddev(pct) stdev,
  has_third_party_parent
FROM
  diff.tmp_tracker_first
GROUP BY
  has_third_party_parent; /*,
  e11.10 only requests BY third-party*/
SELECT
  AVG(total_tracker) avg_total_tracker,
  COUNT(*),
  has_third_party_parent,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tmp_tracker_first)
FROM
  diff.tmp_tracker_first
WHERE
  pct=1.0
GROUP BY
  has_third_party_parent