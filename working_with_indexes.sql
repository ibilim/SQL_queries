use standard;
go
     --------------------   INDEXes ----------------------
--Indices
--binäre suchen --binary search
--ausbalansieren
--geschwindichkeit 
-- es ist nicht egal grouppirte indezes such as spalte namen a,b,c 

create table indtest
	(lfd_nr int identity(1,1),
	datum datetime,
	name varchar(100),
	vorname varchar(100));
go

----gibt es ein Index?

select * from sys.indexes where object_id=object_id('indtest');

go
--ist dr index fragmentiert?

select * from sys.dm_db_index_physical_stats(db_id(), object_id('indtest'),null,null,null);

go

--Datensätze in di tabelle aufnehmen

declare @x int=1;
while @x <= 1000000
begin 
	insert into indtest values
	(getdate(),'Hustensaftschmuggler_' + cast(@x as varchar(100)),
	'Klärchen_' + cast(@x as varchar(100)));
	set @x +=1;
end;
go

select * from sys.dm_db_index_physical_stats(db_id(), object_id('indtest'),null,null,null); 
go

select * from indtest;

alter table indtest add constraint lfdr_pk primary key(lfd_nr);  

------ abfrage ptimieren   >>>>>>>indexes

select name, vorname from indtest
where datum= (select datum from indtest where lfd_nr=48);

select name, vorname,count(*) from indtest
where datum= cast('2021-11-23 11:01:47.620' as datetime2);

select name, vorname,count(*) from indtest
where datum= cast('2021-11-23 11:01:47.620' as datetime2) and vorname> 'Klärchen_70'  ---je mehr bedingungen wir haben je mehr kostet die abfragezeit. 
group by name,vorname
order by vorname desc;

create index datum_ind on indtest(datum);

select name, vorname from indtest
where datum= cast('2021-11-23 11:01:47.620' as datetime2);   ---warnung ist weg dank der create index on datum 


drop index indtest.datum_ind;  

---Selben Index aber mit eingebettenen Spalten    ----- jetz machen wir mit include

create index datum_ind on indtest(datum) include(name,vorname);

select name, vorname from indtest
where datum= cast('2021-11-23 11:01:47.620' as datetime2); 

-----------------


Select lname 
from lieferant 
where lstadt='Hamburg';  --PS index wird verwendet   --unzweckmäßig

--Index der die where klausel abdeckt

create index lstadt_ind on lieferant(lstadt);

Select lname 
from lieferant 
where lstadt='Hamburg';     --Index wird nicht verwendet

drop index lieferant.lstadt_ind;

--Index der die where klausel abdeckt und die Select Liste

create index lstadt_in on lieferant(lstadt,lname);
								
Select lname 
from lieferant 
where lstadt='Hamburg';   --Index wird verwendet

go
--Index der die where klausel abdeckt und die Spalte lname includet

drop index lieferant.lstadt_in;
go
create index lstadt_in on lieferant(lstadt) include(lname);   ---das ist kleiner der oben genante index ist  ---> create index lstadt_in on lieferant(lstadt,lname) 
go
Select lname 
from lieferant 
where lstadt='Hamburg';     ---Index wird auch verwendet

--Index defragmentieren

--feststellen, ob der Index fragmentiert ist
--1. Alle indices einer tabelle
select * from sys.dm_db_index_physical_stats(db_id(), object_id('lieferant'),null,null,null); 
go

--2 . Einen bestimmten index 
 --Index ID das bestimmen 
select name,index_id from sys.indexes
where object_id=object_id('lieferant');
go

select * from sys.dm_db_index_physical_stats(db_id(), object_id('lieferant'),4,null,null); 
go


--bei Einer Fragmentierung bis 30% wird der Index reorganiziert 

alter index lstadt_in on lieferant reorganize;

--bei Einer Fragmentierung über 30% wird der Index rebuild 

alter index lstadt_in on lieferant rebuild;

--oder

create index lstadt_in on lieferant(lstadt) include(lname)
with(drop_existing=on);

--Deaktivieren und aktivieren eines normalen Index

alter index lstadt_in on lieferant disable;
alter index lstadt_in on lieferant rebuild;

--Deaktivieren und aktivieren eines Primärschlüsselindex Index

alter index lnr_pk on lieferant disable;
alter index lnr_pk on lieferant rebuild;

alter table lieferung check constraint lnr_fk;
