<html>
<!--AD_DND-->
<head>
<title>/adserver system</title>
</head>

<body bgcolor=#ffffff text=#000000>
<h2>/adserver system</h2>

part of the <a href="/doc/">ArsDigita Community System</a> by <a
href="http://arsdigita.com">ArsDigita</a> and <a
href="http://furfly.net">others</a>.

<hr>

<ul>
<li>User-accessible directory:  none 
<li>Site administrator directory:  <a href="/adserver/admin">/adserver/admin</a>
<li>data model:  <a href="/doc/sql/display-sql?url=/doc/sql/adserver.sql">/doc/sql/adserver.sql</a>

</ul>

Remember that the underlying rationale for the ad server is set forth in
<a href="http://photo.net/wtr/thebook/community">Chapter 3 of "the
book"</a>.

<P>

The major feature of the adserver not covered by the book is that
there is a notion of ad groups.  For example, if there are four ads
that you'd like a user to see in sequence, you can make them part of a
group and then make all the pages in a section of a site reference
that group.  The page need only call <code>adserver_get_ad_html</code>
with the <code>group_key</code> as an argument and it will get back a
reference to the next appropriate ad from that group.

<p>

Groups can be used for management or for selection of ads.  For
instance, you may have the <i>Amazon</i> group, indicating ads placed
by Amazon.com.  You may have a <i>sports</i> group, indicating ads
that are related to sports.  You might have a <i>frontpage</i> group,
for ads that should appear on the frontpage.  Ads can be members of
more than one group.

<p> 

Within a group, ads can be chosed randomly, in sequential order, or
the least seen ad can be the next ad chosen.

GIF or JPEG files for ads are stored in /ads.   

<p>
The basic html for an ad looks like:
<blockquote>
<pre>
&lt;a href="/adserver/adhref?adv_key=pfizer"&gt;
&lt;img src="/adserver/adimg?adv_key=pfizer"&gt;
&lt;/a&gt;
</pre>
</blockquote>
These references can be created for you in many ways:
<ul>

<li> <tt>adserver_get_ad_html <i>group_key</i></tt> returns an ad from
the group using the group selection mechanism

<li> <tt>adserver_get_ad_html -adv_key [adserver_get_random_ad_key
<i>group_key</i>]</tt> returns a random ad from the group.

<li> <tt>adserver_get_ad_html -adv_key
[adserver_get_random_ad_key]</tt> returns a random ad from the entire
collection.

</ul>

<p>

If the ad server gets confused, it tries to always serve up something
to fill the space.  It looks for <code>[ad_parameters
DefaultAd]</code> and <code>[ad_parameters DefaultTargetUrl]</code>.
If it can't find those, it notifies the site administrator to define
them.

<%= [ad_footer] %>
</body>
</html>
