
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

-- version 2

alter table quest
    alter name set not null,
    alter start_date set not null;

alter table daily_mark
    alter quest set not null,
    alter date set not null;
