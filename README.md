# REES46 E-commerce Funnel & Cart Abandonment Analysis

## The question
Where in the purchase funnel are cosmetics e-commerce users dropping off, 
and is cart abandonment recoverable?

## Setup
- Dataset: REES46 open e-commerce behavior data (cosmetics category)
- Tools: Python, PostgreSQL
- Approach: funnel conversion, purchase timing, cart sit-time, and 
  true-abandonment analysis, each isolated to a single clearly defined 
  population to keep metrics comparable

## Key findings
- **6.92%** overall user-level funnel conversion
- Session-level cart→purchase conversion is only **15.36%**, most 
  purchases happen in a *later* session, not the one where the item 
  was added to cart
- Average full purchase journey: **~11 days**
- Items sit in cart **~8.2 days** on average before removal
- Only **~1.44%** of users who truly abandon a product (strict single-
  population definition) ever return to buy that same product
- ~30% of abandoners buy *something* eventually but not the item 
  they abandoned

## Two theories I tested and disproved
- Unbranded traffic drag down conversion: not supported by the data
- High-volume brands underperform on conversion:  not supported either

## So what?
This isn't really a funnel problem, it's a **return-window problem**. 
Items sit in cart for 8.2 days on average before removal, but cross-session recovery dies after about a week.
That means the intervention window is narrower than the sit-time suggests: a cart-abandonment email fired 48–72 hours in and not at day 8, is the only version of this campaign that lands before the customer has mentally closed the loop. Waiting for the "natural" 8 day removal point to trigger a visit is already too late for most of that ~1.44% who'd ever return anyway, the recommendation isn't "add a reminder email," it's "fix the timing of the one you probably already have."

## Files
- `/sql/funnel_analysis.sql` — full query set, ordered narratively 
  (funnel → timing → cart sit-time → true abandonment)
- `/charts/` — interactive Plotly exports (funnel, cart removal/recovery, 
  session-level Sankey)
