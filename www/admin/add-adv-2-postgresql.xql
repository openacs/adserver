<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="adv_insert_query">      
      <querytext>
      
insert into advs (adv_key, target_url, local_image_p, track_clickthru_p, adv_filename)
select :adv_key, :target_url, :local_image_p, :track_clickthru_p, :adv_filename 
 
where not exists (select 1
                    from advs
                   where adv_key= :adv_key)

      </querytext>
</fullquery>

 
</queryset>
