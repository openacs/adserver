<%= [ad_header $title] %>
<h2>@title@</h2>
<%= [eval ad_context_bar [list @title@]] %>
<hr>
<if @admin_p@ eq t>
@admin_link@
</if>
<slave>
<%= [ad_footer] %>