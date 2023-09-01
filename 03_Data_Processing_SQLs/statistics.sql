-- This SQL is used to generate the results for statistical analysis used in the paper.

  /*,
  --s.1: ndoe count vs rank */
SELECT
  COUNT(*) count,
  rank_bucket
FROM
  diff.tree_by_parent
GROUP BY
  rank_bucket,
  visit_id; /*,
  --s.2: number OF tracker vs rank*/
SELECT
  COUNT(*) node_count,
  rank_bucket
FROM
  diff.tree_by_parent
WHERE
  meta.is_tracker
GROUP BY
  rank_bucket,
  visit_id; /*,
  s.2 sim OF children vs rank*/
SELECT
  rank_bucket,
  children.sim_all
FROM
  diff.tree_by_chain
WHERE
  children.ct_0>0
  OR children.ct_1>0
  OR children.ct_2>0
  OR children.ct_3>0
  OR children.ct_4>0; /*,
  s.3 number OF tracker vs rank*/
SELECT
  COUNT(*) node_count,
  rank_bucket
FROM
  diff.tree_by_parent
WHERE
  meta.is_tracker
GROUP BY
  rank_bucket,
  visit_id; /*,
  s.4 parent_sim vs third_party*/
SELECT
  meta.is_third_party,
  parent.eval_all
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
  s.5. simVSchildrenCount */
SELECT
  children.ct_avg_all,
  children.sim_all
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  freq.seen_in_profiles=5 --
  AND depth>0
  AND ( children.ct_0>0
    OR children.ct_1>0
    OR children.ct_2>0
    OR children.ct_3>0
    OR children.ct_4>0); /*,
  -- s.6 interaction vs tree depth interaction-desktopVStreeDepth */
SELECT
  REPLACE(REPLACE(browser_id,'openwpm_desktop','0'),'openwpm_interaction_1','1'),
  tree_depth
FROM
  `your-bigquery-data-set.diff.tree_by_parent`
WHERE
  browser_id='openwpm_desktop'
  OR browser_id='openwpm_interaction_1';