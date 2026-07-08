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
- Session-level cart→purchase conversion is only **15.36%** — most 
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
Cross-session abandonment is mostly permanent, but there's roughly a 
one-week window where recovery is still realistic. That reframes the 
business question from "fix the funnel" to "shrink the time before the 
customer is gone for good".
Do: targeted reminders within that window rather than generic retargeting indefinitely.

## Files
- `/sql/funnel_analysis.sql` — full query set, ordered narratively 
  (funnel → timing → cart sit-time → true abandonment)
- `/charts/` — interactive Plotly exports (funnel, cart removal/recovery, 
  session-level Sankey)
