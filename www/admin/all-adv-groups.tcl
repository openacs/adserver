# /www/admin/adserver/all-adv-groups.tcl

ad_page_contract {
    @param none
    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id all-adv-groups.tcl,v 3.1.6.4 2000/09/22 01:34:18 kevin Exp
} {
    
}  -properties {
    title:onevalue
    page_content:onevalue
    admin_link:onevalue
}

set title "Manage Ad Groups"
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


set page_content "
<p>

<ul>
<li> <a href='add-adv-group'>Add</a> a new ad group.
<p>
"

set sql_query "select group_key, pretty_name from adv_groups"

db_foreach adv_keyname_query $sql_query {
    append page_content "<li> <a href='one-adv-group?[export_url_vars group_key]'>$pretty_name</a>\n"
}

db_release_unused_handles

append page_content "
</ul>
<p>
"

ad_return_template default
