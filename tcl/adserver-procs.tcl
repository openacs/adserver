ad_library {
  definitions for the ad server; adserver_get_ad_html is called by
  .tcl, .adp, or .html pages (by filters, presumably) to generate ad
  IMGs (linked to HREFs).    An API for managing database queries.


  @creation-date 11/15/2000
  @author modified 11/15/2000 by jerry@hollyjerry.org
  @author modified 07/13/2000 by mchu@arsdigita.com
  @cvs-id $Id$

}

############################################################
### internal cache helper function
############################################################
ad_proc -private adserver_cache_refresh {} {
 } {
     return [util_memoize {adserver_cache_refresh_mem} 300]
}

ad_proc -private adserver_cache_refresh_mem {} {
 } {
  return [ad_parameter -package_id [ad_acs_adserver_id] CacheRefresh 600]
}


############################################################
### external api - encapsulate other acs modules
###
### the ACS is 1% inspiration, 99% perspiration
### maybe next time, aD will shell out another 1% to develop an API
### that encapsulates one modules design from another
############################################################

### our package id
ad_proc -public ad_acs_adserver_id {} {
    @return The object id of the adserver if it exists, 0 otherwise.
 } {
    return [util_memoize {ad_acs_adserver_id_mem} 300]
}

ad_proc -private ad_acs_adserver_id_mem {} {} {
    if {[db_table_exists apm_packages]} {
        return [db_string acs_adserver_id_get {
            select package_id from apm_packages
            where package_key = 'adserver'
        } -default 0]
    } else {
            return 0
    }
}
    
### the url to get to an ad
ad_proc -public ad_acs_adserver_url {} {
    @return The url of the adserver mountpoint if it exists, 0 otherwise.
 } {
    return [util_memoize {ad_acs_adserver_url_mem} [adserver_cache_refresh]]
}

ad_proc -private ad_acs_adserver_url_mem {} {} {
    if {[db_table_exists apm_packages]} {
        return [db_string acs_adserver_mountpoint {
            select site_node.url(s.node_id)
              from site_nodes s, apm_packages a
             where s.object_id = a.package_id
               and a.package_key = 'adserver'
        } -default 0]
    } else {
        return 0
    }
}

ad_proc -public ad_acs_adserver_pageroot {} {
    @return The pathname in the filesystem of the adserver www/ directory
 } {
     return [util_memoize {ad_acs_adserver_pageroot_mem} [adserver_cache_refresh]]
}

ad_proc -private ad_acs_adserver_pageroot_mem {} {} {
    return "[acs_root_dir]/packages/adserver/www"
}

############################################################
### basic get ad function - tries to handle all details
############################################################

ad_proc -public adserver_get_ad_html {
    {-user_id ""} 
    {-method ""}
    {-ad_number ""}
    {-suppress_logging:boolean}
    {-adv_key ""}
    {group_key ""}
    {extra_img_tags "border=0"}
 } {
     Gets an ad.  Try's to make it user specific.

     If method is not supplied, it uses the natural ad
     selection method of the group.  Otherwise, it follows method,
     which may be one of least-exposure-first, user-sequential,
     or random.

     if the ad_number is not blank, it should be an integer specifying
     the number of the ad within a group to be retrieved.

     extra_img_tags are not used if track_clickthru is not set
     
     the string $timestamp in the url will be replaced with the
     current timestamp

 } {

    ############################################
    ### part one: build sql to find the right ad
    ############################################

    if {![string equal $adv_key ""]} {
        set sql_query "
                select track_clickthru_p, target_url
                  from advs
                 where adv_key = :adv_key
        "
        set query_name adserver_get_ad_by_ad_key
    } elseif {[string equal $group_key ""]} {
     
         if {[string is integer -strict $ad_number]} {
            set sql_query "
                select track_clickthru_p, target_url, adv_key
                  from advs
                 where adv_number = :ad_number
            "
            set query_name adserver_get_ad_by_adnumber
        } else {

            set adv_key [adserver_get_random_ad_key]
            set query_name adserver_get_ad_by_ad_key
            set sql_query "
                select track_clickthru_p, target_url
                  from advs
                 where adv_key=:adv_key"
        }
    } else {
        if {[string is integer -strict $ad_number]} {
                 set query_name adserver_get_ad_by_group_and_number
            set sql_query "
                select a.adv_key, track_clickthru_p, target_url
                  from advs a, adv_group_map m
                 where a.adv_key = m.adv_key
                   and adv_group_number = :ad_number
                   and m.group_key = :group_key
                "
        } else {
            if {[string equal "" $method]} {
                set query_name adserver_get_ad_by_method
                set rotation_method [db_string ad_rotation_method "
                    select rotation_method 
                      from adv_groups
                     where group_key=:group_key" -default ""]
        
                set rotation_method [string trim $rotation_method]
            } else {
                set rotation_method $method
            }
    
            switch $rotation_method {
                least-exposure-first {
                    set query_name adserver_get_ad_least_exposure_first
                    set sql_query "
                    select map.adv_key, track_clickthru_p, target_url
                      from adv_group_map map, advs_todays_log log, advs
                     where rownum=1
                       and group_key = :group_key
                       and map.adv_key = advs.adv_key
                       and map.adv_key = log.adv_key (+)
                  order by nvl (display_count, 0)"
                }
                user-sequential {
                    set query_name adserver_get_ad_by_ad_key
                    if {[string equal "" $user_id]} {
                        set user_id [ad_get_user_id]
                    }
    
                    set adv_key [adserver_get_sequential_ad_key \
                            -user_id $user_id $group_key]
                    set sql_query "
                    select track_clickthru_p, target_url
                      from advs
                     where adv_key=:adv_key"
                }
                random -
                default {
                    set query_name adserver_get_ad_by_ad_key
                    set adv_key [adserver_get_random_ad_key $group_key]
                    set sql_query "
                    select track_clickthru_p, target_url from advs
                     where adv_key=:adv_key"
                } 
            }
        }
    }

    ##########################################
    ### part two: get the ad from the db
    ### check for the default case
    ##########################################

    if {![db_0or1row $query_name $sql_query]} {
        # couldn't even find one row, use the default ad
        ns_log warning "adserver_get_ad_html asked for an ad " \
                "in the $group_key group but there aren't any (adv_key is $adv_key)"

        set target_url \
            [ad_parameter \
                -package_id [ad_acs_adserver_id] \
            DefaultAdTargetURL /]
        set track_clickthru_p t
        set adv_key default
    }

    # normally we generate the images through a call to adimg
    # wrapped in an adhref href.  If track_clickthru_p is
    # false, just spew out the html contained in target_url forget
    # about it.  This is how we deal with doubleclick and their ild
                
    ######################################################
    ### part three: generate the html
    ###             track the impression now, if necessary
    ###             or spit out doubleclickish url
    ######################################################

    if {[string equal $track_clickthru_p t]} {

        set h_url [adserver_href_attr \
                -suppress_logging=$suppress_logging_p \
                -adv_key $adv_key $target_url]

        set s_url [adserver_src_attr \
                      -suppress_logging=$suppress_logging_p \
                      -adv_key $adv_key]

        set result \
                "<a href='$h_url'><img src='$s_url' $extra_img_tags></a>"
    } else {
        set result $target_url

        # update the impressions since this won't get called
        # through adimg.tcl
        db_dml adserver_defs_adv_update "
        update adv_log 
           set display_count = display_count + 1 
         where adv_key = :adv_key 
           and entry_date = trunc (sysdate)"
                    
        set n_rows [db_resultrows]
                    
        if { $n_rows == 0 } {
            # there wasn't a row in the database; we can't just do
            # the obvious insert because another thread might be
            # executing concurrently
            db_dml adv_insert "
                insert into adv_log 
                       (adv_key, entry_date, display_count) 
                values (:adv_key,
                        trunc (sysdate),
                        (select 1 from dual 
                                 where 0 = (select count (*) 
                                              from adv_log 
                                             where adv_key = :adv_key 
                                               and entry_date = trunc (sysdate))))"
        }
                    
        if {[ad_conn -connected_p]} {

            if {[util_memoize {
                ad_parameter -package_id [ad_acs_adserver_id] DetailedPerUserLoggingP 0
            } [adserver_cache_refresh]]} {
                set user_id [ad_get_user_id]
                if {$user_id == 0} {
                    set user_id [db_null]
                }
                # ignore logged out clicks, for now....
                db_dml adserver_defs_adv_user_insert {
                    insert into adv_user_map (user_id, adv_key, event_time, event_type)
                    values (:user_id,:adv_key,sysdate,'d')
                }
            }
        }
    }
    db_release_unused_handles

    ######################################################
    ### part four: fixup user variables
    ######################################################

    regsub -all {\$timestamp} $result [ns_httptime [ns_time]] result
    return $result
}


############################################################
### internal procs to help get an api helper funcions
### divide and conquer - these routines handle easier cases
############################################################

### pick a random ad
### dumb routine really, ads should not be randomly picked
ad_proc adserver_get_random_ad_key {{group_key ""}} {
    Returns random adv key 
 } {
    if {[string equal "" $group_key]} {
        
        # no group given, pick an ad at random
        set n_available [db_string adserver_count_group_ads "
           select adv_count 
             from advs_properties
        " -default 0]

        set adv_key ""
        # pick an ad, any ad
        if { $n_available > 0} {
            set pick [ns_rand $n_available]
            set adv_key [db_string adserver_pick "
            select adv_key 
              from advs
             where adv_number = :pick
            " -default ""]
        }

        # return the ad you picked (may be "")
        return $adv_key

    } else {
    
        # count the ads in the group
        set n_available [db_string adserver_count_group_ads "
            select adv_count 
              from adv_groups 
             where group_key = :group_key
        " -default 0]
    
        # if none are present in the group, pick a random ad from all ads
        if {$n_available == 0} {
            ns_log warning adserver: non existent group $group_key
            return [adserver_get_random_ad_key]
        }

        # pick a random ad from the group
        set pick [ns_rand $n_available]
    
        # select the ad_key for that ad
        set adv_key [db_string adserver_group_get "
        select adv_key 
          from adv_group_map
         where adv_group_number = :pick
           and group_key = :group_key
        " -default ""]

        # if it's blank, pick a random ad from all ads
        if {[string equal "" $adv_key]} {
            ns_log warning adserver: empty group $group_key
            return [adserver_get_random_ad_key]
        }
        return $adv_key
    }
}

### get the "next" ad in a sequence
ad_proc adserver_get_sequential_ad_key { {-user_id ""} group_key} {
    Returns sequential adv_key
 } {
    if {[string equal "" $user_id]} {
        set user_id [ad_get_user_id]
    }

    set selection [db_0or1row adserver_adv_key {
        select adv_group_number as last,
               ag.adv_count max_adv_group_number
          from adv_group_map grp, adv_groups ag, adv_user_map map
         where user_id=:user_id
           and event_time     = (
               select max(event_time) 
                 from adv_user_map map2
                where map2.user_id = :user_id
                  and map2.adv_key = map.adv_key
                  and map2.event_type = 'd'
               )
           and ag.group_key   = :group_key
           and grp.group_key  = :group_key
           and grp.adv_key    = map.adv_key
           and map.user_id    = :user_id
           and map.event_type = 'd'}]

        if {!$selection} {
            set adv_group_number 0
        } else {
            if {$adv_group_number == [expr $max_adv_group_number - 1]} {
                set adv_group_number 0
            }
        }

     set key [db_string adserver_sequential_get {
         select adv_key 
           from adv_group_map
          where group_key=:group_key
            and adv_group_number=:adv_group_number} -default ""]

     if {[string equal "" $key]} {
         set key [adserver_get_random_ad_key]
     }

     return $key

}

############################################################
### helper functions to generate href and src attributes
############################################################

### generate the href target 
ad_proc -private adserver_href_attr {
    -suppress_logging:boolean
    {-adv_key ""}
    target_url
 } {
    Returns href attribute.  

 } {
     set ad_url "[ad_acs_adserver_url]adhref.tcl?adv_key=[ad_urlencode $adv_key]"
     if {$suppress_logging_p == 1} {
         append ad_url "&suppress_logging_p=1"
     }
    return $ad_url
}

### generate the image src attribute
### only called when track_clickthru is set
ad_proc -private adserver_src_attr {
    -suppress_logging:boolean
    {-adv_key ""}
 } {
    Returns src attribute.  

    Passes suppress_logging to adserver_image_url to build the url.
 } {
     set ad_url "[ad_acs_adserver_url]adimg.tcl?adv_key=[ad_urlencode $adv_key]"
     if {$suppress_logging_p == 1} {
         append ad_url "&suppress_logging_p=1"
     }
     return $ad_url
}

###################################################################
### helper functions to build a file pathanem
###################################################################

### concatenate two pieces of a url.  Gets number of /s right.
ad_proc -private adserver_url_concat {a b} {
    joins a & b, ensuring that the right number of slashes are present
 } {
    set as [string equal / [string range $a end end]]
    set bs [string equal / [string range $b 0 0]]
    if {$as && $bs} {
        return $a[string trimleft $b /]
    } else {
        if {!$as && !$bs} {
            return $a/$b
        } else {
            return $a$b
        }
    }
}

### generate the url for the image src attribute
ad_proc -private adserver_image_url {
    ad_url
 } {
    Builds the url to an image.

    If local_image is true then this routine builds the url to a local
    image as follows:

    If the parameter BaseImagePath starts with a /, \, or it's second
    char is a :, it assumes the BaseImagePath is the beginning of an
    absolute hard drive pathname, and this routine just concatenates
    the ad_url to the BaseImagePath.

    Otherwise, this routine builds the image path by concatenating:
    [ad_acs_adserver_pageroot]/$BaseImagePath/$ad_url

    the return pathname can be returned using ns_returnfile AND not
    ad_returnredirect

 } {

    set image_path [util_memoize {
        ad_parameter -package_id [ad_acs_adserver_id] \
                BaseImagePath adserver
    } [adserver_cache_refresh]]

    # absolute or relative?
    if {[string equal [string range $image_path 0 0] /] ||
        [string equal [string range $image_path 0 0] \\] ||
        [string equal [string range $image_path 1 1] :]} {
        # absolute pathname on unix, mac, or windows
        set url [adserver_url_concat $image_path $ad_url]
    } else {

        # local to the webserver
        set url [adserver_url_concat \
                    [adserver_url_concat \
                        [ad_acs_adserver_pageroot] $image_path] \
                    $ad_url]
    }
    return $url
}
