-- ==================================================================
-- THEME: TIMING
-- Question: how long does the journey take, and does the purchase
-- happen in the same session as the cart add, or does the user
-- come back later?
-- ==================================================================

-- avg time between each funnel step, for users who converted
WITH user_journey AS (
    SELECT
        user_id,
        MIN(CASE WHEN event_type = 'view' THEN event_time END) AS view_time,
        MIN(CASE WHEN event_type = 'cart' THEN event_time END) AS add_to_cart_time,
        MIN(CASE WHEN event_type = 'purchase' THEN event_time END) AS purchase_time
    FROM cosmetics_ecommerce.cosmetics_cleaned
    GROUP BY user_id
    HAVING MIN(CASE WHEN event_type = 'purchase' THEN event_time END) IS NOT NULL
)
SELECT
    COUNT(*) AS converted_users,
    ROUND(AVG(EXTRACT(EPOCH FROM add_to_cart_time - view_time)) / 86400, 2) AS avg_view_to_cart_days,
    ROUND(AVG(EXTRACT(EPOCH FROM purchase_time - add_to_cart_time)) / 86400, 2) AS avg_cart_to_purchase_days,
    ROUND(AVG(EXTRACT(EPOCH FROM purchase_time - view_time)) / 86400, 2) AS avg_total_journey_days
FROM user_journey;

-- for each user/product's first cart add, does the purchase happen same session or later?
-- use ROW_NUMBER to grab the first cart add and first purchase per user/product
WITH first_cart AS (
    SELECT user_id, product_id, user_session, event_time AS cart_time
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id, product_id ORDER BY event_time ASC) AS rn
        FROM cosmetics_ecommerce.cosmetics_cleaned
        WHERE event_type = 'cart'
    ) ranked
    WHERE rn = 1
),
first_purchase AS (
    SELECT user_id, product_id, user_session, event_time AS purchase_time
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id, product_id ORDER BY event_time ASC) AS rn
        FROM cosmetics_ecommerce.cosmetics_cleaned
        WHERE event_type = 'purchase'
    ) ranked
    WHERE rn = 1
)
SELECT
    CASE
        WHEN fp.purchase_time IS NULL THEN 'no_purchase'
        WHEN fp.user_session = fc.user_session THEN 'same_session'
        ELSE 'later_session'
    END AS purchase_timing,
    COUNT(*) AS cart_add_count
FROM first_cart fc
LEFT JOIN first_purchase fp
    ON fc.user_id = fp.user_id
    AND fc.product_id = fp.product_id
    AND fp.purchase_time >= fc.cart_time
GROUP BY 1;

-- most purchases happen in a LATER session, not the same one the item
-- was added in -- conversion isn't a single-session event for this store
