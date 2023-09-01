-- This is the SQL used to generate the results for the general overview section of the paper.

  -- e0.1 deviation OF visits
SELECT
  AVG(diff) avg,
  MAX(diff) max,
  MIN(diff) min,
  stddev(diff) stdev
FROM (
  SELECT
    DATE_DIFF(start_time,(
      SELECT
        start_time
      FROM
        diff.visits
      WHERE
        visit_id=t1.visit_id
        AND browser_id='openwpm_desktop'
        AND in_scope=TRUE ),second) diff
  FROM
    `your-bigquery-data-set.diff.visits` t1
  WHERE
    in_scope=TRUE
    AND browser_id='openwpm_interaction_1'); /*,
  -- e.1 scope*/
SELECT
  COUNT(*)
FROM (
  SELECT
    COUNT(*) AS sites
  FROM
    diff.visits
  GROUP BY
    site_id);
SELECT
  COUNT(*)
FROM (
  SELECT
    COUNT(*) AS visits
  FROM
    diff.visits
  GROUP BY
    visit_id); /*,
  -- e1.1 number OF identified pages*/
SELECT
  SUM(subpages_count) s_sum,
  AVG(subpages_count) s_avg
FROM
  diff.sites; /*,
  ,
  ,
  e1.2 total visits*/
WITH
  visits AS (
  SELECT
    browser_id,
    COUNT(*) ct
  FROM
    diff.visits
  WHERE
    in_scope=TRUE
  GROUP BY
    browser_id)
SELECT
  AVG(ct) s_avg,
  MAX(ct ) s_max,
  MIN(ct) s_min,
  stddev(ct) s_dev
FROM
  visits; /*,
  e1.3 total page visits*/
SELECT
  COUNT(*)
FROM
  diff.visits
WHERE
  in_scope=TRUE; /*,
  e1.4 sites BY ALL profiles */
SELECT
  COUNT(*)
FROM
  `your-bigquery-data-set.diff.sites`
WHERE
  in_scope IS TRUE;/*,
  e1.5 visits BY ALL profiles */
SELECT
  SUM(subpages_count)
FROM
  `your-bigquery-data-set.diff.sites`
WHERE
  in_scope IS TRUE; /*,
  e1.6 - depth stats*/
SELECT
  AVG(depth) avg_depth,
  stddev(depth) st_depth,
  MIN(depth) min_depth,
  MAX(depth) max_depth,
  AVG(breadth) avg_children,
  stddev(breadth) std_children,
  MIN(breadth) min_children,
  MAX(breadth) max_children,
FROM (
  SELECT
    browser_id,
    MAX(tree_depth) depth,
    MAX(children_count) breadth,
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`
  GROUP BY
    browser_id,
    visit_id );/*,
--e1.6.2 breadth*/
SELECT
  AVG(breadth) avg,
  min(breadth) min,
  max(breadth) max,
  stddev(breadth) stdev
FROM (
  SELECT
    MAX(breadth) breadth
  FROM (
    SELECT
      browser_visit,
      tree_depth tree_depth,
     count(*) breadth,
    FROM
      `your-bigquery-data-set.diff.tree_by_parent`
    GROUP BY
      browser_visit,
      tree_depth)
  GROUP BY
    browser_visit)
     /*,
  e1.7 tree node numbers */
SELECT
  AVG(ct) savg,
  stddev(ct) stdv,
  MAX(ct) smax,
  MIN(ct) smin
FROM (
  SELECT
    COUNT(*) ct
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`
  GROUP BY
    visit_id,
    browser_id); /*,
  e1.8 frequency OF DISTINCT nodes*/
SELECT
  AVG(in_profiles) s_avg,
  MAX(in_profiles ) s_max,
  MIN(in_profiles) s_min,
  stddev(in_profiles) s_dev
FROM
  `your-bigquery-data-set.diff.tree_eval_url`; /*,
  e1.9 nodes IN ALL profiels */
SELECT
  COUNT(*) ct,
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    diff.tree_eval_url) pct
FROM
  diff.tree_eval_url
WHERE
  in_profiles=5; /*,
  e1.10 nodes IN only one profile*/
SELECT
  COUNT(*) ct,
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    diff.tree_eval_url) pct
FROM
  diff.tree_eval_url
WHERE
  in_profiles=1; /*,
  --e1.10 pct OF trees
WITH
  depth<=5
  AND breadth<=33 */
SELECT
  COUNT(*),
  COUNT(*)/1090979 pct
FROM (
  SELECT
    browser_visit,
    MAX(tree_depth) depth,
    MAX(children_count) breadth,
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`
  GROUP BY
    browser_visit)
WHERE
  depth<=5
  AND breadth<=30;