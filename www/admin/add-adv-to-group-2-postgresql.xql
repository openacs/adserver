<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="adv_insert_query">      
      <querytext>
      
insert into adv_group_map (group_key, adv_key) 
select :group_key, :adv_key
  
 where not exists (select 1
                     from adv_group_map
                    where adv_key = :adv_key
                      and group_key = :group_key)

      </querytext>
</fullquery>

 
</queryset>
