<?xml version="1.0"?>
<queryset>

<fullquery name="adv_insert_check">      
      <querytext>
      
select count(*)
  from advs 
 where adv_key = :adv_key
   and target_url = :target_url
   and local_image_p = :local_image_p
   and track_clickthru_p = :track_clickthru_p
  and adv_filename = :adv_filename

      </querytext>
</fullquery>

 
</queryset>
