<?xml version="1.0"?>
<queryset>

<fullquery name="adv_info_query">      
      <querytext>
      
select sum (display_count) as n_displays, 
       sum (click_count) as n_clicks, 
       min (entry_date) as first_display, 
       max (entry_date) as last_display, 
       round (max (entry_date) - min (entry_date)) as n_days, 
       count (*) as n_entries 
from adv_log 
where adv_key = :adv_key
      </querytext>
</fullquery>

 
</queryset>
