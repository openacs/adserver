# /www/admin/adserver/one-adv-detailed-stats.tcl

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


set title "Detailed Statistics: $adv_key"
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

db_1row adv_info_query "select adv_key, adv_filename, track_clickthru_p, target_url from advs where adv_key = :adv_key"

append page_content "
<center>
[adserver_get_ad_html -suppress_logging=$suppress_logging_p -adv_key $adv_key]
"

db_1row adv_numbers_query "
select sum(display_count) as n_displays, 
       sum(click_count) as n_clicks, 
       min(entry_date) as first_display, 
       max(entry_date) as last_display 
from adv_log 
where adv_key = :adv_key"


ns_log NOTICE "n_clicks: $n_clicks"
ns_log NOTICE "n_displays: $n_clicks"

append page_content "</center>

<h3>Summary Statistics</h3>

Between [util_AnsiDatetoPrettyDate $first_display] and [util_AnsiDatetoPrettyDate $last_display], this ad was 

<ul>
<li>displayed $n_displays times 
<li>clicked on $n_clicks times
<li>clicked through [expr 100 * $n_clicks / $n_displays ]% of the time
</ul>

<h3>By Date</h3>

<table cellspacing=3>
<tr><th>Date<th>Displays<th>Clickthroughs</th><th>Clickthrough Rate</tr>

"

set query_sql "select * 
from adv_log 
where adv_key = :adv_key 
order by entry_date"

db_foreach select_query $query_sql  {
    append page_content "<tr><td>[util_AnsiDatetoPrettyDate $entry_date]<td align=right>$display_count<td align=right>$click_count</td><td align=right>"
    if {$display_count > 0} {
	append page_content "[expr 100 * $click_count / $display_count ]%"
    } else {
	append page_content "0%"
    }
    append page_content "</tr>\n"
}

db_release_unused_handles

append page_content "
</table>
<p>
"

ad_return_template default
