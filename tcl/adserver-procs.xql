<?xml version="1.0"?>
<queryset>

<fullquery name="ad_acs_adserver_id_mem.acs_adserver_id_get">      
      <querytext>
      
            select package_id from apm_packages
            where package_key = 'adserver'
        
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_ad_html.ad_rotation_method">      
      <querytext>
      
                    select rotation_method 
                      from adv_groups
                     where group_key=:group_key
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_random_ad_key.adserver_count_group_ads">      
      <querytext>
      
           select adv_count 
             from advs_properties
        
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_random_ad_key.adserver_pick">      
      <querytext>
      
            select adv_key 
              from advs
             where adv_number = :pick
            
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_random_ad_key.adserver_count_group_ads">      
      <querytext>
      
            select adv_count
              from adv_groups
             where group_key = :group_key
        
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_random_ad_key.adserver_group_get">      
      <querytext>
      
        select adv_key 
          from adv_group_map
         where adv_group_number = :pick
           and group_key = :group_key
        
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_sequential_ad_key.adserver_adv_key">      
      <querytext>
      
        select adv_group_number as last,
               ag.adv_count, '0' as max_adv_group_number
          from adv_group_map grp, adv_groups ag, adv_user_map map
         where user_id=:user_id
           and event_time     = (
               select max(event_time) 
                 from adv_user_map map2
                where map2.user_id = :user_id
                  and map2.adv_key = map.adv_key
                  and map2.event_type = 'd'
               )
           and ag.group_key   = :group_key
           and grp.group_key  = :group_key
           and grp.adv_key    = map.adv_key
           and map.user_id    = :user_id
           and map.event_type = 'd'
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_sequential_ad_key.adserver_sequential_get">      
      <querytext>
      
         select adv_key 
           from adv_group_map
          where group_key=:group_key
            and adv_group_number=:adv_group_number
      </querytext>
</fullquery>

 
<fullquery name="adserver_get_ad_html.adserver_get_ad_by_ad_key">      
      <querytext>
                select track_clickthru_p, target_url
                  from advs
                 where adv_key = :adv_key
      </querytext>
</fullquery>

<fullquery name="adserver_get_ad_html.adserver_get_ad_by_adnumber">      
      <querytext>
                select track_clickthru_p, target_url, adv_key
                  from advs
                 where adv_number = :ad_number
      </querytext>
</fullquery>

<fullquery name="adserver_get_ad_html.adserver_get_ad_by_group_and_number">      
      <querytext>
                select a.adv_key, track_clickthru_p, target_url
                  from advs a, adv_group_map m
                 where a.adv_key = m.adv_key
                   and adv_group_number = :ad_number
                   and m.group_key = :group_key
      </querytext>
</fullquery>

</queryset>
