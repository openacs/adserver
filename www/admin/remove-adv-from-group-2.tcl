# /www/admin/adserver/remove-adv-from-group-2.tcl

ad_page_contract {
    @param group_key:notnull
    @param adv_key:notnull

    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id remove-adv-from-group-2.tcl,v 3.1.6.4 2000/10/20 23:21:52 avni Exp
} {
    group_key:notnull
    adv_key:notnull
}

db_dml adv_delete_query "
delete
   from adv_group_map
  where group_key = :group_key
    and adv_key = :adv_key
"

db_release_unused_handles

ad_returnredirect "one-adv-group?[export_url_vars group_key]"
