# /www/adserver//index.tcl

ad_page_contract {

    main adserver page

    @param none
    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @author modified 3/20/2001 janine@furfly.net
    @cvs-id index.tcl,v 3.2.2.5 2000/09/22 01:34:19 kevin Exp
} -properties {
    title:onevalue
    page_content:onevalue
    admin_p:onevalue
    admin_link:onevalue
}

set title       "Adserver: and now a word from our sponsors"
set admin_p f
set admin_link ""
set page_content "

Thanks for visiting.  Here's a sampling of our sponsors' ads.

<blockquote>
"
set package_id [ad_conn package_id]

set ads [list]
set count 0
db_foreach adserver_sample_groups {
    select group_key, pretty_name, adv_count, rotation_method
      from adv_groups
     order by group_key
 } {
     incr count
     set ad_content ""
     set suppress_logging 0
     if {[ad_permission_p $package_id admin]} {
         set suppress_logging 1
         set admin_p t
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
         append ad_content "
         <ul>
         <li>pretty name: $pretty_name
         <li>group key: $group_key &nbsp;
           <a href='[ad_conn package_url]view-group?group_key=$group_key'>
           (see all the ads in this group)
           </a>
         <li>$adv_count ads in group
         <li>rotation method: $rotation_method
         </ul>
         "
     }
     
     append ad_content "
     <blockquote>
     [adserver_get_ad_html $group_key]
     </blockquote>
     "
#     [adserver_get_ad_html -method random -suppress_logging=$suppress_logging $group_key]

     lappend ads $ad_content

}

# still show admin and doc links even if there are no ads to display
if { [ad_permission_p $package_id admin] && $count == 0 } {
  append page_content "
No ads defined (and assigned to groups) right now.
<table align=right>
<tr>
<td>
<a href='[ad_conn package_url]admin'>admin</a>
<br clear=all>
<a href='/doc/[ad_conn package_key]'>doc</a>
</td>
</tr>
</table>
<p>
"
} else {
  append page_content [join $ads "\n<hr width=40% align=left >\n"]
}

append page_content "</blockquote>\n"

ad_return_template default

