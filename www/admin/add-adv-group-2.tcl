# /www/admin/adserver/add-adv-group-2.tcl

ad_page_contract {
    target page for ad-adv-group.tcl
    
    @param group_key:notnull
    @param pretty_name
    @param rotation_method

    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id add-adv-group-2.tcl,v 3.1.6.6 2000/10/20 23:21:51 avni Exp
} {
    group_key:notnull,trim
    pretty_name:trim
    rotation_method
} -properties {
    title:onevalue
    page_content:onevalue
    admin_link:onevalue
}

db_dml adv_insert_query "
insert into adv_groups (group_key, pretty_name, rotation_method)
select :group_key, :pretty_name, :rotation_method
  from dual
 where not exists (select 1
                     from adv_groups
                    where group_key = :group_key)
"

# The handling of '' and null in Oracle is too weird to do this in the query
if { [empty_string_p $pretty_name] } {
    set pretty_name_sql "pretty_name is null"
} else {
    set pretty_name_sql "pretty_name = :pretty_name"
}
# The trim around rotation_method is necessary since it is a CHAR column,
# not a VARCHAR
set insert_succ_p [db_string adv_insert_check "
select count(*)
  from adv_groups 
 where group_key = :group_key and $pretty_name_sql
   and trim(rotation_method) = :rotation_method" ]
db_release_unused_handles

if { $insert_succ_p } {
    ad_returnredirect "one-adv-group?[export_url_vars group_key]"
} else {
    set title "Adding group failed"
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

    append page_content "
    <p> Insert_succ_p $insert_succ_p: /$group_key/$pretty_name/$rotation_method/
    <p> We are sorry. The group <i>$group_key</i> could not be added. There already is a
    group with the same group name. 
    <p> Please use the back button on your browser and change the group name.
    "

    ad_return_template default
}


