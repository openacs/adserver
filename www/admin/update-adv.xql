<?xml version="1.0"?>
<queryset>

<fullquery name="adv_update_query">      
      <querytext>
      
update advs set 
  target_url = :target_url, 
  track_clickthru_p = :track_clickthru_p, 
  adv_filename = :adv_filename, 
  local_image_p = :local_image_p 
where adv_key = :adv_key
      </querytext>
</fullquery>

 
</queryset>
