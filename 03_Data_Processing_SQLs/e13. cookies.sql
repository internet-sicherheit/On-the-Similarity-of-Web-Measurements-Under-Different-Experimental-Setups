  -- This is the SQL used to generate results for Implications on Cookies.
  
  /*,
  e13.0 general overview*/
SELECT
  'total cookies' label,
  COUNT(*) count,
  NULL avg,
  NULL stdev,
  NULL min,
  NULL max,
FROM
  diff.tmp_cookies
UNION ALL
SELECT
  'avg per profile' label,
  COUNT(*) count,
  AVG(ct) avg,
  stddev(ct) stdev,
  MIN(ct) min,
  MAX(ct) max,
FROM (
  SELECT
    COUNT(*) ct
  FROM
    diff.tmp_cookies
  GROUP BY
    browser_id) ; /*,
  --e13.1 tracking cookies*/
SELECT
  'all' label,
  COUNT( * ),
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    diff.tmp_cookies ) pct
FROM
  diff.tmp_cookies
WHERE
  is_tracker; /*,
  --e13.2 distribution OF UNIQ cookies BY profile*/
SELECT
  CONCAT('is_third_party ',meta.is_third_party) label,
  meta.in_profiles,
  ROUND(COUNT(*)/(
    SELECT
      COUNT(* )
    FROM
      diff.tree_distinct_cookies ),2) pct
FROM
  `your-bigquery-data-set.diff.tree_distinct_cookies`
GROUP BY
  meta.in_profiles,
  meta.is_third_party
UNION ALL
SELECT
  CONCAT('is_session ',meta.is_session) label,
  meta.in_profiles,
  ROUND(COUNT(*)/(
    SELECT
      COUNT(* )
    FROM
      diff.tree_distinct_cookies ),2)
FROM
  `your-bigquery-data-set.diff.tree_distinct_cookies`
GROUP BY
  meta.in_profiles,
  meta.is_session
UNION ALL
SELECT
  CONCAT('is_tracker ',meta.is_tracker) label,
  meta.in_profiles,
  ROUND(COUNT(*)/(
    SELECT
      COUNT(* )
    FROM
      diff.tree_distinct_cookies ),2)
FROM
  `your-bigquery-data-set.diff.tree_distinct_cookies`
GROUP BY
  meta.in_profiles,
  meta.is_tracker
ORDER BY
  in_profiles,
  label,
  pct ; /*,
  -- e13.3 distribution OF the cookies */
SELECT
  'third_party' AS label,
  meta.in_profiles in_profiles,
  COUNT(*) ct,
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    diff.tree_distinct_cookies
  WHERE
    meta.is_third_party)
FROM
  diff.tree_distinct_cookies
WHERE
  meta.is_third_party
GROUP BY
  meta.in_profiles
UNION ALL
SELECT
  'is_session' AS label,
  meta.in_profiles in_profiles,
  COUNT(*) ct,
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    diff.tree_distinct_cookies
  WHERE
    meta.is_session)
FROM
  diff.tree_distinct_cookies
WHERE
  meta.is_session
GROUP BY
  meta.in_profiles
UNION ALL
SELECT
  'is_tracker' AS label,
  meta.in_profiles in_profiles,
  COUNT(*) ct,
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    diff.tree_distinct_cookies
  WHERE
    meta.is_tracker)
FROM
  diff.tree_distinct_cookies
WHERE
  meta.is_tracker
GROUP BY
  meta.in_profiles
ORDER BY
  in_profiles,
  label; 
 
  /*,
  --e13.4 sim OF cookie PARAMETERS same_site,, path etc.*/
SELECT
  'is_secure' AS label,
  COUNT(*) count,
  AVG(is_secure.sim_all) avg,
  MIN(is_secure.sim_all) min,
  MAX(is_secure.sim_all) max,
  stddev(is_secure.sim_all) stdev,
FROM
  `your-bigquery-data-set.diff.tree_distinct_cookies`
WHERE
  meta.in_profiles=5
  AND is_secure.sim_all<1
UNION ALL
SELECT
  'is_session' AS label,
  COUNT(*),
  AVG(is_session.sim_all) avg,
  MIN(is_session.sim_all) min,
  MAX(is_session.sim_all) max,
  stddev(is_session.sim_all) stdev,
FROM
  `your-bigquery-data-set.diff.tree_distinct_cookies`
WHERE
  meta.in_profiles=5
  AND is_session.sim_all<1
UNION ALL
SELECT
  'is_http_only' AS label,
  COUNT(*),
  AVG(is_http_only.sim_all) avg,
  MIN(is_http_only.sim_all) min,
  MAX(is_http_only.sim_all) max,
  stddev(is_http_only.sim_all) stdev,
FROM
  `your-bigquery-data-set.diff.tree_distinct_cookies`
WHERE
  meta.in_profiles=5
  AND is_http_only.sim_all<1
UNION ALL
SELECT
  'same_site' AS label,
  COUNT(*),
  AVG(same_site.sim_all) avg,
  MIN(same_site.sim_all) min,
  MAX(same_site.sim_all) max,
  stddev(same_site.sim_all) stdev,
FROM
  `your-bigquery-data-set.diff.tree_distinct_cookies`
WHERE
  meta.in_profiles=5
  AND same_site.sim_all<1
UNION ALL
SELECT
  'path' AS label,
  COUNT(*),
  AVG(path.sim_all) avg,
  MIN(path.sim_all) min,
  MAX(path.sim_all) max,
  stddev(path.sim_all) stdev,
FROM
  `your-bigquery-data-set.diff.tree_distinct_cookies`
WHERE
  meta.in_profiles=5
  AND path.sim_all<1; /*,
  --e13.5 number NOT same cookies*/
SELECT
  COUNT(*),
  COUNT(*)/(
  SELECT
    COUNT(*)
  FROM
    diff.tree_distinct_cookies
  WHERE
    meta.in_profiles=5 )
FROM
  diff.tree_distinct_cookies
WHERE
  meta.in_profiles=5
  AND (is_secure.sim_all<1
    OR is_session.sim_all<1
    OR is_http_only.sim_all<1
    OR same_site.sim_all<1); /*,
  --e13.6 sim of cookies per visit */
SELECT
  'all' label,
  AVG(name.sim_all) avg,
  MIN(name.sim_all) min,
  MAX(name.sim_all) max,
  stddev(name.sim_all) stdev
FROM
  `your-bigquery-data-set.diff.tree_cookies_per_visit`
UNION ALL
SELECT
  'desktopVSinteraction' label,
  AVG(name.sim_0_1),
  MIN(name.sim_0_1),
  MAX(name.sim_0_1),
  stddev(name.sim_0_1)
FROM
  `your-bigquery-data-set.diff.tree_cookies_per_visit`
UNION ALL
SELECT
  'simultane' label,
  AVG(name.sim_1_2),
  MIN(name.sim_1_2),
  MAX(name.sim_1_2),
  stddev(name.sim_1_2)
FROM
  `your-bigquery-data-set.diff.tree_cookies_per_visit`
UNION ALL
SELECT
  'interactionVSold' label,
  AVG(name.sim_1_3),
  MIN(name.sim_1_3),
  MAX(name.sim_1_3),
  stddev(name.sim_1_3)
FROM
  `your-bigquery-data-set.diff.tree_cookies_per_visit`
UNION ALL
SELECT
  'interactionVSHeadless' label,
  AVG(name.sim_1_4),
  MIN(name.sim_1_4),
  MAX(name.sim_1_4),
  stddev(name.sim_1_4)
FROM
  `your-bigquery-data-set.diff.tree_cookies_per_visit`; /*,
  --e13.7 sim of cookies per site*/
SELECT
  'all' label,
  AVG(name.sim_all),
  MIN(name.sim_all),
  MAX(name.sim_all),
  stddev(name.sim_all)
FROM
  `your-bigquery-data-set.diff.tree_cookies_per_site`
UNION ALL
SELECT
  'desktopVSinteraction' label,
  AVG(name.sim_0_1),
  MIN(name.sim_0_1),
  MAX(name.sim_0_1),
  stddev(name.sim_0_1)
FROM
  `your-bigquery-data-set.diff.tree_cookies_per_site`
UNION ALL
SELECT
  'simultane' label,
  AVG(name.sim_1_2),
  MIN(name.sim_1_2),
  MAX(name.sim_1_2),
  stddev(name.sim_1_2)
FROM
  `your-bigquery-data-set.diff.tree_cookies_per_site`
UNION ALL
SELECT
  'interactionVSold' label,
  AVG(name.sim_1_3),
  MIN(name.sim_1_3),
  MAX(name.sim_1_3),
  stddev(name.sim_1_3)
FROM
  `your-bigquery-data-set.diff.tree_cookies_per_site`
UNION ALL
SELECT
  'interactionVSHeadless' label,
  AVG(name.sim_1_4),
  MIN(name.sim_1_4),
  MAX(name.sim_1_4),
  stddev(name.sim_1_4)
FROM
  `your-bigquery-data-set.diff.tree_cookies_per_site`;

  