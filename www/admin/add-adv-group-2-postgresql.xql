<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="adv_insert_query">      
      <querytext>
      
insert into adv_groups (group_key, pretty_name, rotation_method)
select :group_key, :pretty_name, :rotation_method
  
 where not exists (select 1
                     from adv_groups
                    where group_key = :group_key)

      </querytext>
</fullquery>

 
</queryset>
