<?xml version="1.0"?>
<queryset>

<fullquery name="adv_group_info_query">      
      <querytext>
      
select group_key, pretty_name
from adv_groups 
where group_key = :group_key
      </querytext>
</fullquery>

 
<fullquery name="r_method">      
      <querytext>
      
                    select rotation_method as current_method
                    from adv_groups where group_key=:group_key
      </querytext>
</fullquery>

 
</queryset>
