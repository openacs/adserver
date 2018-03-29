# /www/admin/adserver/add-adv-to-group-2.tcl

ad_page_contract {
    target page for add-adv-to-group.tcl

    @param group_key:notnull
    @param adv_key:notnull

    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id $Id$
} {
    group_key:notnull
    adv_key:notnull
}

db_dml adv_insert_query "
insert into adv_group_map (group_key, adv_key) 
select :group_key, :adv_key
  from dual
 where not exists (select 1
                     from adv_group_map
                    where adv_key = :adv_key
                      and group_key = :group_key)
"

# We do not check if the insert succeeded, since it can only fail if this association
# is already in ADV_GROUP_MAP

db_release_unused_handles
ad_returnredirect one-adv-group?[export_url_vars group_key]
