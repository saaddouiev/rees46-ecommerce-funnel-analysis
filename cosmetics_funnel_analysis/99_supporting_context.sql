-- ==================================================================
-- SUPPORTING CONTEXT
-- Not headline findings -- these are the disproven theories referenced
-- in the write-up as "things I checked and ruled out."
-- ==================================================================

-- theory: pricier items get removed more -> checked by brand, not true
SELECT
    brand,
    ROUND(AVG(price), 2) AS average_price,
    COUNT(CASE WHEN event_type = 'remove_from_cart' THEN 1 END) AS total_removals,
    COUNT(CASE WHEN event_type = 'cart' THEN 1 END) AS total_adds,
    ROUND(100.0 * COUNT(CASE WHEN event_type = 'remove_from_cart' THEN 1 END)
        / NULLIF(COUNT(CASE WHEN event_type = 'cart' THEN 1 END), 0), 2) AS removal_rate_pct
FROM cosmetics_ecommerce.cosmetics_cleaned
WHERE brand != 'Unknown'
GROUP BY brand
ORDER BY removal_rate_pct DESC;

-- same theory checked at product level, in case brand was too coarse -> still not true
SELECT
    product_id,
    category_id,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(CASE WHEN event_type = 'remove_from_cart' THEN 1 END) AS removals,
    COUNT(CASE WHEN event_type = 'cart' THEN 1 END) AS adds,
    ROUND(100.0 * COUNT(CASE WHEN event_type = 'remove_from_cart' THEN 1 END)
        / NULLIF(COUNT(CASE WHEN event_type = 'cart' THEN 1 END), 0), 2) AS removal_rate_pct
FROM cosmetics_ecommerce.cosmetics_cleaned
WHERE brand != 'Unknown'
GROUP BY product_id, category_id
HAVING COUNT(CASE WHEN event_type = 'cart' THEN 1 END) > 20
ORDER BY removal_rate_pct DESC;
