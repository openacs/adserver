# /www/admin/adserver/delete-adv.tcl

ad_page_contract {
    @param adv_key:notnull
    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id delete-adv.tcl,v 3.2.2.5 2000/10/20 23:21:51 avni Exp
} {
    adv_key:notnull
} -properties {
    title:onevalue
    page_content:onevalue
    admin_link:onevalue
}

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

db_1row adv_info_query "
select sum (display_count) as n_displays, 
       sum (click_count) as n_clicks, 
       min (entry_date) as first_display, 
       max (entry_date) as last_display, 
       round (max (entry_date) - min (entry_date)) as n_days, 
       count (*) as n_entries 
from adv_log 
where adv_key = :adv_key"



set title "Confirm Deletion of $adv_key"

append page_content "

<center>
[adserver_get_ad_html -suppress_logging=$suppress_logging_p -adv_key $adv_key]
</center>

If what you want to do is stop showing an ad to users, you're in the
wrong place.  What you should be doing instead is changing the places
that reference this ad to reference some other ad.  Ads that have been
shown to users should never be deleted from the system because that
also deletes the logs.

<p>

Here's what you'll be deleting if you delete this ad:

<ul>
<li>$n_entries log entries 
<li>covering $n_days days (from $first_display to $last_display)
<li>during which there were $n_displays displays and $n_clicks clickthroughs 
</ul>

<p>

If you don't want to do that, then you can simply <a
href=''>return to ad server administration</a>.

<p>

However, if you only put this ad in the database for a demonstration
or experiment and never actually showed it to any users, then you can 

<center>
<form method=GET action='delete-adv-2'>
[export_form_vars adv_key]
<input type=submit value='Confirm deletion of this ad and its log entries'>
</form>
</center>

"

ad_return_template default