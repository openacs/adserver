<?xml version="1.0"?>
<queryset>

<fullquery name="adv_group_update_query">      
      <querytext>
      
update adv_groups set pretty_name = :pretty_name,
                      rotation_method=:rotation_method
                      where group_key = :group_key
      </querytext>
</fullquery>

 
</queryset>
