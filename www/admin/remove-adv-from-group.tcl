# /www/admin/adserver/remove-adv-from-group.tcl

ad_page_contract {
    @param group_key:notnull
    @param adv_key:notnull

    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id $Id$
} {
    group_key:notnull
    adv_key:notnull
} -properties {
    title:onevalue
    page_content:onevalue
    admin_link:onevalue
}

set title "Confirm removal of $adv_key"
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

append page_content "
<center>
[adserver_get_ad_html -suppress_logging=$suppress_logging_p -adv_key $adv_key]
</center>
<p>
This won't remove the ad from the system.  You're only deleting the
association between the group $group_key ([db_string adv_name_query "select pretty_name from adv_groups where group_key = :group_key"]) and this ad. 

<p>

<form method=get action='remove-adv-from-group-2'>

[export_form_vars group_key adv_key]

<center>
<input type=submit value='Confirm Removal'>
</center>
</form>

"

db_release_unused_handles

ad_return_template default
