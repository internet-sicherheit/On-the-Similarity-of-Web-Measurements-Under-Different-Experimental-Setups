-- This is the SQL used to generate the results for first and third party nodes.

  /*,
  -- e4.1 first-party level */
SELECT
  COUNT(*) total_third_parties,
  COUNT(*) / (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_parent) pct,
FROM
  diff.tree_by_parent
WHERE
  meta.is_third_party=FALSE; /*,
  -- e4.2 first-party frequency OF appearing */
SELECT
  AVG(freq.seen_in_profiles),
  depth
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  meta.is_third_party=FALSE
GROUP BY
  depth
ORDER BY
  depth; /*,
  -- e4.3 similarity OF children frist party*/
SELECT
  AVG(children.sim_all) s_avg,
  MAX(children.sim_all) s_max,
  MIN(children.sim_all) s_min,
  stddev(children.sim_all) s_dev
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  meta.is_third_party=FALSE
  AND ( children.ct_0>0
    OR children.ct_1>0
    OR children.ct_2>0
    OR children.ct_3>0
    OR children.ct_4>0) ; /*,
  -- e4.10 first-party level - e3.3 deepen analysis*/
SELECT
  COUNT(*) total_third_parties,
  COUNT(*) / (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_parent) pct,
FROM
  diff.tree_by_parent
WHERE
  meta.is_third_party=TRUE; /*,
  -- e4.11 third parties BY their volume*/
SELECT
  meta.etld,
  COUNT(*) total_third_parties,
  COUNT(*) / (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain t2
  WHERE
    meta.is_third_party=TRUE) pct,
FROM
  diff.tree_by_chain t1
WHERE
  meta.is_third_party=TRUE
GROUP BY
  meta.etld
ORDER BY
  total_third_parties DESC; /*,
  -- e4.12 first-party frequency OF appearing */
SELECT
  AVG(freq.seen_in_profiles),
  depth
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  meta.is_third_party=TRUE
GROUP BY
  depth
ORDER BY
  depth; /*,
  -- e4.13 third party - similarity OF children FOR */
SELECT
  AVG(children.sim_all) s_avg,
  MAX(children.sim_all) s_max,
  MIN(children.sim_all) s_min,
  stddev(children.sim_all) s_dev
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  meta.is_third_party=TRUE
  AND ( children.ct_0>0
    OR children.ct_1>0
    OR children.ct_2>0
    OR children.ct_3>0
    OR children.ct_4>0) ; /*,
  --e4.14 domination OF depth-levels BY first vs third-partys*/
SELECT
  COUNT(*),
  depth,
  meta.is_third_party,
  COUNT(*)/ (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain t2
  WHERE
    t1.depth=t2.depth ) ct
FROM
  `your-bigquery-data-set.diff.tree_by_chain` t1
GROUP BY
  depth,
  meta.is_third_party
ORDER BY
  depth; /*,
  --e4.15 number OF children BY depths */
SELECT
  AVG(children.ct_avg_all),
  depth
FROM
  diff.tree_by_chain
WHERE
  meta.is_third_party=TRUE
GROUP BY
  depth
ORDER BY
  depth ASC;
SELECT
  AVG(children.ct_avg_all),
  depth
FROM
  diff.tree_by_chain
WHERE
  meta.is_third_party=FALSE
GROUP BY
  depth
ORDER BY
  depth ASC; /*,
  --e4.14 NO OF children BY first-third party*/



  SELECT
  AVG(children_count),
  meta.is_third_party
FROM
  `your-bigquery-data-set.diff.tree_by_parent`
WHERE
   tree_depth>0
GROUP BY
  meta.is_third_party;



