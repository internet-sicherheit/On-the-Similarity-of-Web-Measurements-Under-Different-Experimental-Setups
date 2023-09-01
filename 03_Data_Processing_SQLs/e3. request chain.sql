-- This is the SQL used to generate the results for dependency of the nodes (request chain).

  --e3.1
SELECT
  freq.seen_in_profiles,
  COUNT(*) ct,
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain )
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
GROUP BY
  freq.seen_in_profiles
ORDER BY
  freq.seen_in_profiles; /*,
  -- e3.1.1 uniq req chain depth>1*/
SELECT
  freq.seen_in_profiles,
  COUNT(*) ct,
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    depth>1 )
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  depth>1
GROUP BY
  freq.seen_in_profiles
ORDER BY
  freq.seen_in_profiles; /*,
  -- e3.2 frequence OF depth BY seen_in_profiles*/
SELECT
  freq.seen_in_profiles,
  depth,
  COUNT(*) ct,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain t2
  WHERE
    t2.freq.seen_in_profiles=t1.freq.seen_in_profiles ) AS total,
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain t2
  WHERE
    t2.freq.seen_in_profiles=t1.freq.seen_in_profiles ) AS pct
FROM
  `your-bigquery-data-set.diff.tree_by_chain` t1
GROUP BY
  depth,
  freq.seen_in_profiles
ORDER BY
  seen_in_profiles DESC,
  depth ASC; /*,
  /*,
  -- e3.5 children overview*/
SELECT
  AVG(children_count) avg,
  MIN(children_count) min,
  MAX(children_count) max,
  stddev(children_count) sd
FROM
  `your-bigquery-data-set.diff.tree_by_parent`; 
  /*,
  -- e3.5.1 nodes w1th 1 or 0 child */

  
  SELECT
  COUNT(*) one_or_no_child,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_parent)
FROM
  `your-bigquery-data-set.diff.tree_by_parent`
WHERE
  (children_count=1
    OR children_count=0)
  AND tree_depth>0;
  
  
  
  /*,
  --e3.6 number OF children depending 0n depth */
SELECT
  AVG(children_count) avg,
  MIN(children_count) min,
  MAX(children_count) max,
  stddev(children_count) sd,
  tree_depth
FROM
  `your-bigquery-data-set.diff.tree_by_parent`
GROUP BY
  tree_depth
ORDER BY
  tree_depth; /*,
  --e3.7 number OF children W1TH >0 */
SELECT
  AVG(children_count) avg,
  MIN(children_count) min,
  MAX(children_count) max,
  stddev(children_count) sd,
  tree_depth
FROM
  `your-bigquery-data-set.diff.tree_by_parent`
WHERE
  children_count>0
GROUP BY
  tree_depth
ORDER BY
  tree_depth; /*,
  -- e3.8 similartiy OF children */
SELECT
  AVG(children.sim_all) s_avg,
  MAX(children.sim_all) s_max,
  MIN(children.sim_all) s_min,
  stddev(children.sim_all) s_dev
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  children.ct_0>0
  OR children.ct_1>0
  OR children.ct_2>0
  OR children.ct_3>0
  OR children.ct_4>0 ; /*,
  -- e3.9 similarity BY depth */
SELECT
  AVG(children.sim_all) avg,
  MIN(children.sim_all) min,
  MAX(children.sim_all) max,
  stddev(children.sim_all) sd,
  depth
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  children.ct_0>0
  OR children.ct_1>0
  OR children.ct_2>0
  OR children.ct_3>0
  OR children.ct_4>0
GROUP BY
  depth
ORDER BY
  depth; -- e3.10 similarity WH€N nodes are IN ALL profiles */
SELECT
  AVG(children.sim_all) avg,
  MIN(children.sim_all) min,
  MAX(children.sim_all) max,
  stddev(children.sim_all) sd,
  depth
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  freq.seen_in_profiles=5
GROUP BY
  depth
ORDER BY
  depth; /*,
  -- e3.11 ANALYSIS 0N 1st Level PARENTS - similarity*/
SELECT
  AVG(parent.eval_all) s_avg,
  MAX(parent.eval_all) s_max,
  MIN(parent.eval_all) s_min,
  stddev(parent.eval_all) s_dev
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  freq.seen_in_profiles=5 --AND ARRAY_LENGTH(SPLIT(parent.in_1,','))=1
  AND depth>1; /*,
  --nodes that have sim =1*/ -- e3.12
SELECT
  ct_exact_same,
  ct_total,
  ct_exact_same/ct_total
FROM (
  SELECT
    ct_exact_same,
    (
    SELECT
      COUNT(*)
    FROM
      `your-bigquery-data-set.diff.tree_by_chain`
    WHERE
      freq.seen_in_profiles=5
      AND ARRAY_LENGTH(SPLIT(parent.in_0,','))=1
      AND ARRAY_LENGTH(SPLIT(parent.in_1,','))=1
      AND ARRAY_LENGTH(SPLIT(parent.in_2,','))=1
      AND ARRAY_LENGTH(SPLIT(parent.in_3,','))=1
      AND ARRAY_LENGTH(SPLIT(parent.in_4,','))=1) ct_total
  FROM (
    SELECT
      COUNT(*) ct_exact_same
    FROM
      `your-bigquery-data-set.diff.tree_by_chain`
    WHERE
      freq.seen_in_profiles=5
      AND ARRAY_LENGTH(SPLIT(parent.in_0,','))=1
      AND ARRAY_LENGTH(SPLIT(parent.in_1,','))=1
      AND ARRAY_LENGTH(SPLIT(parent.in_2,','))=1
      AND ARRAY_LENGTH(SPLIT(parent.in_3,','))=1
      AND ARRAY_LENGTH(SPLIT(parent.in_4,','))=1
      AND parent.eval_all=1 ) ); /*,
  --e13.12.0*/
SELECT
  COUNT(*) scope,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain )
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  freq.seen_in_profiles=5
  AND depth>1; /*e13.12.1 nodes that have same parent*/
SELECT
  ct_exact_same,
  ct_total,
  ct_exact_same/ct_total
FROM (
  SELECT
    ct_exact_same,
    (
    SELECT
      COUNT(*) ct_exact_same
    FROM
      `your-bigquery-data-set.diff.tree_by_chain`
    WHERE
      freq.seen_in_profiles=5
      AND depth>1 ) ct_total
  FROM (
    SELECT
      COUNT(*) ct_exact_same
    FROM
      `your-bigquery-data-set.diff.tree_by_chain`
    WHERE
      freq.seen_in_profiles=5
      AND parent.eval_all=1
      AND depth>1 ) ); /*,
  e13.12.2 sim OF parents grouped*/
SELECT
  'low sim' label,
  ct_exact_same,
  ct_total,
  ct_exact_same/ct_total pct
FROM (
  SELECT
    ct_exact_same,
    (
    SELECT
      COUNT(*) ct_exact_same
    FROM
      `your-bigquery-data-set.diff.tree_by_chain`
    WHERE
      freq.seen_in_profiles=5
      AND depth>1 ) ct_total
  FROM (
    SELECT
      COUNT(*) ct_exact_same
    FROM
      `your-bigquery-data-set.diff.tree_by_chain`
    WHERE
      freq.seen_in_profiles=5
      AND parent.eval_all<0.3
      AND depth>1 ) )
UNION ALL
SELECT
  'medium sim' label,
  ct_exact_same,
  ct_total,
  ct_exact_same/ct_total
FROM (
  SELECT
    ct_exact_same,
    (
    SELECT
      COUNT(*) ct_exact_same
    FROM
      `your-bigquery-data-set.diff.tree_by_chain`
    WHERE
      freq.seen_in_profiles=5
      AND depth>1 ) ct_total
  FROM (
    SELECT
      COUNT(*) ct_exact_same
    FROM
      `your-bigquery-data-set.diff.tree_by_chain`
    WHERE
      freq.seen_in_profiles=5
      AND parent.eval_all>=0.3
      AND parent.eval_all<0.8
      AND depth>1 ) )
UNION ALL
SELECT
  'high sim' label,
  ct_exact_same,
  ct_total,
  ct_exact_same/ct_total
FROM (
  SELECT
    ct_exact_same,
    (
    SELECT
      COUNT(*) ct_exact_same
    FROM
      `your-bigquery-data-set.diff.tree_by_chain`
    WHERE
      freq.seen_in_profiles=5
      AND depth>1 ) ct_total
  FROM (
    SELECT
      COUNT(*) ct_exact_same
    FROM
      `your-bigquery-data-set.diff.tree_by_chain`
    WHERE
      freq.seen_in_profiles=5
      AND parent.eval_all>=0.8
      AND depth>1 ) ); /*,
  -- e3.13 nodes that are NOT same?*/
SELECT
  AVG(parent.eval_all)
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  freq.seen_in_profiles=5 --
  AND ARRAY_LENGTH(SPLIT(parent.in_0,','))=1 --
  AND ARRAY_LENGTH(SPLIT(parent.in_1,','))=1 --
  AND ARRAY_LENGTH(SPLIT(parent.in_2,','))=1 --
  AND ARRAY_LENGTH(SPLIT(parent.in_3,','))=1 --
  AND ARRAY_LENGTH(SPLIT(parent.in_4,','))=1
  AND parent.eval_all!=1
  AND depth>1 ; /*,
  -- e3.14 nodes that are NOT same > SIM: First-party
  OR third-party?*/
SELECT
  AVG(parent.eval_all),
  meta.is_third_party
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  freq.seen_in_profiles=5 --
  AND ARRAY_LENGTH(SPLIT(parent.in_0,','))=1 --
  AND ARRAY_LENGTH(SPLIT(parent.in_1,','))=1 --
  AND ARRAY_LENGTH(SPLIT(parent.in_2,','))=1 --AND ARRAY_LENGTH(SPLIT(parent.in_3,','))=1 --
  AND ARRAY_LENGTH(SPLIT(parent.in_4,','))=1
  AND parent.eval_all!=1
  AND depth>1
GROUP BY
  meta.is_third_party; /*,
  -- e3.15 nodes that are NOT same > SIM: resource_type ?*/
SELECT
  AVG(parent.eval_all),
  meta.resource_type,
  COUNT(*) ct,
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    freq.seen_in_profiles=5
    AND depth>1 ) pct
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  freq.seen_in_profiles=5 --
  AND ARRAY_LENGTH(SPLIT(parent.in_0,','))=1 --
  AND ARRAY_LENGTH(SPLIT(parent.in_1,','))=1 --
  AND ARRAY_LENGTH(SPLIT(parent.in_2,','))=1 --
  AND ARRAY_LENGTH(SPLIT(parent.in_3,','))=1 --
  AND ARRAY_LENGTH(SPLIT(parent.in_4,','))=1
  AND parent.eval_all!=1
  AND depth>1
GROUP BY
  meta.resource_type
ORDER BY
  AVG(parent.eval_all) DESC