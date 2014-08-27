
create table quest (
    id serial primary key,
    name varchar(2000),
    start_date timestamp without time zone
);

create table daily_mark (
    id serial primary key,
    quest integer references quest,
    date timestamp without time zone
);

create view daily_mark_date as
    select id, quest, date(date) from daily_mark;
