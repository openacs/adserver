<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="adv_log_update_query">      
      <querytext>
      
      update adv_log 
         set display_count = display_count + 1 
       where adv_key = :adv_key 
         and entry_date = trunc (sysdate)
      </querytext>
</fullquery>

 
<fullquery name="adv_insert">      
      <querytext>
      
        insert into adv_log 
               (adv_key, entry_date, display_count) 
        values (:adv_key,
                trunc (sysdate),
                (select 1 from dual 
                         where 0 = (select count (*) 
                                      from adv_log 
                                     where adv_key = :adv_key 
                                      and entry_date = trunc (sysdate))))
      </querytext>
</fullquery>

 
<fullquery name="adv_known_user_insert">      
      <querytext>
      
        insert into adv_user_map (user_id, adv_key, event_time, event_type) 
        values (:user_id, :adv_key, sysdate, 'd')
      </querytext>
</fullquery>

 
</queryset>
