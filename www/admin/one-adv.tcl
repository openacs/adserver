# /www/admin/adserver/one-adv.tcl

ad_page_contract {
    @param adv_key:notnull
    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id $Id$
} {
    adv_key:notnull
} -properties {
    title:onevalue
    page_content:onevalue
    admin_link:onevalue
}

set context {one ad}

set title "One Ad: $adv_key"
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

set selection [ns_set create]

db_1row adv_info_query "select adv_key, 
       adv_filename, 
       local_image_p, 
       track_clickthru_p, 
       target_url 
from advs 
where adv_key = :adv_key"

if {[string equal $track_clickthru_p t]} {
    set clickthru_yes CHECKED
    set clickthru_no "" 
} else {
    set clickthru_yes "" 
    set clickthru_no CHECKED
}

if {[string equal $local_image_p t]} {
    set local_yes CHECKED
    set local_no "" 
} else {
    set local_yes "" 
    set local_no CHECKED
}

set form "
<form method=POST action=update-adv>
<table noborder>
[export_form_vars adv_key]
<tr>
  <td>Ad Key</td>
  <td>$adv_key</td>
</tr>
<tr>
  <td>Link to:</td>
  <td><textarea name=target_url rows=4 cols=60>$target_url</textarea></td>
</tr>
<tr>
  <td>Track Click Throughs:</td>
  <td>
      <input type=radio name=track_clickthru_p $clickthru_yes value='t']>Yes
      <input type=radio name=track_clickthru_p $clickthru_no value='f']>No
</td>
</tr>
<tr>
  <td>Local Image:</td>
  <td>
     <input type=radio name=local_image_p $local_yes value='t']>Yes
     <input type=radio name=local_image_p $local_no value='f']>No
  </td>
</tr>
<tr>
  <td>Image File</td>
  <td>
     <input type=text name=adv_filename value='[ad_quotehtml $adv_filename]' size=60>
  </td>
</tr>
</table>
<br>
<center>
<input type=submit value='Update'>
</center>
</FORM>
"

set page_content "
<center>
[adserver_get_ad_html -suppress_logging=$suppress_logging_p -adv_key $adv_key]
</center>

"

# note that we aren't at risk of dividing by zero because 
# there won't be any rows in this table unless the ad
# has been displayed at least once


set display_count [db_string adv_display_count "
select count(*) from adv_log where adv_key=:adv_key"]

if { $display_count > 0 } {
    db_0or1row adv_info_select "
       select sum (display_count) as n_displays, 
              sum (click_count) as n_clicks, 
              round (100.0 * (sum(click_count) / sum(display_count)), 2) as clickthrough_percent, 
              min (entry_date) as first_display, 
              max (entry_date) as last_display 
       from adv_log 
       where adv_key = :adv_key"
    # we have at least one entry
    append page_content "
    <h3>Summary Statistics</h3>
	   
    Between [util_AnsiDatetoPrettyDate $first_display] and [util_AnsiDatetoPrettyDate $last_display], this ad was 
	   
    <ul>
    <li>displayed $n_displays times  
    <li>clicked on $n_clicks times
    <li>clicked through $clickthrough_percent% of the time
    </ul>
    
    <a href='one-adv-detailed-stats?[export_url_vars adv_key]'>detailed stats</a>
    "   
} else {
    append page_content "<h3>This ad has never been shown</h3>"
}

append page_content "

<h3>Ad Parameters</h3>

$form
<p>

<blockquote>
<font size=-2 face='verdana, arial, helvetica'>
If you only inserted this ad for debugging purposes, you can
take the extreme step of <a href='delete-adv?[export_url_vars adv_key]'>deleting this ad and its associated log entries from the database</a>.]
</font>
</blockquote>
<p>
"

ad_return_template default
