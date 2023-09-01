-- This is the SQL used to generate the results for similarity of the nodes by depth.


  -- e2.1 similarity OF appaering OF trees IN depths
SELECT
  AVG(depth.eval_all) s_avg,
  MAX(depth.eval_all) s_max,
  MIN(depth.eval_all) s_min,
  stddev(depth.eval_all) s_dev
FROM
  diff.tree_eval_url;
  
  
  /*,
  --e2.1.0 sim of appearing of trees in depths > 1*/

  SELECT
  AVG(depth.eval_all) s_avg,
  MAX(depth.eval_all) s_max,
  MIN(depth.eval_all) s_min,
  stddev(depth.eval_all) s_dev
FROM
  diff.tree_eval_url
WHERE
  '1' NOT IN UNNEST(SPLIT(depth.in_0,','))
  AND '1' NOT IN UNNEST(SPLIT(depth.in_1,','))
  AND '1' NOT IN UNNEST(SPLIT(depth.in_2,','))
  AND '1' NOT IN UNNEST(SPLIT(depth.in_3,','))
  AND '1' NOT IN UNNEST(SPLIT(depth.in_4,','));
  
  
  /*,
  -- e2.1.1 similarity OF appaering OF trees IN depths IN ALL profiles*/
SELECT
  AVG(depth.eval_all) s_avg,
  MAX(depth.eval_all) s_max,
  MIN(depth.eval_all) s_min,
  stddev(depth.eval_all) s_dev
FROM
  diff.tree_eval_url
WHERE
  in_profiles=5; /*,
  -- e2.2 nodes that appear IN ALL trees*/
SELECT
  AVG(depth.eval_all) s_avg,
  MAX(depth.eval_all) s_max,
  MIN(depth.eval_all) s_min,
  stddev(depth.eval_all) s_dev
FROM
  diff.tree_eval_url
WHERE
  in_profiles=3; /*,
  --e2.3 sim of depths first-party vs third-party*/

SELECT
'first-party',
  AVG(depth.eval_all) s_avg,
  MAX(depth.eval_all) s_max,
  MIN(depth.eval_all) s_min,
  stddev(depth.eval_all) s_dev
FROM
  diff.tree_eval_url
WHERE
  --in_profiles=5 AND 
  meta.is_third_party=False
  union all
  SELECT
'third-party',
  AVG(depth.eval_all) s_avg,
  MAX(depth.eval_all) s_max,
  MIN(depth.eval_all) s_min,
  stddev(depth.eval_all) s_dev
FROM
  diff.tree_eval_url
WHERE
  --in_profiles=5 AND 
  meta.is_third_party=TRUE;

  