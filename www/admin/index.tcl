# /www/adserver/admin/adserver/index.tcl

ad_page_contract {

    main adserver admin page

    @param none
    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id $Id$
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

set package_id [ad_conn package_id]
# set admin_p     [ad_permission_p $package_id admin]
ad_require_permission $package_id admin

set title       "Adserver Administration"
set page_content "
<ul>

"


# Let's get the groups and their corresponding ads, the ads with no
# groups will arrive at the end

# first get any groups with no ads
set query_sql "
    select group_key, pretty_name
      from adv_groups 
     where not group_key in (select group_key from adv_group_map)"

db_foreach adv_select_query1 $query_sql  {
    if ![empty_string_p $pretty_name] {
	set group_anchor $pretty_name
    } else {
	set group_anchor $group_key
    }
    append page_content \
            "<li>Group <a 
    href='one-adv-group?[export_url_vars group_key]'
    >$group_anchor</a>\n"
}

# now get groups with ads
# outer join gets us all ads, even those
# without groups
set query_sql "
    select map.group_key, advs.adv_key
      from advs, adv_group_map map
     where advs.adv_key = map.adv_key(+)
  order by upper(map.group_key), upper(advs.adv_key)
"

set last_group_key "foobar marker"
set doing_standalone_ads_now_p 0
set first_iteration_p 1
db_foreach adv_select_query2 $query_sql  {
    if { $first_iteration_p && [empty_string_p $group_key] } {
	# this installation doesn't use groups apparently
	set doing_standalone_ads_now_p 1
    }
    set first_iteration_p 0
    if { [string compare $group_key $last_group_key] != 0 } {
	if [empty_string_p $group_key] {
	    # we've come to the end of the grouped ads
	    set doing_standalone_ads_now_p 1
	    append page_content "<h4>ads that aren't in any group</h4>"
	} else {
	    set group_pretty_name [db_string adv_name_query "
            select pretty_name
              from adv_groups
             where group_key = :group_key
            "]
	    if ![empty_string_p $group_pretty_name] {
		set group_anchor $group_pretty_name
	    } else {
		set group_anchor $group_key
	    }
            set href "one-adv-group?[export_url_vars group_key]"
	    append page_content "
            <li>Group <a href='$href'>$group_anchor</a>:
            "
	}
	set last_group_key $group_key
    }
    if $doing_standalone_ads_now_p {
	append page_content "<li>"
    }
    append page_content "
    <a href='one-adv?[export_url_vars adv_key]'>$adv_key</a>
    "
}

db_release_unused_handles

append page_content "<p>

<li>Create a new <a href='add-adv'>ad</a> | 
                 <a href='add-adv-group'>ad group</a>

</ul>

Documentation for this subsystem is available at 
<a href='/doc/adserver'>/doc/adserver.html</a>.

"

ad_return_template default
