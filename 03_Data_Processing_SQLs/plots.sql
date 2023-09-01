-- This SQL is used to generate the results for plots used in the paper.

  /* depth of nodes by appearaence */
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
  max_breadth DESC;


    /*,
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
  t1.browser_id=t4.browser_id