# /www/admin/adserver/update-adv-group.tcl

ad_page_contract {
    @param pretty_name
    @param group_key:notnull

    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id $Id$
} {
    pretty_name
    rotation_method
    group_key:notnull
}

db_dml adv_group_update_query "
update adv_groups set pretty_name = :pretty_name,
                      rotation_method=:rotation_method
                      where group_key = :group_key"

db_release_unused_handles

ad_returnredirect "one-adv-group?[export_url_vars group_key]"

