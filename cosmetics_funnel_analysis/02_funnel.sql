-- ==================================================================
-- THEME: THE FUNNEL
-- Question: how many users move through view -> cart -> purchase,
-- and where does the drop-off actually happen?
-- ==================================================================

-- unique users at each stage, plus stage-to-stage conversion rates
WITH funnel_stages AS (
    SELECT
        COUNT(DISTINCT CASE WHEN event_type = 'view' THEN user_id END) AS stage_1_views,
        COUNT(DISTINCT CASE WHEN event_type = 'cart' THEN user_id END) AS stage_2_cart,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_3_purchase
    FROM cosmetics_ecommerce.cosmetics_cleaned
)
SELECT
    *,
    ROUND(100.0 * stage_2_cart / NULLIF(stage_1_views, 0), 2) AS view_to_cart_pct,
    ROUND(100.0 * stage_3_purchase / NULLIF(stage_2_cart, 0), 2) AS cart_to_purchase_pct,
    ROUND(100.0 * stage_3_purchase / NULLIF(stage_1_views, 0), 2) AS overall_conversion_pct
FROM funnel_stages;

-- same funnel, shown as users dropped at each transition
WITH funnel_stages AS (
    SELECT
        COUNT(DISTINCT CASE WHEN event_type = 'view' THEN user_id END) AS stage_1_views,
        COUNT(DISTINCT CASE WHEN event_type = 'cart' THEN user_id END) AS stage_2_cart,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_3_purchase
    FROM cosmetics_ecommerce.cosmetics_cleaned
)
SELECT 'view_to_cart' AS stage_transition,
       stage_1_views - stage_2_cart AS users_dropped,
       ROUND((stage_1_views - stage_2_cart) * 100.0 / stage_1_views, 2) AS drop_off_rate
FROM funnel_stages
UNION ALL
SELECT 'cart_to_purchase',
       stage_2_cart - stage_3_purchase,
       ROUND((stage_2_cart - stage_3_purchase) * 100.0 / stage_2_cart, 2)
FROM funnel_stages;

-- session-level view: did the session convert, drop at cart, or just browse
WITH session_flags AS (
    SELECT
        user_session,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS has_purchased,
        MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS has_carted
    FROM cosmetics_ecommerce.cosmetics_cleaned
    WHERE user_session IS NOT NULL
    GROUP BY user_session
)
SELECT
    CASE
        WHEN has_purchased = 1 THEN 'Converted'
        WHEN has_carted = 1 THEN 'Dropped Off at Cart'
        ELSE 'Viewers Only'
    END AS session_segment,
    COUNT(*) AS session_count
FROM session_flags
GROUP BY 1;
