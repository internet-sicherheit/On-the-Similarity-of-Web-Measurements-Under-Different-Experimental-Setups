-- This is the SQL used to generate results for similarity of the nodes by rank.
  /*,
  e12.1 nodes*/
SELECT
  'nodes' AS label,
  rank_bucket,
  AVG(count) avg,
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
ORDER BY
  rank_bucket; 
   
  
  /*,
  e12.2 avg depth per node*/
SELECT
  COUNT(*),
  AVG(tree_depth) stdev,
  stddev(tree_depth) stdev,
  rank_bucket
FROM
  diff.tree_by_parent
GROUP BY
  rank_bucket
ORDER BY
  rank_bucket; /*,
  e12.3 sim OF children BY rank*/
SELECT
  rank_bucket,
  avg (children.sim_all)
FROM
  diff.tree_by_chain
WHERE
  children.ct_0>0
  OR children.ct_1>0
  OR children.ct_2>0
  OR children.ct_3>0
  OR children.ct_4>0
GROUP BY
  rank_bucket
ORDER BY
  rank_bucket; /*,
  -- e12.4 sim OF parents*/
  
SELECT
  rank_bucket,
  avg (parent.eval_all),
  min (parent.eval_all),
  max (parent.eval_all),
  stddev (parent.eval_all)
FROM
  diff.tree_by_chain
GROUP BY
  rank_bucket
ORDER BY
  rank_bucket;






