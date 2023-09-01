-- This is SQL used to generate the results for the tables used in the paper.
#tab.browser_implications
SELECT
  'requests' label,
  browser_id,
  COUNT(*) total
FROM
  diff.tmp_requests
GROUP BY
  browser_id
UNION ALL
SELECT
  'nodes',
  browser_id,
  COUNT(*) total
FROM
  diff.tree_by_parent
GROUP BY
  browser_id
UNION ALL
SELECT
  'tracker',
  browser_id,
  COUNT(*) total
FROM
  diff.tree_by_parent
WHERE
  meta.is_tracker
GROUP BY
  browser_id
UNION ALL
SELECT
  'third_party',
  browser_id,
  COUNT(*) total
FROM
  diff.tree_by_parent
WHERE
  meta.is_third_party
GROUP BY
  browser_id
UNION ALL
SELECT
  'max_depth',
  browser_id,
  MAX(tree_depth)
FROM
  diff.tree_by_parent
WHERE
  meta.is_third_party
GROUP BY
  browser_id
union all
  SELECT
  'max breadth' label,
  browser_id,
  MAX(breadth)
FROM (
  SELECT
    browser_id,
    tree_depth,
    COUNT(*) breadth,
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`
  GROUP BY
    browser_visit,
    browser_id,
    tree_depth)
GROUP BY
  browser_id

ORDER BY 
  browser_id;
 


  #tab.cookie_implications



 
SELECT
  'cookies' label,
  browser_id,
  COUNT(*) total
FROM
  diff.tmp_cookies
GROUP BY
  browser_id
UNION ALL
SELECT
  'tracker',
  browser_id,
  COUNT(*) total
FROM
  diff.tmp_cookies
WHERE
  is_tracker
GROUP BY
  browser_id
UNION ALL
SELECT
  'session',
  browser_id,
  COUNT(*) total
FROM
  diff.tmp_cookies
  where is_session=1
GROUP BY
  browser_id
UNION ALL
SELECT
  'third_party',
  browser_id,
  COUNT(*) total
FROM
  diff.tmp_cookies
WHERE
  is_third_party=1
GROUP BY
  browser_id 


ORDER BY 
  browser_id
