<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="ad_acs_adserver_url_mem.acs_adserver_mountpoint">      
      <querytext>
      
            select site_node__url(s.node_id)
              from site_nodes s, apm_packages a
             where s.object_id = a.package_id
               and a.package_key = 'adserver'
        
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_ad_html.adserver_defs_adv_update">      
      <querytext>
      
        update adv_log 
           set display_count = display_count + 1 
         where adv_key = :adv_key 
           and entry_date = current_date
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_ad_html.adv_insert">      
      <querytext>
      
                insert into adv_log 
                       (adv_key, entry_date, display_count) 
                values (:adv_key,
                        current_date,
                        (select 1  
                                 where 0 = (select count (*) 
                                              from adv_log 
                                             where adv_key = :adv_key 
                                               and entry_date = current_date)))
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_ad_html.adserver_defs_adv_user_insert">      
      <querytext>
      
                    insert into adv_user_map (user_id, adv_key, event_time, event_type)
                    values (:user_id,:adv_key,current_timestamp,'d')
                
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_ad_html.adserver_get_ad_least_exposure_first">      
      <querytext>

           select 
             map.adv_key, track_clickthru_p, target_url, display_count 
           from 
             adv_group_map map, adv_log log , advs 
           where 
             group_key = :group_key 
             and map.adv_key = advs.adv_key 
             and map.adv_key = log.adv_key 
             and log.entry_date=now()::date

           UNION

           select 
             map.adv_key, track_clickthru_p, target_url, 
           case when 
             display_count is null then 0 else display_count end as display_count 
           from 
             adv_group_map map, advs 
             left join adv_log on (advs.adv_key=adv_log.adv_key and adv_log.entry_date=now()::date) 
           where 
             group_key = :group_key 
             and map.adv_key = advs.adv_key

           order by display_count asc		

	   limit 1

      </querytext>
</fullquery>

</queryset>
