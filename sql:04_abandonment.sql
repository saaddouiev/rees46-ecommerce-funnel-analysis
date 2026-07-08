-- ==================================================================
-- THEME: ABANDONMENT
-- Question: how long does an item sit in the cart before removal,
-- and do "true abandoners" (removed with zero purchase in-session)
-- ever come back?
-- ==================================================================

-- avg hours between adding to cart and removing it
SELECT
    ROUND(AVG(EXTRACT(EPOCH FROM r.event_time - c.event_time) / 3600), 2) AS avg_hours_to_remove,
    COUNT(*) AS total_removals
FROM cosmetics_ecommerce.cosmetics_cleaned c
JOIN cosmetics_ecommerce.cosmetics_cleaned r
    ON c.user_id = r.user_id
    AND c.product_id = r.product_id
    AND c.event_type = 'cart'
    AND r.event_type = 'remove_from_cart'
    AND r.event_time > c.event_time;

-- a "true abandoner" = removed an item in a session where they bought nothing at all
-- use ROW_NUMBER to get each user's FIRST true abandonment
WITH purchase_sessions AS (
    SELECT DISTINCT user_id, user_session
    FROM cosmetics_ecommerce.cosmetics_cleaned
    WHERE event_type = 'purchase'
),
true_abandonment AS (
    SELECT user_id, abandoned_product, removal_time
    FROM (
        SELECT
            r.user_id,
            r.product_id AS abandoned_product,
            r.event_time AS removal_time,
            ROW_NUMBER() OVER (PARTITION BY r.user_id ORDER BY r.event_time ASC) AS rn
        FROM cosmetics_ecommerce.cosmetics_cleaned r
        LEFT JOIN purchase_sessions ps
            ON r.user_id = ps.user_id AND r.user_session = ps.user_session
        WHERE r.event_type = 'remove_from_cart' AND ps.user_id IS NULL
    ) ranked
    WHERE rn = 1
),
-- then get their first purchase after that abandonment, if any
next_purchase AS (
    SELECT user_id, purchased_product
    FROM (
        SELECT
            ta.user_id,
            p.product_id AS purchased_product,
            ROW_NUMBER() OVER (PARTITION BY ta.user_id ORDER BY p.event_time ASC) AS rn
        FROM true_abandonment ta
        JOIN cosmetics_ecommerce.cosmetics_cleaned p
            ON p.user_id = ta.user_id AND p.event_type = 'purchase' AND p.event_time > ta.removal_time
    ) ranked
    WHERE rn = 1
)
SELECT
    return_type,
    COUNT(*) AS abandoner_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM true_abandonment), 2) AS pct_of_abandoners
FROM (
    SELECT
        ta.user_id,
        CASE
            WHEN np.purchased_product IS NULL THEN 'never_returned'
            WHEN np.purchased_product = ta.abandoned_product THEN 'same_product'
            ELSE 'different_product'
        END AS return_type
    FROM true_abandonment ta
    LEFT JOIN next_purchase np ON ta.user_id = np.user_id
) classified
GROUP BY return_type
ORDER BY abandoner_count DESC;

-- almost nobody who truly abandons comes back on their own -- this is a
-- return-window problem, not a funnel problem
