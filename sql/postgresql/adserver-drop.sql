--
-- packages/adserver/sql/adserver-drop.sql
--
-- @author jerry@hollyjerry.org
-- @creation-date 2000-10-15
-- @cvs-id $Id$
--

drop view advs_todays_log;
drop trigger advs_count_bfr_insert on advs;
drop function advs_count_bfr_insert_fun();
drop trigger advs_count_afr_del_row on advs;
drop function advs_count_afr_del_row_fun();
drop trigger advs_count_afr_del on advs;
drop function advs_count_afr_del_fun();
drop trigger adv_group_count_bfr_insert on adv_group_map;
drop function adv_group_count_bfr_insert_fun();
drop trigger adv_group_count_afr_del_row on adv_group_map;
drop function adv_group_count_afr_del_row_fun();


drop table adv_log;
drop table adv_user_map;

-- drop table adv_categories;
-- drop table adv_keyword_map;
drop table adv_group_map;
drop table adv_group_swaps;
drop table adv_groups;

drop table advs_properties;
drop table advs_swaps;

drop table advs;
