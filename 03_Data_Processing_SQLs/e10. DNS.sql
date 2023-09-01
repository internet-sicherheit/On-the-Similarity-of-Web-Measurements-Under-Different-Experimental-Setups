-- This is SQL used to generate results for DNS analysis
-- Note the results are not included in the paper.
  /*,
  0: openwpm_desktop,
  1: openwpm_interaction_1,
  2: openwpm_interaction_2,
  3: openwpm_interaction_old,
  4: openwpmheadless_interaction */ --e10.0 scope
SELECT
  COUNT(*) scope,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain ) total
FROM
  diff.tree_by_chain
WHERE
  meta.in_profiles=5; --e10.1 exact_same
SELECT
  COUNT(*) exact_same,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    meta.in_profiles=5 ) total
FROM
  diff.tree_by_chain
WHERE
  meta.in_profiles=5
  AND CAST(json_value(json_extract_array(dns.eval_all)[
    OFFSET
      (0)],
      '$.addresses') AS numeric)=1; /*,
  -- e10.2 sim OF Associated IP Addresses */
SELECT
  AVG(val),
  MIN(val),
  MAX(val),
  stddev(val)
FROM (
  SELECT
    CAST(json_value(json_extract_array(dns.eval_all)[
      OFFSET
        (0)],
        '$.addresses') AS numeric) val
  FROM
    diff.tree_by_chain
  WHERE
    meta.in_profiles=5); /*,
  e10.3 -- cdn types*/
SELECT
  json_value(json_extract_array(dns.in_1)[
  OFFSET
    (0)],
    '$.cdn'),
  COUNT(*)
FROM
  diff.tree_by_chain
WHERE
  meta.in_profiles=5
  AND CAST(json_value(json_extract_array(dns.eval_all)[
    OFFSET
      (0)],
      '$.addresses') AS numeric)<1
GROUP BY
  json_value(json_extract_array(dns.in_1)[
  OFFSET
    (0)],
    '$.cdn')
ORDER BY
  COUNT(*) DESC; /*,
  -- e10.4 - why non cdn are NOT same?*/
SELECT
  dns
FROM
  diff.tree_by_chain
WHERE
  json_value(json_extract_array(dns.in_1)[
  OFFSET
    (0)],
    '$.cdn') IS NULL
  AND meta.in_profiles=5
  AND CAST(json_value(json_extract_array(dns.eval_all)[
    OFFSET
      (0)],
      '$.addresses') AS numeric)<1; /*,
  -- e10.5 dns ipv6*/
SELECT
  COUNT(*) AS has_ipv6,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    meta.in_profiles=5) AS total
FROM
  diff.tree_by_chain
WHERE
  json_value(json_extract_array(dns.in_3)[
  OFFSET
    (0)],
    '$.addresses') LIKE '%:%'
  AND meta.in_profiles=5
  AND json_value(json_extract_array(dns.in_4)[
  OFFSET
    (0)],
    '$.addresses') NOT LIKE '%:%'
  AND json_value(json_extract_array(dns.in_4)[
  OFFSET
    (0)],
    '$.cdn') IS NOT NULL; /*,
  -- e10.6*/
SELECT
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    meta.in_profiles=5
    AND json_value(json_extract_array(dns.in_0)[
    OFFSET
      (0)],
      '$.addresses') LIKE '%:%' ) AS in_0,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    meta.in_profiles=5
    AND json_value(json_extract_array(dns.in_1)[
    OFFSET
      (0)],
      '$.addresses') LIKE '%:%' ) AS in_1,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    meta.in_profiles=5
    AND json_value(json_extract_array(dns.in_2)[
    OFFSET
      (0)],
      '$.addresses') LIKE '%:%' ) AS in_2,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    meta.in_profiles=5
    AND json_value(json_extract_array(dns.in_3)[
    OFFSET
      (0)],
      '$.addresses') LIKE '%:%' ) AS in_3,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    meta.in_profiles=5
    AND json_value(json_extract_array(dns.in_4)[
    OFFSET
      (0)],
      '$.addresses') LIKE '%:%' ) AS in_4; /*,
  -- ################################################################################ used_addresses,
  -- e10.7 - used_adress ALL same */
SELECT
  COUNT(*) exact_same,
  (
  SELECT
    COUNT(*)
  FROM
    diff.tree_by_chain
  WHERE
    meta.in_profiles=5 ) total
FROM
  diff.tree_by_chain
WHERE
  meta.in_profiles=5
  AND CAST(json_value(json_extract_array(dns.eval_all)[
    OFFSET
      (0)],
      '$.used_address') AS numeric)=1; /*,
  -- e10.8 */ -- e10.2 sim OF used_addresses */
SELECT
  AVG(val),
  MIN(val),
  MAX(val),
  stddev(val)
FROM (
  SELECT
    CAST(json_value(json_extract_array(dns.eval_all)[
      OFFSET
        (0)],
        '$.used_address') AS numeric) val
  FROM
    diff.tree_by_chain
  WHERE
    meta.in_profiles=5 ) ; /*,
  -- e10.9: used_addresses: effects OF third party 0n  similarity */
SELECT
  *,
  exact_same/total AS pct
FROM (
  SELECT
    *,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain t2
    WHERE
      meta.in_profiles=5
      AND meta.is_third_party=third_party ) total
  FROM (
    SELECT
      meta.is_third_party third_party,
      COUNT(*) exact_same
    FROM
      diff.tree_by_chain t1
    WHERE
      meta.in_profiles=5
      AND CAST(json_value(json_extract_array(dns.eval_all)[
        OFFSET
          (0)],
          '$.used_address') AS numeric)<1
    GROUP BY
      meta.is_third_party)); /*,
  --e10.10 cdn*/
SELECT
  json_value(json_extract_array(dns.in_1)[
  OFFSET
    (0)],
    '$.cdn'),
  COUNT(*)
FROM
  diff.tree_by_chain
WHERE
  meta.in_profiles=5
  AND CAST(json_value(json_extract_array(dns.eval_all)[
    OFFSET
      (0)],
      '$.used_address') AS numeric)<1
GROUP BY
  json_value(json_extract_array(dns.in_1)[
  OFFSET
    (0)],
    '$.cdn')
ORDER BY
  COUNT(*) DESC; /*,
  --e10.11 resource type */
SELECT
  *,
  exact_same/total AS pct
FROM (
  SELECT
    *,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain t2
    WHERE
      meta.in_profiles=5
      AND meta.resource_type=third_party
      AND json_value(json_extract_array(dns.in_1)[
      OFFSET
        (0)],
        '$.cdn') IS NULL ) total
  FROM (
    SELECT
      meta.resource_type third_party,
      COUNT(*) exact_same
    FROM
      diff.tree_by_chain t1
    WHERE
      meta.in_profiles=5
      AND CAST(json_value(json_extract_array(dns.eval_all)[
        OFFSET
          (0)],
          '$.used_address') AS numeric)=1
      AND json_value(json_extract_array(dns.in_1)[
      OFFSET
        (0)],
        '$.cdn') IS NULL
    GROUP BY
      meta.resource_type))
ORDER BY
  pct; /*,
  --e10.12 resource type sim <1*/
SELECT
  *,
  exact_same/total AS pct
FROM (
  SELECT
    *,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain t2
    WHERE
      meta.in_profiles=5
      AND meta.resource_type=third_party
      AND json_value(json_extract_array(dns.in_1)[
      OFFSET
        (0)],
        '$.cdn') IS NULL ) total
  FROM (
    SELECT
      meta.resource_type third_party,
      COUNT(*) exact_same
    FROM
      diff.tree_by_chain t1
    WHERE
      meta.in_profiles=5
      AND CAST(json_value(json_extract_array(dns.eval_all)[
        OFFSET
          (0)],
          '$.used_address') AS numeric)<1
      AND json_value(json_extract_array(dns.in_1)[
      OFFSET
        (0)],
        '$.cdn') IS NULL
    GROUP BY
      meta.resource_type))
ORDER BY
  pct; /*,
  STATISTIC e10.13 - anova test dns_ip,
  sim OF childrent
  AND parent*/
SELECT
  CAST(json_value(json_extract_array(dns.eval_all)[
    OFFSET
      (0)],
      '$.used_address') AS numeric) dns_ip,
  children.sim_all,
  parent.eval_all
FROM
  diff.tree_by_chain t1
WHERE
  meta.in_profiles=5
  AND json_value(json_extract_array(dns.in_0)[
  OFFSET
    (0)],
    '$.addresses') IS NOT NULL
  AND json_value(json_extract_array(dns.in_1)[
  OFFSET
    (0)],
    '$.addresses') IS NOT NULL
  AND json_value(json_extract_array(dns.in_2)[
  OFFSET
    (0)],
    '$.addresses') IS NOT NULL
  AND json_value(json_extract_array(dns.in_3)[
  OFFSET
    (0)],
    '$.addresses') IS NOT NULL
  AND json_value(json_extract_array(dns.in_4)[
  OFFSET
    (0)],
    '$.addresses') IS NOT NULL; /*,
  -- e10.14 sim OF dns ip BY depth */
SELECT
  COUNT(*),
  AVG(val) avg,
  MIN(val) min,
  MAX(val) max,
  stddev(val) stdv,
  depth
FROM (
  SELECT
    depth,
    CAST(json_value(json_extract_array(dns.eval_all)[
      OFFSET
        (0)],
        '$.used_address') AS numeric) val
  FROM
    diff.tree_by_chain
  WHERE
    meta.in_profiles=5 )
GROUP BY
  depth
ORDER BY
  depth; /*,
  --e10.15 DoH pct per profile*/
SELECT
  *,
  desktop/total AS pct_desk,
  sim1/total AS pct_sim1,
  sim2/total AS pct_sim2,
  old1/total AS pct_old1,
  headl/total AS pct_headl,
FROM (
  SELECT
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain
    WHERE
      meta.in_profiles=5
      AND CAST(json_value(json_extract_array(dns.in_0)[
        OFFSET
          (0)],
          '$.is_TRR') AS numeric)=1) AS desktop,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain
    WHERE
      meta.in_profiles=5
      AND CAST(json_value(json_extract_array(dns.in_1)[
        OFFSET
          (0)],
          '$.is_TRR') AS numeric)=1) AS sim1,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain
    WHERE
      meta.in_profiles=5
      AND CAST(json_value(json_extract_array(dns.in_2)[
        OFFSET
          (0)],
          '$.is_TRR') AS numeric)=1) AS sim2,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain
    WHERE
      meta.in_profiles=5
      AND CAST(json_value(json_extract_array(dns.in_3)[
        OFFSET
          (0)],
          '$.is_TRR') AS numeric)=1) AS old1,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain
    WHERE
      meta.in_profiles=5
      AND CAST(json_value(json_extract_array(dns.in_4)[
        OFFSET
          (0)],
          '$.is_TRR') AS numeric)=1) AS headl,
    (
    SELECT
      COUNT(*)
    FROM
      diff.tree_by_chain
    WHERE
      meta.in_profiles=5) AS total); /*,
  --e10.16 number OF records that changes IN AT least one profile*/
SELECT
  COUNT(*)
FROM
  diff.tree_by_chain
WHERE
  meta.in_profiles=5
  AND ( json_value(json_extract_array(dns.in_0)[
    OFFSET
      (0)],
      '$.addresses') LIKE '%:%'
    AND ( json_value(json_extract_array(dns.in_1)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_2)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_3)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_4)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%' ) )
  OR ( json_value(json_extract_array(dns.in_1)[
    OFFSET
      (0)],
      '$.addresses') LIKE '%:%'
    AND ( json_value(json_extract_array(dns.in_0)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_2)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_3)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_4)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%' ) )
  OR ( json_value(json_extract_array(dns.in_2)[
    OFFSET
      (0)],
      '$.addresses') LIKE '%:%'
    AND ( json_value(json_extract_array(dns.in_0)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_1)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_3)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_4)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%' ) )
  OR ( json_value(json_extract_array(dns.in_3)[
    OFFSET
      (0)],
      '$.addresses') LIKE '%:%'
    AND ( json_value(json_extract_array(dns.in_0)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_1)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_2)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_4)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%' ) )
  OR ( json_value(json_extract_array(dns.in_4)[
    OFFSET
      (0)],
      '$.addresses') LIKE '%:%'
    AND ( json_value(json_extract_array(dns.in_0)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_1)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_2)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%'
      OR json_value(json_extract_array(dns.in_3)[
      OFFSET
        (0)],
        '$.addresses') NOT LIKE '%:%' ) );