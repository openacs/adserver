# /www/admin/adserver/delete-adv-2.tcl

ad_page_contract {
    @param adv_key:notnull
    @author modified 07/13/200 by mchu@arsdigita.com
    @author modified 10/15/2000 jerry@hollyjerry.org
    @cvs-id delete-adv-2.tcl,v 3.1.6.4 2000/09/22 01:34:19 kevin Exp
} {
    adv_key:notnull
} -properties {
    title:onevalue
    page_content:onevalue
    admin_link:onevalue
}

set title "Deleting $adv_key"
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

<ul>
"

db_transaction {

    db_dml adv_delete_query_1 "delete from adv_log where adv_key = :adv_key"

    append page_content "<li>Deleted [db_resultrows] rows from adv_log.\n"

    db_dml adv_delete_query_2 "delete from adv_user_map where adv_key = :adv_key"
    
    append page_content "<li>Deleted [db_resultrows] rows from adv_user_map.\n"
    
    # db_dml adv_delete_query_3 "delete from adv_categories where adv_key = :adv_key"
    
    append page_content "<li>Deleted [db_resultrows] rows from adv_categories.\n"
    
    db_dml adv_delete_query_4 "delete from adv_group_map where adv_key = :adv_key"
    
    append page_content "<li>Deleted [db_resultrows] rows from adv_group_map.\n"
    
    db_dml adv_delete_query_5 "delete from advs where adv_key = :adv_key"
    
    append page_content "<li>Deleted the ad itself from advs.\n"   
}

db_release_unused_handles

append page_content "</ul>

Transaction complete.

"

ad_return_template default
