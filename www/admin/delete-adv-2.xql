<?xml version="1.0"?>
<queryset>

<fullquery name="adv_delete_query_1">      
      <querytext>
      delete from adv_log where adv_key = :adv_key
      </querytext>
</fullquery>

 
<fullquery name="adv_delete_query_2">      
      <querytext>
      delete from adv_user_map where adv_key = :adv_key
      </querytext>
</fullquery>

 
<fullquery name="adv_delete_query_4">      
      <querytext>
      delete from adv_group_map where adv_key = :adv_key
      </querytext>
</fullquery>

 
<fullquery name="adv_delete_query_5">      
      <querytext>
      delete from advs where adv_key = :adv_key
      </querytext>
</fullquery>

 
</queryset>
