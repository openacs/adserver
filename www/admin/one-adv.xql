<?xml version="1.0"?>
<queryset>

<fullquery name="adv_info_query">      
      <querytext>
      select adv_key, 
       adv_filename, 
       local_image_p, 
       track_clickthru_p, 
       target_url 
from advs 
where adv_key = :adv_key
      </querytext>
</fullquery>

 
<fullquery name="adv_display_count">      
      <querytext>
      
select count(*) from adv_log where adv_key=:adv_key
      </querytext>
</fullquery>

 
<fullquery name="adv_info_select">      
      <querytext>
      
       select sum (display_count) as n_displays, 
              sum (click_count) as n_clicks, 
              round(100 * sum (click_count) /sum (display_count),1) as clickthrough_percent, 
              min (entry_date) as first_display, 
              max (entry_date) as last_display 
       from adv_log 
       where adv_key = :adv_key
      </querytext>
</fullquery>

 
</queryset>
