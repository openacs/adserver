<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="adv_insert_query">      
      <querytext>
      
insert into adv_groups (group_key, pretty_name, rotation_method)
select :group_key, :pretty_name, :rotation_method
  from dual
 where not exists (select 1
                     from adv_groups
                    where group_key = :group_key)

      </querytext>
</fullquery>

 
</queryset>
