-- statement level trigger to perform the swaps.
create or replace function advs_count_afr_del_fun() returns opaque as '
declare
    nextval integer;
    s record;
begin
    -- find the highest numbered ad
    -- advs_properties is guaranteed to exist.
    select adv_count
      into nextval
      from advs_properties;
       -- for update; -- do I need the for update?

    -- for each adnumber to be swapped do
    for s in select swap from advs_swaps order by swap desc loop        

        -- find the ad that has that number and renumber it
        update advs
           set adv_number = s.swap
         where adv_number = nextval - 1;

        -- delete the row 
        delete 
          from advs_swaps 
         where swap = s.swap;
 
        nextval := nextval - 1;
    end loop;

    -- update the highest number
    update advs_properties 
       set adv_count = nextval;

    return new;
end;
' language 'plpgsql';
