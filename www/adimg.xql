<?xml version="1.0"?>
<queryset>

<fullquery name="adv_select">      
      <querytext>
      
              SELECT adv_filename as ad_filename_stub, 
                     case when local_image_p = 't' then 1 else 0 end as local_image
                FROM advs
                WHERE adv_key = :adv_key
      </querytext>
</fullquery>

 
</queryset>
