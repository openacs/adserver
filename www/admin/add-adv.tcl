# /www/admin/adserver/add-adv.tcl

ad_page_contract {
    @param none
    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id add-adv.tcl,v 3.1.6.5 2000/10/20 23:21:51 avni Exp
} {
    
} -properties {
    title:onevalue
    page_content:onevalue
    admin_link:onevalue
}

set title "Add a new Ad"
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

<FORM METHOD=POST ACTION=add-adv-2>
<TABLE noborder>
<TR><td>Ad Key</td>
    <td><INPUT TYPE=text name=adv_key></td>
    <td>(no spaces please)</td>
</tr>
<tr><td>Link to:</td>
    <td><textarea name=target_url rows=4 cols=40>[ad_parameter DefaultTargetUrl adserver ""]</textarea></td>
    <td>(a URL for the user who clicks on this banner or all of doubleclick stuff)</td>
</tr>
<tr><td>Local Image:</td>
    <td><INPUT TYPE=radio CHECKED name=local_image_p value='t'>Yes <INPUT TYPE=radio name=local_image_p value='f'>No</td>
    <td>(Image resides on this server)</td>
</tr>
<tr><td>Track Clickthru:</td>
    <td><INPUT TYPE=radio CHECKED name=track_clickthru_p value='t'>Yes <INPUT TYPE=radio name=track_clickthru_p value='f'>No</td>
    <td>(No for doubleclick, etc.)</td>
</tr>
<tr><td>Image File Location:</td>
    <td><INPUT TYPE=text name=adv_filename size=30 value='[ad_parameter DefaultAd adserver ""]'></td>
    <td>(pathname or URL of banner GIF, blank for doubleclick, etc.)</td>
</tr>
</table>
<br>
<center>
<INPUT TYPE=submit value=add>
</center>
</FORM>


"

ad_return_template default
