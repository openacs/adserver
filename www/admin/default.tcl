if { ![info exists title] } {
    set title ""
}
if { ![info exists context_bar] } {
    set context_bar [ad_context_bar [list $title]]
}
if { [info exists admin_p] && $admin_p } { 
    set page_content "$admin_link $page_content"
}

    

