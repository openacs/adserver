# /www/admin/adserver/all-advs.tcl

ad_page_contract {
    @param none
    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id $Id$
} {

}  -properties {
    title:onevalue
    page_content:onevalue
    admin_link:onevalue
}

set title "Manage Ads"
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
<ul>
<li> <a href='add-adv'>Add</a> a new ad.
<p>
"

set sql_query "
select adv_key
  from advs
 order by upper(adv_key)
"

db_foreach adv_select_advs_query $sql_query {
    append page_content "<li> <a href='one-adv?[export_url_vars adv_key]'>$adv_key</a>\n"
}

db_release_unused_handles

append page_content "</ul>
<p>
"

ad_return_template default
