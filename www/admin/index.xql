<?xml version="1.0"?>
<queryset>

<fullquery name="adrv_name_query">      
      <querytext>
      
            select pretty_name
              from adv_groups
             where group_key = :group_key
            
      </querytext>
</fullquery>

<fullquery name="adv_select_query1">      
      <querytext>
      
    select group_key, pretty_name
      from adv_groups 
     where not group_key in (select group_key from adv_group_map)
            
      </querytext>
</fullquery>
 
<fullquery name="adv_select_query2">      
      <querytext>
      
    select map.group_key, advs.adv_key
      from advs, adv_group_map map
     where advs.adv_key = map.adv_key

UNION

    select NULL, advs.adv_key
      from advs
     where 0=(select count(*) from adv_group_map where advs.adv_key = adv_group_map.adv_key)
           
      </querytext>
</fullquery>

</queryset>
