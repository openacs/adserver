<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="ad_acs_adserver_url_mem.acs_adserver_mountpoint">      
      <querytext>
      
            select site_node.url(s.node_id)
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
           and entry_date = trunc (sysdate)
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_ad_html.adv_insert">      
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

 
<fullquery name="adserver_get_ad_html.adserver_defs_adv_user_insert">      
      <querytext>
      
                    insert into adv_user_map (user_id, adv_key, event_time, event_type)
                    values (:user_id,:adv_key,sysdate,'d')
                
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_ad_html.adserver_get_ad_least_exposure_first">      
      <querytext>
                    select map.adv_key, track_clickthru_p, target_url
                      from adv_group_map map, advs_todays_log log, advs
                     where rownum=1
                       and group_key = :group_key
                       and map.adv_key = advs.adv_key
                       and map.adv_key = log.adv_key
                  order by nvl (display_count, 0)
      </querytext>
</fullquery>

</queryset>
