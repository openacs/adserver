# /www/admin/adserver/add-adv-group.tcl

ad_page_contract {
    adds an adv group
    
    @param none
    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id $Id$
} {
    
} -properties {
    title:onevalue
    page_content:onevalue
    admin_link:onevalue
}

set title "Add a new Ad Group"
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
<p>

<FORM METHOD=POST action=add-adv-group-2>
<TABLE noborder>
<TR>
<td>Group Key <br>(no spaces, please!)</td><td><INPUT TYPE=text name=group_key></td></tr>
<tr>
<td>Group Pretty Name<br>(for your convenience)</td><td><INPUT type=text name=pretty_name></td></tr>
<tr>
<td>Rotation Method</td><td><SELECT name=rotation_method>
<option value=least-exposure-first>Least Exposure First
<option value=sequential>Sequential
<option value=random>Random
</select></td></tr>
</TABLE>

<P>
<center>
<INPUT TYPE=submit value=add>
</center>

</FORM>
<p>

"


ad_return_template default