# /www/adserver/view-group.tcl

ad_page_contract {

    adserver view entire group

    @param none
    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id $Id$
} {
    group_key:notnull,trim
} -properties {
    title:onevalue
    page_content:onevalue
    admin_p:onevalue
    admin_link:onevalue
}

set package_id [ad_conn package_id]
ad_require_permission $package_id admin

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

set page_content ""

set title       "Ads in group $group_key"
if {[db_0or1row adserver_group_view "
        select pretty_name, adv_count, rotation_method
          from adv_groups
         where group_key = :group_key
    "]} {
        append page_content "
        <blockquote>
        <h3>Group $pretty_name</h3>
        <ul>
         <li>group key: $group_key
         <li>$adv_count ads in group
         <li>rotation method: $rotation_method
        </ul>
        <table cellspacing=0 cellpadding=0 border=0>
        "
        db_foreach adserver_group_view_one "
            select adv_key, adv_group_number
              from adv_group_map
             where group_key = :group_key
          order by adv_group_number
        " {
              append page_content "
              <blockquote>
              <tr><td>$adv_group_number</td><td>&nbsp;&nbsp;</td><td>$adv_key</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
              <td>
              [adserver_get_ad_html -suppress_logging -ad_number $adv_group_number $group_key]
              </td>
              </tr>
              <tr><td>&nbsp;</td></tr>
              </blockquote>
              "
        }
        append page_content "
        </table>
        </blockquote>
        "
} else {
    set page_content "
    I am sorry, we could not find a group for \"$group_key\"
    "
}

ad_return_template default

