# /www/admin/adserver/one-adv-group.tcl
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

set title "Adserver Administration One Group"
set context {one ad group}
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

set selection [ns_set create]


db_1row adv_group_info_query "
select group_key, pretty_name
from adv_groups 
where group_key = :group_key" -column_set selection

set pretty_name [ns_set get $selection pretty_name]
set page_content ""

set current_method [db_string r_method "
                    select rotation_method as current_method
                    from adv_groups where group_key=:group_key" -default ""]

set current_method [string trim $current_method]

set form "
<FORM METHOD=POST action=update-adv-group>
<TABLE noborder>
<TR>
<td>Group Key</td><td>$group_key</td>
[export_form_vars group_key]
</tr>
<tr>
<td>Group Pretty Name<br>(for your convenience)</td><td><INPUT type=text name=pretty_name value=\"[ad_quotehtml $pretty_name]\" size=40>
</tr>
<tr>
<td>Rotation Method</td><td>
<select name=rotation_method>
[ad_generic_optionlist {"Least Exposure First" "Sequential" "Random"} {"least-exposure-first" "sequential" "random"} $current_method]
</select>
</td>
</tr>

<tr><td>
<INPUT TYPE=submit value=update></td>
</tr>
</TABLE>
</FORM>
"

# append page_content "[bt_mergepiece $form $selection]

append page_content "<p> $form
<h3>Ads in this Group</h3>

These are listed in the order that they will be displayed to users.

<ul>
"

set sql_query "select adv_key 
from adv_group_map 
where group_key = :group_key 
order by upper (adv_key)"

db_foreach adv_select_query $sql_query {
    append page_content "<li> <a href='one-adv?adv_key=$adv_key'>$adv_key</a>
&nbsp;&nbsp; (<a href='remove-adv-from-group?[export_url_vars group_key adv_key]'>remove</a>)
\n"
}

db_release_unused_handles

append page_content "<p>

<li> <A href='add-adv-to-group?[export_url_vars group_key]'>Add</a> an Ad To this Group

</ul>
"

ad_return_template default

