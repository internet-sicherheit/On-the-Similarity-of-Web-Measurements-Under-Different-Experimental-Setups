-- This is the SQL used to generate the results when comparing sim1 vs. sim2.

  /*,
  0: openwpm_desktop,
  1: openwpm_interaction_1,
  2: openwpm_interaction_2,
  3: openwpm_interaction_old,
  4: openwpmheadless_interaction */ /*,
  --e5.1 volume OF nodes*/
SELECT
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    freq.in_1>0) sim1,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    freq.in_2>0) sim2; /*,
  -- e5.2 volume OF third-partys */
SELECT
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    freq.in_1>0
    AND meta.is_third_party ) sim1,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    freq.in_2>0
    AND meta.is_third_party) sim2; /*,
  --e5.3 max depths */
SELECT
  (
  SELECT
    MAX(depth)
  FROM
    diff.tree_by_chain
  WHERE
    freq.in_1>0 ) sim1,
  (
  SELECT
    MAX(depth)
  FROM
    diff.tree_by_chain
  WHERE
    freq.in_2>0 ) sim; -- e5.4 avg OF depth profiles
SELECT
  (
  SELECT
    AVG(depth)
  FROM
    diff.tree_by_chain
  WHERE
    freq.in_1>0 ) sim1,
  (
  SELECT
    AVG(depth)
  FROM
    diff.tree_by_chain
  WHERE
    freq.in_2>0 ) sim2; /*,
  -- e5.5 avg number OF children*/
SELECT
  (
  SELECT
    AVG(children.ct_1)
  FROM
    diff.tree_by_chain
  WHERE
    freq.in_1>0 ) sim1,
  (
  SELECT
    AVG(children.ct_2)
  FROM
    diff.tree_by_chain
  WHERE
    freq.in_2>0 ) sim2; /*,
  -- e5.6 sim avg OF children IN both profiles*/
SELECT
  AVG(children.sim_1_2) avg,
  MIN(children.sim_1_2) min,
  MAX(children.sim_1_2) max,
  stddev(children.sim_1_2) std
FROM
  diff.tree_by_chain
WHERE
  freq.in_1>0
  AND freq.in_2>0
  AND (children.ct_1>0
    OR children.ct_2>0 ); /*,
  --e5.7 sim BY depth*/
SELECT
  depth,
  AVG(children.sim_1_2) avg,
  MIN(children.sim_1_2) min,
  MAX(children.sim_1_2) max,
  stddev(children.sim_1_2) std
FROM
  diff.tree_by_chain
WHERE
  freq.in_1>0
  OR freq.in_2>0
GROUP BY
  depth
ORDER BY
  depth; /*,
  -- e5.8 sim   first and  third partys? */
SELECT
  ct,
  sim,
  round(ct/(
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain t1
  WHERE
    freq.in_1>0
    AND freq.in_2>0
    AND (children.ct_1>0
      OR children.ct_2>0 )
    AND t1.meta.is_third_party=t.is_third_party),2) pct,
  is_third_party
FROM (
  SELECT
    COUNT(*) ct,
    ROUND(children.sim_1_2,1) sim,
    meta.is_third_party AS is_third_party
  FROM
    diff.tree_by_chain
  WHERE
    (children.ct_1>0
      OR children.ct_2>0 )
    AND freq.in_1>0
    AND freq.in_2>0
  GROUP BY
    ROUND(children.sim_1_2,1),
    meta.is_third_party) t
ORDER BY
  is_third_party,
  sim; /*,
  -- e5.9 - uniq nodes first party vs. third party */
SELECT
  COUNT(*),
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    `your-bigquery-data-set.diff.tree_by_chain` t2
  WHERE
    freq.in_2>0
    AND freq.in_1=0),
  meta.is_third_party
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  freq.in_2>0
  AND freq.in_1=0
GROUP BY
  meta.is_third_party; /*,
  -- e5.10 - uniq nodes is_tracker? */
SELECT
  COUNT(*),
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    `your-bigquery-data-set.diff.tree_by_chain` t2
  WHERE
    freq.in_2>0
    AND freq.in_1=0),
  meta.is_tracker
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  freq.in_2>0
  AND freq.in_1=0
GROUP BY
  meta.is_tracker;