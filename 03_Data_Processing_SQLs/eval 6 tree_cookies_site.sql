-- This is SQL used to evaluate similarity of the cookies on site level.

  /*,
  -p1_distribution_of_nodes_by_tree*/ # included IN overleaf
SELECT
  'All' AS label,
  tree_depth
FROM
  `your-bigquery-data-set.diff.tree_by_parent`
WHERE
  browser_id='openwpm_interaction_1'
UNION ALL
SELECT
  'First party' AS label,
  tree_depth
FROM
  `your-bigquery-data-set.diff.tree_by_parent`
WHERE
  browser_id='openwpm_interaction_1'
  AND meta.is_third_party=FALSE
UNION ALL
SELECT
  'Third party' AS label,
  tree_depth
FROM
  `your-bigquery-data-set.diff.tree_by_parent`
WHERE
  browser_id='openwpm_interaction_1'
  AND meta.is_third_party=TRUE
UNION ALL
SELECT
  'Tracking requests' AS label,
  tree_depth
FROM
  `your-bigquery-data-set.diff.tree_by_parent`
WHERE
  browser_id='openwpm_interaction_1'
  AND meta.is_tracker=TRUE
UNION ALL
SELECT
  'Non-tracking requests' AS label,
  tree_depth
FROM
  `your-bigquery-data-set.diff.tree_by_parent`
WHERE
  browser_id='openwpm_interaction_1'
  AND meta.is_tracker=TRUE; /*,
  --p2_number_of_subnodes_by_depth*/ # included IN overleaf
SELECT
  tree_depth AS depth,
  sub_nodes.total subnodes
FROM
  diff.tree_by_parent
WHERE
  tree_depth>0
  AND browser_id='openwpm_interaction_1'; /* depth of nodes by appearaence */
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
  --p2: boxplot tree sizes BY profiles*/
WITH
  myTable AS (
  SELECT
    browser_id,
    MAX(tree_depth) depth,
    MAX(children_count) breadth,
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`
  GROUP BY
    browser_id,
    visit_id )
SELECT
  browser_id,
  depth AS val,
  'Depth' AS label
FROM
  mytable
UNION ALL
SELECT
  browser_id,
  breadth AS val,
  'Breadth' AS label
FROM
  mytable ; /*,
  -- heatmap FOR max depth
  AND breadth */
SELECT
  max_breadth,
  max_depth,
  COUNT(*) count
FROM (
  SELECT
    browser_id,
    visit_id,
    MAX(children_count) max_breadth,
    MAX(tree_depth) max_depth,
  FROM
    diff.tree_by_parent
  GROUP BY
    browser_id,
    visit_id)
GROUP BY
  max_breadth,
  max_depth
ORDER BY
  max_breadth DESC; /*,
  -- RADAR CHART */
WITH
  requests AS (
  SELECT
    COUNT(*) requests,
    browser_id
  FROM
    `your-bigquery-data-set.diff.tmp_requests`
  GROUP BY
    browser_id),
  nodes AS (
  SELECT
    COUNT(*) nodes,
    browser_id
  FROM (
    SELECT
      COUNT(*),
      browser_id
    FROM
      `your-bigquery-data-set.diff.tree_by_parent`
    WHERE
      meta.is_tracker=TRUE
    GROUP BY
      tree_url_hash,
      chain_url_id,
      visit_id,
      browser_id)
  GROUP BY
    browser_id),
  third_party AS (
  SELECT
    COUNT(*) third_party,
    browser_id
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`
  WHERE
    meta.is_third_party=TRUE
  GROUP BY
    browser_id),
  trackers AS (
  SELECT
    COUNT(*) trackers,
    browser_id
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`
  WHERE
    meta.is_tracker=TRUE
  GROUP BY
    browser_id)
SELECT
  t1.browser_id,
  trackers,
  nodes,
  requests,
  third_party
FROM
  trackers t1
INNER JOIN
  third_party AS t2
ON
  t1.browser_id=t2.browser_id
INNER JOIN
  nodes AS t3
ON
  t1.browser_id=t3.browser_id
INNER JOIN
  requests AS t4
ON
  t1.browser_id=t4.browser_id; /*,
  DNS: e10.6*/ --TODO: DNS /*,
  -- number OF grand_children BY depth
SELECT
  tree_depth depth,
  /* AVG(children_all) avg_all_grandchildren,
  MIN(children_all) min_all_grandchildren,
  MAX(children_all) max_all_grandchildren,
  stddev(children_all) stdev_all_grandchildren,
  */
FROM
  diff.tree_by_parent
WHERE
  children_count>0
GROUP BY
  tree_depth
ORDER BY
  tree_depth; /*,
  p5:boxplot similarity BY depth - p5_boxplot_similarity_of_children_parent_by_depth*/
SELECT
  'children' sim_group,
  row_id,
  children.sim_all,
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
  depth,
  row_id,
  children.sim_all
UNION ALL
SELECT
  'parent' sim_group,
  row_id,
  parent.eval_all,
  depth
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  depth>1
GROUP BY
  depth,
  row_id,
  parent.eval_all; /*,
  --densitivy BY depth*/
SELECT
  'All' AS label,
  tree_depth,
  ROUND(scope/ total,5) pct_all
FROM (
  SELECT
    t1.tree_depth,
    scope,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_parent ) total
  FROM (
    SELECT
      COUNT(*) AS scope,
      tree_depth
    FROM
      diff.tree_by_parent
    GROUP BY
      tree_depth) t1
  ORDER BY
    tree_depth);
SELECT
  'Third-Party' AS label,
  tree_depth,
  ROUND(scope/ total,5) pct_third_party
FROM (
  SELECT
    t1.tree_depth,
    scope,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_parent
    WHERE
      meta.is_third_party=TRUE ) total
  FROM (
    SELECT
      COUNT(*) AS scope,
      tree_depth
    FROM
      diff.tree_by_parent
    WHERE
      meta.is_third_party=TRUE
    GROUP BY
      tree_depth) t1
  ORDER BY
    tree_depth);
SELECT
  'Tracker',
  tree_depth,
  ROUND(scope/ total,5) pct_tracker
FROM (
  SELECT
    t1.tree_depth,
    scope,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_parent
    WHERE
      meta.is_tracker=TRUE ) total
  FROM (
    SELECT
      COUNT(*) AS scope,
      tree_depth
    FROM
      diff.tree_by_parent
    WHERE
      meta.is_tracker=TRUE
    GROUP BY
      tree_depth) t1
  ORDER BY
    tree_depth); /*,
  -- p8_sim_nodes_children_parent*/
SELECT
  'children' AS sim_group,
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
UNION ALL
SELECT
  'parent' AS sim_group,
  AVG(parent.eval_all) avg,
  MIN(parent.eval_all) min,
  MAX(parent.eval_all) max,
  stddev(parent.eval_all) sd,
  depth
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  depth>1
GROUP BY
  depth
ORDER BY
  depth; /*,
  p9: distribution OF similarity nodes
  AND parents */
SELECT
  'parent' AS sim_group,
  sim,
  ROUND(ct_exact_same/ct_total,3) pct
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
      AND depth>1 ) ct_total,
    sim
  FROM (
    SELECT
      COUNT(*) ct_exact_same,
      ROUND(parent.eval_all,1) sim
    FROM
      `your-bigquery-data-set.diff.tree_by_chain`
    WHERE
      freq.seen_in_profiles=5
      AND depth>1
    GROUP BY
      ROUND(parent.eval_all,1))
  ORDER BY
    sim)
UNION ALL
SELECT
  'children' sim_group,
  sim,
  ROUND(ct_exact_same/ct_total,3) pct
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
      AND ( children.ct_0>0
        OR children.ct_1>0
        OR children.ct_2>0
        OR children.ct_3>0
        OR children.ct_4>0) ) ct_total,
    sim
  FROM (
    SELECT
      COUNT(*) ct_exact_same,
      ROUND(children.sim_all,1) sim
    FROM
      `your-bigquery-data-set.diff.tree_by_chain`
    WHERE
      freq.seen_in_profiles=5
      AND ( children.ct_0>0
        OR children.ct_1>0
        OR children.ct_2>0
        OR children.ct_3>0
        OR children.ct_4>0)
    GROUP BY
      ROUND(children.sim_all,1))
  ORDER BY
    sim)
ORDER BY
  sim; /*,
  p10_number_of_nodes_per_rank */
SELECT
  'Total nodes' AS label,
  rank_bucket,
  ROUND(AVG(count),0) avg,
  stddev(count) stdev
FROM (
  SELECT
    COUNT(*) count,
    rank_bucket
  FROM
    diff.tree_by_parent
  GROUP BY
    rank_bucket,
    visit_id)
GROUP BY
  rank_bucket
UNION ALL
SELECT
  resource_type AS label,
  rank_bucket,
  ROUND(AVG(count)) avg,
  stddev(count) stdev,
FROM (
  SELECT
    COUNT(*) count,
    rank_bucket,
    meta.resource_type resource_type
  FROM
    diff.tree_by_parent
  GROUP BY
    rank_bucket,
    visit_id,
    meta.resource_type)
WHERE
  resource_type='csp_report'
  OR resource_type='image'
  OR resource_type='script'
  OR resource_type='sub_frame'
  OR resource_type='xmlhttprequest'
  OR resource_type='font'
GROUP BY
  resource_type,
  rank_bucket
ORDER BY
  label,
  rank_bucket;/*,
  -- p11 dns_sim*/
SELECT
  'associated' label,
  --row_id,
  CAST(json_value(json_extract_array(dns.eval_all)[
    OFFSET
      (0)],
      '$.addresses') AS numeric) sim,
  depth
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  children.ct_0>0
  OR children.ct_1>0
  OR children.ct_2>0
  OR children.ct_3>0
  OR children.ct_4>0
UNION ALL
SELECT
  'used' label,
  --row_id,
  CAST(json_value(json_extract_array(dns.eval_all)[
    OFFSET
      (0)],
      '$.used_address') AS numeric),
  depth
FROM
  `your-bigquery-data-set.diff.tree_by_chain`;