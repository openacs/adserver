<?xml version="1.0"?>
<queryset>

<fullquery name="adv_info_query">      
      <querytext>
      select adv_key, adv_filename, track_clickthru_p, target_url from advs where adv_key = :adv_key
      </querytext>
</fullquery>

 
<fullquery name="adv_numbers_query">      
      <querytext>
      
select sum(display_count) as n_displays, 
       sum(click_count) as n_clicks, 
       min(entry_date) as first_display, 
       max(entry_date) as last_display 
from adv_log 
where adv_key = :adv_key
      </querytext>
</fullquery>

 
</queryset>
