--
-- packages/adserver/sql/adserver-create.sql
--
-- @author jerry@hollyjerry.org
-- @creation-date 2000-10-15
-- @cvs-id $Id$
--

----------------------------------------
----------------------------------------
-- DEFINE TABLES
----------------------------------------
----------------------------------------

-- a table of advertisements
create table advs (
	adv_key         varchar(200) primary key,
	-- this is useful for integrating with 
        -- third-party ad products and services
        local_image_p	char(1) default 't'
                        constraint advs_local_img_p
                        check (local_image_p in ('t','f')),
	-- 't' indicates that target_url contains lots of html and
	-- this ad should not get wrapped in the clickthrough counter.
	-- This is useful for doubleclick, etc. where they've got
	-- javascript and other nonsense wrapping the ad
	track_clickthru_p char(1) default 't'
                        constraint advs_trk_clk_p
                        check (track_clickthru_p in ('t','f')),
	-- a stub, relative to [ns_info pageroot] if local_image_p, or
	-- a url if !local_image_p
	adv_filename    varchar(200),
	target_url      varchar(4000),
        adv_number      integer default null
);

-- **** move the unique index into a separate tablespace
-- constraint adv_log_u unique (adv_key,entry_date) 
-- using index tablespace photonet_index

create table adv_log (
	adv_key         varchar(200) not null references advs on delete cascade,
	entry_date      date not null,
	display_count   integer default 0,
	click_count     integer default 0,
	unique(adv_key,entry_date)
);

-- for publishers who want to get fancy

create table adv_user_map (
	user_id         integer references users on delete cascade,
	adv_key         varchar(200) references advs on delete cascade,
	event_time      date not null,
	-- will generally be 'd' (displayed) 'c' (clicked through)
	event_type      char(1)
);


create index adv_user_map_idx on adv_user_map(user_id);

/*

-- commented out until ACS 4 categories gets developed.

-- for publishers who want to get really fancy 

create table adv_categories (
	adv_key         not null references advs
                        on delete cascade,
	category_id     integer not null references categories
                        on delete cascade,
	unique(adv_key, category_id)
);

*/

-- a table of advertisement properties, namely keeping the
-- track of the number of ads in the database
create table advs_properties (
       adv_count	 integer
);
insert into advs_properties values (0);

-- a table of adnumbers that have been deleted and that
-- have yet to be reflected in the adv_count
create table advs_swaps (
       swap integer
);

--------------------------------------------------
--------------------------------------------------
-- stuff built on top of the raw ad server layer 
--------------------------------------------------
--------------------------------------------------

-- this is for publishers who want to rotate ads within a group

-- any ad can be a member of one or more adv_groups
-- this table lists each ad group (something like 'sports ads',
-- or 'pokemon ads', or 'XXX ads') and this table keeps
-- track of the number of ads in each group

create table adv_groups (
	group_key	varchar(30) not null primary key,
	pretty_name	varchar(50),
        adv_count       integer default(0), -- number of advs in group
	-- need to define some rotation methods 
        -- sequential: show the ads to THAT user 
        -- in the order specified in adv_group_map
	-- least-exposure-first: show the ad that has been shown the
	-- least number of times that day; random: show a random ad
	rotation_method char(35) default 'sequential'
                        constraint ad_grp_rotation_method
                        check (rotation_method in (
                              'sequential',
                              'least-exposure-first',
                              'random'))
);



-- a relationship: this ad is in this group and has this adnumber.
-- Is there an oracle bug here?
-- if the second on delete cascade is present, then when this 
-- script is sourced, if you type 
-- delete from advs
-- then your Oracle session will crash:
-- delete from advs
-- *
-- ERROR at line 1:
-- ORA-03113: end-of-file on communication channel

create table adv_group_map ( 
       group_key varchar(30) not null references adv_groups on delete cascade, 
       -- ORACLE BUG NOTE: why is this on delete cascade bad?
       -- to see the oracle bug, comment out the line with the comma,
       -- and uncomment the on delete cascade line
       adv_key varchar(200) not null references advs
             , 
             --  on delete cascade, 
       adv_group_number integer default null, 
       primary key (group_key,adv_key) 
);

-- a table of ads that were deleted from a group and has yet
-- to be reflected in that groups adv_count.
create table adv_group_swaps (
       group_key varchar(30) not null references adv_groups on delete cascade,
       swap integer
);


-- This view is used to select ads for display based on the current
-- days impression count
create view advs_todays_log AS
SELECT * FROM adv_log WHERE entry_date = current_date;

-- insert into advs (
--    adv_key, local_image_p, track_clickthru_p, adv_filename, target_url
-- ) values (
--   'ArsDigita', 't', 't', 'arsdigita.gif', 'http://www.arsdigita.com'
-- );

commit;

--------------------------------------------------
--------------------------------------------------
-- TRIGGERS TO MAINTAIN AD COUNT FOR ALL ADS
--------------------------------------------------
--------------------------------------------------

/* 

I have several triggers defined to help me maintain the adv_count of
all ads.  I need two triggers and the advs_swaps to get around the
mutating advs table;

Some of this code and it's model is discussed here
http://www.arsdigita.com/bboard/q-and-a-fetch-msg?msg_id=000KZ0&topic_id=web%2fdb&topic=

On insert, we find the current adv_count for all ads and use that 
for the adv_number, and then we increment the adv_count.

On deletions, two triggers run: a row trigger inserts adv_number of
the ad being deleted into the advs_swaps table. When all the row
triggers are done, a statement trigger sweeps over all the numbers to
be in the advs_swaps table and for each number it finds there, it
finds the entry with the highest adv_number and changes adv_number to
be the number in the swap table.  Having done that it deletes the row
in the swap table.  And repeats for the next row.

Here's the insertion of a new ad trigger:

*/

-- trigger to insert an advertisement and
-- automatically determine/maintain the highest
-- advertisement number
create function advs_count_bfr_insert_fun() returns opaque as '
declare
        top integer;
begin
    -- advs_properties is guaranteed to exist
    select adv_count 
      into top 
      from advs_properties;
       -- for update;

    new.adv_number := top;

    update advs_properties 
       set adv_count = adv_count + 1;

    return new;
end;
' language 'plpgsql';

create trigger advs_count_bfr_insert
before insert on advs
for each row execute procedure advs_count_bfr_insert_fun();

-- row level trigger to "save" an intermediate 
-- adnumber to be swapped for the "high" adnumber.
-- for each row to be deleted do:
create function advs_count_afr_del_row_fun() returns opaque as '
begin
    insert into advs_swaps values (old.adv_number);

    return new;
end;
' language 'plpgsql';

create trigger advs_count_afr_del_row
after delete on advs
for each row execute procedure advs_count_afr_del_row_fun();

-- statement level trigger to perform the swaps.
create function advs_count_afr_del_fun() returns opaque as '
declare
    next integer;
    s record;
begin
    -- find the highest numbered ad
    -- advs_properties is guaranteed to exist.
    select adv_count
      into next
      from advs_properties;
       -- for update; -- do I need the for update?

    -- for each adnumber to be swapped do
    for s in select swap from advs_swaps order by swap desc loop        

        -- find the ad that has that number and renumber it
        update advs
           set adv_number = s.swap
         where adv_number = next - 1;

        -- delete the row 
        delete 
          from advs_swaps 
         where swap = s.swap;
 
        next := next - 1;
    end loop;

    -- update the highest number
    update advs_properties 
       set adv_count = next;

    return new;
end;
' language 'plpgsql';

create trigger advs_count_afr_del
after delete on advs for each row execute procedure advs_count_afr_del_fun();



--------------------------------------------------
--------------------------------------------------
-- TRIGGERS TO MAINTAIN AD COUNT FOR GROUPED ADS
--------------------------------------------------
--------------------------------------------------

/* 

I have several triggers defined to help me maintain the
adv_group_number.  I need two triggers and the adv_group_swap to get
around the mutating adv_group_map table;

On insert, we find the current adv_count for that group and use that 
for the adv_group_number, and then we increment the adv_count.

On deletions, two triggers run: a row trigger inserts adv_group_number
of the ad being deleted into the adv_group_swap table. When all the
row triggers are done, a statement trigger sweeps over all the numbers
to be in the adv_group_swaps table and for each number it finds there,
it finds the entry with the highest adv_group_number in the
adv_group_map table (for the same group) and changes adv_group_number
to be the number in the swap table.  Having done that it deletes the
row in the swap table.  And repeats for the next row.

Here's the insertion of a new ad into a group trigger:

*/

create function adv_group_count_bfr_insert_fun() returns opaque as '
declare 
    top integer; 
begin 
    select adv_count 
      into top 
      from adv_groups 
     where group_key = new.group_key; -- for update;

     new.adv_group_number := top;

     update adv_groups 
        set adv_count = adv_count + 1 
      where group_key = new.group_key; 

     return new;
end; 
' language 'plpgsql';


create trigger adv_group_count_bfr_insert 
before insert on adv_group_map 
for each row execute procedure adv_group_count_bfr_insert_fun();

/*

And here are the two triggers that maintain the top count after a row
is deleted:

*/

create function adv_group_count_afr_del_row_fun() returns opaque as '
begin 
    update adv_group_map set adv_group_number=adv_group_number-1 where adv_group_number>old.adv_group_number and group_key=old.group_key;

    update adv_groups set adv_count=adv_count-1 where group_key=old.group_key;

    return new;
end; 
' language 'plpgsql';


create trigger adv_group_count_afr_del_row 
after delete on adv_group_map 
for each row execute procedure adv_group_count_afr_del_row_fun();

insert into advs (adv_key, local_image_p, track_clickthru_p, adv_filename, target_url) 
values ('ArsDigita', 't', 't', 'arsdigita.gif', 'http://www.arsdigita.com');
/*
-- test cases
delete from advs;
delete from advs_properties;
delete from advs_swaps;
insert into advs_properties values (0);
insert into advs values('a', 't', 't', 'abc', 'http://abc',null);
insert into advs values('b', 't', 't', 'abc', 'http://abc',null);
insert into advs values('c', 't', 't', 'abc', 'http://abc',null);
insert into advs values('d', 't', 't', 'abc', 'http://abc',null);
insert into advs values('e', 't', 't', 'abc', 'http://abc',null);
insert into advs values('f', 't', 't', 'abc', 'http://abc',null);
insert into advs values('g', 't', 't', 'abc', 'http://abc',null);
insert into advs values('h', 't', 't', 'abc', 'http://abc',null);
insert into advs values('i', 't', 't', 'abc', 'http://abc',null);
insert into advs values('j', 't', 't', 'abc', 'http://abc',null);
insert into advs values('k', 't', 't', 'abc', 'http://abc',null);
insert into advs values('l', 't', 't', 'abc', 'http://abc',null);
insert into advs values('m', 't', 't', 'abc', 'http://abc',null);
insert into advs values('n', 't', 't', 'abc', 'http://abc',null);
insert into advs values('o', 't', 't', 'abc', 'http://abc',null);
insert into advs values('p', 't', 't', 'abc', 'http://abc',null);
insert into advs values('q', 't', 't', 'abc', 'http://abc',null);
insert into advs values('r', 't', 't', 'abc', 'http://abc',null);
insert into advs values('s', 't', 't', 'abc', 'http://abc',null);
insert into advs values('t', 't', 't', 'abc', 'http://abc',null);
insert into advs values('u', 't', 't', 'abc', 'http://abc',null);
insert into advs values('v', 't', 't', 'abc', 'http://abc',null);
insert into advs values('w', 't', 't', 'abc', 'http://abc',null);
insert into advs values('x', 't', 't', 'abc', 'http://abc',null);
insert into advs values('y', 't', 't', 'abc', 'http://abc',null);
insert into advs values('z', 't', 't', 'abc', 'http://abc',null);
select adv_key, adv_number, adv_count from advs, advs_properties;

delete from adv_groups;
delete from adv_group_map;
delete from adv_group_swaps;

insert into adv_groups (group_key, pretty_name, adv_count) 
       values('aaa', 'aaa', 0);
insert into adv_groups (group_key, pretty_name, adv_count) 
       values('bbb', 'bbb', 0);
insert into adv_groups (group_key, pretty_name, adv_count) 
       values('ccc', 'ccc', 0);
insert into adv_groups (group_key, pretty_name, adv_count) 
       values('ddd', 'ddd', 0);

insert into adv_group_map (group_key, adv_key) values('aaa', 'a');
insert into adv_group_map (group_key, adv_key) values('aaa', 'b');
insert into adv_group_map (group_key, adv_key) values('aaa', 'c');
insert into adv_group_map (group_key, adv_key) values('aaa', 'd');
insert into adv_group_map (group_key, adv_key) values('aaa', 'e');
insert into adv_group_map (group_key, adv_key) values('aaa', 'f');
insert into adv_group_map (group_key, adv_key) values('aaa', 'g');
insert into adv_group_map (group_key, adv_key) values('aaa', 'h');
insert into adv_group_map (group_key, adv_key) values('aaa', 'i');
insert into adv_group_map (group_key, adv_key) values('aaa', 'j');
insert into adv_group_map (group_key, adv_key) values('aaa', 'k');
insert into adv_group_map (group_key, adv_key) values('aaa', 'l');
insert into adv_group_map (group_key, adv_key) values('bbb', 'm');
insert into adv_group_map (group_key, adv_key) values('bbb', 'n');
insert into adv_group_map (group_key, adv_key) values('bbb', 'o');
insert into adv_group_map (group_key, adv_key) values('bbb', 'p');
insert into adv_group_map (group_key, adv_key) values('bbb', 'q');
insert into adv_group_map (group_key, adv_key) values('bbb', 'r');
insert into adv_group_map (group_key, adv_key) values('aaa', 's');
insert into adv_group_map (group_key, adv_key) values('ccc', 't');
insert into adv_group_map (group_key, adv_key) values('ccc', 'u');
insert into adv_group_map (group_key, adv_key) values('ccc', 'v');
insert into adv_group_map (group_key, adv_key) values('ccc', 'w');
insert into adv_group_map (group_key, adv_key) values('ddd', 'x');
insert into adv_group_map (group_key, adv_key) values('ddd', 'y');
insert into adv_group_map (group_key, adv_key) values('ddd', 'z');

commit;

*/
