# /www/admin/adserver/add-adv-to-group.tcl

ad_page_contract {
    @param group_key:notnull
    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id $Id$
} {
    group_key:notnull
} -properties {
    title:onevalue
    page_content:onevalue
    admin_link:onevalue
}

set title "Add an ad to a group"
set context "Add an ad to a group"
set admin_link "
<table align=right>
<tr>
<td>
<a href='[ad_conn package_url]admin'>admin</a>
<br clear=all>
<a href='/doc/[ad_conn package_key]'>doc</a>
</td>
</tr>
</table>"

# we'll export this to adhref and adimg so that admin actions don't
# corrupt user data
set suppress_logging_p 1

db_1row adv_pretty_name_query "select pretty_name from adv_groups where group_key = :group_key"

set page_content "
Choose an ad to include in this Ad Group:<p>
<ul>
"

set sql_query "select adv_key from advs where adv_key NOT IN (select adv_key from adv_group_map where group_key = :group_key)"

db_foreach adv_get_key_query $sql_query {
    append page_content "<li><a href=\"add-adv-to-group-2?[export_url_vars group_key adv_key]\">$adv_key</a>\n"
}

db_release_unused_handles

append page_content "</ul>
<p>
"

ad_return_template default
