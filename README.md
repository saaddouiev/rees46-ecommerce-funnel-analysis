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
This isn't a funnel problem, it's a return-window problem. 
Customers aren't rejecting the product, only 15.36% of cart-adds convert in the same session, and the ones who do come back mostly buy something else (1.44% return for the exact item, ~30% buy anything within ~11 days). The cart itself becomes irrelevant faster than the customer does.

Two changes follow directly from this:

- Re-engagement should target the return, not the SKU. Broad "welcome back" triggers, category recs, generic incentives, timed inside the ~8-day cart-sit window will reach the 30% who are actually convertible. Product-specific reminders are optimizing for a population that's already down to 1.44%.
- Cart persistence is a technical lever, not just a marketing one. With cross-session purchase as the dominant path, any friction that breaks cart continuity across devices or sessions (no persistence, no account-linking prompt at add-to-cart) is quietly discarding demand the data shows is still there roughly a week later.

## Files
- `/sql/funnel_analysis.sql` — full query set, ordered narratively 
  (funnel → timing → cart sit-time → true abandonment)
- `/charts/` — interactive Plotly exports (funnel, cart removal/recovery, 
  session-level Sankey)
