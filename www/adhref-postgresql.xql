<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="adv_known_user_insert">      
      <querytext>
      
    insert into adv_user_map (user_id, adv_key, event_time, event_type) 
    values (:user_id, :adv_key, current_timestamp, 'c')
    
      </querytext>
</fullquery>

 
<fullquery name="adv_update_query">      
      <querytext>
      
update adv_log 
   set click_count = click_count + 1 
 where adv_key = :adv_key 
   and entry_date = current_date
    
      </querytext>
</fullquery>


<fullquery name="adv_insert">      
      <querytext>
    insert into adv_log
           (adv_key, entry_date, click_count)
    values (:adv_key,
            current_date,
            (select 1 from dual 
                     where 0 = (select count (*) 
                                  from adv_log 
                                 where adv_key = :adv_key 
                                   and entry_date = current_date)))"
    db_dml adv_insert $insert_sql
      </querytext>
</fullquery>

</queryset>
