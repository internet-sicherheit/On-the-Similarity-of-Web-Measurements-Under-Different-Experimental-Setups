-- This is the SQL used to generate the results for unique nodes (Case Study).
  /*,
  --e9.1 how many uniq nodes*/
SELECT
  ct_uniq,
  ct_total,
  ct_uniq/ct_total
FROM (
  SELECT
    COUNT(*) ct_uniq,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain) ct_total
  FROM
    `your-bigquery-data-set.diff.tree_by_chain`
  WHERE
    freq.seen_in_profiles=1 ); /*,
  -- e9.2 - how many uniq nodes has a query string*/
SELECT
  COUNT(*) urls_with_querystring,
  (
  SELECT
    COUNT(*)
  FROM (
    SELECT
      COUNT(*)
    FROM
      `your-bigquery-data-set.diff.tree_by_chain` t1
    WHERE
      t1.freq.seen_in_profiles=1
    GROUP BY
      tree_url_hash)) AS uniq_urls
FROM (
  SELECT
    1
  FROM
    `your-bigquery-data-set.diff.tree_by_chain` t1
  INNER JOIN
    diff.tmp_requests t2
  ON
    t1.tree_url_hash=t2.tree_url_hash
  WHERE
    t1.freq.seen_in_profiles=1
    AND t2.url LIKE '%?%'
  GROUP BY
    t1.tree_url_hash); /*,
  --e9.3 is_tracker*/
SELECT
  ct_uniq,
  is_tracker,
  ct_total,
  ct_uniq/ct_total
FROM (
  SELECT
    COUNT(*) ct_uniq,
    meta.is_tracker AS is_tracker,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain
    WHERE
      freq.seen_in_profiles=1) ct_total
  FROM
    `your-bigquery-data-set.diff.tree_by_chain`
  WHERE
    freq.seen_in_profiles=1
  GROUP BY
    meta.is_tracker); /*,
  --e9.4 third-parties*/
SELECT
  ct_uniq,
  is_third_party,
  ct_total,
  ct_uniq/ct_total
FROM (
  SELECT
    COUNT(*) ct_uniq,
    meta.is_third_party AS is_third_party,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain
    WHERE
      freq.seen_in_profiles=1) ct_total
  FROM
    `your-bigquery-data-set.diff.tree_by_chain`
  WHERE
    freq.seen_in_profiles=1
  GROUP BY
    meta.is_third_party); /*,
  --e9.5 resource_type*/
SELECT
  ct_uniq,
  resource_type,
  ct_total,
  ct_uniq/ct_total AS pct
FROM (
  SELECT
    COUNT(*) ct_uniq,
    meta.resource_type AS resource_type,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain
    WHERE
      freq.seen_in_profiles=1) ct_total
  FROM
    `your-bigquery-data-set.diff.tree_by_chain`
  WHERE
    freq.seen_in_profiles=1
  GROUP BY
    meta.resource_type)
ORDER BY
  pct DESC; /*,
  --e9.6 uniq per etld*/
SELECT
  ct_uniq,
  etld,
  ct_total,
  ct_uniq/ct_total AS pct
FROM (
  SELECT
    COUNT(*) ct_uniq,
    meta.etld AS etld,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain
    WHERE
      freq.seen_in_profiles=1) ct_total
  FROM
    `your-bigquery-data-set.diff.tree_by_chain`
  WHERE
    freq.seen_in_profiles=1
  GROUP BY
    meta.etld)
ORDER BY
  pct DESC; /*,
  --e9.7 metod*/
SELECT
  ct_uniq,
  method,
  ct_total,
  ct_uniq/ct_total AS pct
FROM (
  SELECT
    COUNT(*) ct_uniq,
    meta.method AS method,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain
    WHERE
      freq.seen_in_profiles=1) ct_total
  FROM
    `your-bigquery-data-set.diff.tree_by_chain`
  WHERE
    freq.seen_in_profiles=1
  GROUP BY
    meta.method)
ORDER BY
  pct DESC; /*,
  -- e9.9 image
  AND tracker*/
SELECT
  COUNT(*)
FROM
  `your-bigquery-data-set.diff.tree_by_chain`
WHERE
  freq.seen_in_profiles=1
  AND meta.resource_type='"image"'
  AND meta.is_tracker; /*,
  ,
  --,
  --,
  -- ################################## UNABHÄNGIG VON DER TIEFE,
  --,
  --,
  -- */ /*,
  -- e9.10 uniq nodes */
SELECT
  ct_uniq,
  ct_total,
  ct_uniq/ct_total
FROM (
  SELECT
    COUNT(*) ct_uniq,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_parent) ct_total
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`
  WHERE
    meta.in_profiles=1 ); /*,
  ,
  --
  -- e9.11 - how many uniq nodes has a query string*/



SELECT
  COUNT(*) urls_with_querystring,
  (
  SELECT
    COUNT(*)
  FROM (
    SELECT
      COUNT(*)
    FROM
      `your-bigquery-data-set.diff.tree_by_parent` t1
    WHERE
      t1.meta.in_profiles=1
    GROUP BY
      tree_url_hash)) AS uniq_urls
FROM (
  SELECT
    1
  FROM
    `your-bigquery-data-set.diff.tree_by_chain` t1
  INNER JOIN
    diff.tmp_requests t2
  ON
    t1.tree_url_hash=t2.tree_url_hash
  WHERE
    t1.freq.seen_in_profiles=1
    AND t2.url LIKE '%?%'
  GROUP BY
    t1.tree_url_hash);

/*,
--e9.12 tracking uniq nodes
,--
,--*/



SELECT
  ct_uniq,
  is_tracker,
  ct_total,
  ct_uniq/ct_total
FROM (
  SELECT
    COUNT(*) ct_uniq,
    meta.is_tracker AS is_tracker,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_parent
    WHERE
      meta.in_profiles=1) ct_total
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`
  WHERE
    meta.in_profiles=1
  GROUP BY
    meta.is_tracker);

    /*,
    ,--
    ,-- e9.13 uniq third party
    */


    SELECT
  ct_uniq,
  is_third_party,
  ct_total,
  ct_uniq/ct_total
FROM (
  SELECT
    COUNT(*) ct_uniq,
    meta.is_third_party AS is_third_party,
    (
    SELECT
      COUNT(*)
    FROM
      `your-bigquery-data-set.diff.tree_by_parent`
    WHERE
      meta.in_profiles=1 ) ct_total
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`
  WHERE
    meta.in_profiles=1
  GROUP BY
    meta.is_third_party);






/*,
,-- e9.14 uniq nodes per resource type
*/
SELECT
  ct_uniq,
  resource_type,
  ct_total,
  ct_uniq/ct_total AS pct
FROM (
  SELECT
    COUNT(*) ct_uniq,
    meta.resource_type AS resource_type,
    (
    SELECT
      COUNT(*)
    FROM
      `your-bigquery-data-set.diff.tree_by_parent`
    WHERE
      meta.in_profiles=1) ct_total
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`
  WHERE
    meta.in_profiles=1
  GROUP BY
    meta.resource_type)
ORDER BY
  pct DESC;

/*,
--e9.15 uniq node per etld*/



SELECT
  ct_uniq,
  etld,
  ct_total,
  ct_uniq/ct_total AS pct
FROM (
  SELECT
    COUNT(*) ct_uniq,
    meta.etld AS etld,
    (
    SELECT
      COUNT(*)
    FROM
      `your-bigquery-data-set.diff.tree_by_parent`
    WHERE
      meta.in_profiles=1) ct_total
  FROM
    `your-bigquery-data-set.diff.tree_by_parent`
  WHERE
    meta.in_profiles=1
  GROUP BY
    meta.etld)
ORDER BY
  pct DESC;



