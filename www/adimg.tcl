# /www/adserver/adimg.tcl

ad_page_contract {
    This page tries to find an image file to serve to the user,
    serves it, closes the TCP connection to the user.
    while this thread is still alive, logs the ad display
    
    @author philg@mit.edu
    @author jerry@hollyjerry.org
    @creation-date 11/24/1999
    @cvs-id $Id$
} {
    {adv_key ""}
    suppress_logging_p:optional
}

# last edited November 24, 1999 to address a concurrency problem 

set display_default_banner_p 0

set adv_key [ns_urldecode $adv_key]

if { ![info exists adv_key] || $adv_key == "" || [string equal $adv_key default]} {
    set display_default_banner_p 1
    set ad_filename_stub [util_memoize {
        ad_parameter -package_id [ad_acs_adserver_id] DefaultAdImage adserver
    } [adserver_cache_refresh]]
    set local_image [util_memoize {
        ad_parameter -package_id [ad_acs_adserver_id] DefaultAdLocalP adserver 1
    } [adserver_cache_refresh]]
} else {
    if { [db_0or1row adv_select "
              SELECT adv_filename as ad_filename_stub, 
                     decode(local_image_p, 't', 1, 0) as local_image
                FROM advs
                WHERE adv_key = :adv_key"] } {
        # correct vars set
    } else {
	set display_default_banner_p 1
    }
}

set ad_filename [adserver_image_url $ad_filename_stub]

if {$local_image == 1 || [string equal $local_image t] } {

    if { ![file isfile $ad_filename] } {
        ns_log Error "Didn't find ad: $ad_filename"

        if {$display_default_banner_p == 1} {
            # we're really in bad shape; no row exists and 
            # we don't have an adv_key
            ns_log Error "adimg.tcl didn't find an ad matching " \
                    "\"$adv_key\" AND no default file exists"
            adserver_notify_host_administrator "define a default ad!" "
            Define a default banner ad in [ad_system_name]
            someone is requesting ads with an
            invalid adv_key of \"$adv_key\"
            "
        } else {
            # punt to the default banner
            set display_default_banner_p 1
            set ad_filename_stub [util_memoize {
                ad_parameter -package_id [ad_acs_adserver_id] DefaultAdImage adserver
            } [adserver_cache_refresh]]
            set local_image [util_memoize {
                ad_parameter -package_id [ad_acs_adserver_id] DefaultAdLocalP adserver 1
            } [adserver_cache_refresh]]
            set ad_filename [adserver_image_url $ad_filename_stub]
        }
    }

    # return the file
    # the no-cache stuff ensures that Netscape browser users never get
    # a cached IMG with a new target

    ns_returnfile 200 "[ns_guesstype $ad_filename]\nPragma: no-cache" \
            $ad_filename
} else {
    # let the remote server provide the image
    ad_returnredirect $ad_filename_stub
    # Should we check for the existence of the ad on the remote host?
    # For now, we don't

}

if { [info exists suppress_logging_p] && $suppress_logging_p == 1 } {
    return
}

# we've returned to the user but let's keep this thread alive to log

ns_conn close

if {$display_default_banner_p == 0} {

    db_dml adv_log_update_query "
      update adv_log 
         set display_count = display_count + 1 
       where adv_key = :adv_key 
         and entry_date = current_date"

    set n_rows [db_resultrows]

    if { $n_rows == 0 } {
        # there wasn't a row in the database; we can't just do the obvious
        # insert because another thread might be executing concurrently
        db_dml adv_insert "
        insert into adv_log 
               (adv_key, entry_date, display_count) 
        values (:adv_key,
                current_date,
                (select 1 from dual 
                         where 0 = (select count (*) 
                                      from adv_log 
                                     where adv_key = :adv_key 
                                      and entry_date = current_date)))"
    }

    if [util_memoize {
        ad_parameter -package_id [ad_acs_adserver_id] DetailedPerUserLoggingP adserver 0
    } [adserver_cache_refresh]] {
        set user_id [ad_get_user_id]
        if { $user_id == 0 } {
            set user_id [db_null]
        } 
        # we know who this user is
        db_dml adv_known_user_insert "
        insert into adv_user_map (user_id, adv_key, event_time, event_type) 
        values (:user_id, :adv_key, sysdate, 'd')"
    }
}

