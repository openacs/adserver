<?xml version="1.0"?>
<queryset>

<fullquery name="adserver_group_view">      
      <querytext>
      
        select pretty_name, adv_count, rotation_method
          from adv_groups
         where group_key = :group_key
    
      </querytext>
</fullquery>

 
<fullquery name="adserver_group_view_one">      
      <querytext>
      
            select adv_key, adv_group_number
              from adv_group_map
             where group_key = :group_key
          order by adv_group_number
        
      </querytext>
</fullquery>

 
</queryset>
