<?xml version="1.0"?>
<queryset>

<fullquery name="adv_insert_check">      
      <querytext>
      
select count(*)
  from adv_groups 
 where group_key = :group_key and $pretty_name_sql
   and trim(rotation_method) = :rotation_method
      </querytext>
</fullquery>

 
</queryset>
