

--eventuell vorhandene datenbankspezifische benutzerdefinierte
--Fehlermeldungen entfernen

if exists(select * from sys.messages where message_id = 50100)
	execute sp_dropmessage '50100', 'all';
go

--eventuell vorhandene Datenbank "Standard" löschen


if exists(select * from sys.databases where database_id = db_id('Standard'))
	drop database Standard;
go

--benutzerdefinierte Fehlermeldung erstellen

sp_addmessage 50100,16,'The delivery of supplier %s of %s, was deleted from the User %s on %s.', 'us_english', 'true';
go
sp_addmessage 50100,16,'Die Lieferung von Lieferant %1! vom %2!, wurde von User %3! am %4! gelöscht', 'German', 'true';
go

--neue Datenbank "Standard" erstellen

create database standard;
/*
on (name = 'Standard',
    filename = 'f:\standard.mdf',
    size = 5MB,
    maxsize = 10MB)
log on (name = 'Standard_Prot',
    filename = 'f:\standard_prot.ldf',
    size = 2MB,
    maxsize = 3MB)
*/
go

use standard;
go


 -- Schemas erstellen
 
 --create schema verwaltung authorization dbo;
 go
 --create schema einkauf authorization dbo;
 go
 


--Tabellen erstellen

create table dbo.artikel
	(
	anr nchar(3) NOT NULL constraint anr_ps primary key 
	constraint anr_chk check(anr like 'a%' and cast(substring(anr,2,2)as int) between 1 and 99),
	aname nvarchar(50) NOT NULL ,
	farbe nchar (7) NULL constraint farbe_chk check( farbe in ('rot', 'blau', 'grün', 'schwarz', 'gelb')),
	gewicht decimal(9,2) NULL ,
	astadt nvarchar(50) NULL ,
	amenge int NULL constraint amenge_chk check( amenge between 0 and 10000));
go


create table dbo.lieferant
	(
	lnr nchar(3) NOT NULL constraint lnr_ps primary key 
	constraint lnr_chk check(lnr like 'l%' and cast(substring(lnr,2,2)as int) between 1 and 99),
	lname nvarchar(50) NOT NULL constraint lname_chk check( lname like '[A-Z]%'),
	status int NULL constraint status_chk check( status between 1 and 99),
	lstadt nvarchar(50) NULL constraint lstadt_chk check( lstadt like '[A-Z]%'));
go


create table dbo.lieferung
	(
	lnr nchar(3) NOT NULL constraint lnr_fs references dbo.lieferant(lnr)
			     on update cascade,
	anr nchar(3) NOT NULL constraint anr_fs references dbo.artikel(anr)
			     on update cascade,
	lmenge int NOT NULL constraint lmenge_chk check( lmenge between 1 and 1000000) ,
	ldatum datetime NOT NULL,
	constraint lief_ps primary key(lnr, anr, ldatum));
go


use standard;
go

--Tabellen mit Anfangsdaten füllen
--Tabelle Lieferant

insert into dbo.lieferant values('L01', 'Schmidt', 20, 'Hamburg');
insert into dbo.lieferant values('L02', 'Jonas', 10, 'Ludwigshafen');
insert into dbo.lieferant values('L03', 'Blank', 30, 'Ludwigshafen');
insert into dbo.lieferant values('L04', 'Clark', 20, 'Hamburg');
insert into dbo.lieferant values('L05', 'Adam', 30, 'Aachen');


--Tabelle Artikel

insert into dbo.artikel values('A01', 'Mutter', 'rot', 12, 'Hamburg', 800);
insert into dbo.artikel values('A02', 'Bolzen', 'grün', 17, 'Ludwigshafen', 1200);
insert into dbo.artikel values('A03', 'Schraube', 'blau', 17, 'Mannheim', 400);
insert into dbo.artikel values('A04', 'Schraube', 'rot', 14, 'Hamburg', 900);
insert into dbo.artikel values('A05', 'Nockenwelle', 'blau', 12, 'Ludwigshafen', 1300);
insert into dbo.artikel values('A06', 'Zahnrad', 'rot', 19, 'Hamburg', 500);


--Tabelle Lieferung

insert into dbo.lieferung values('L01', 'A01', 300, '18.05.90');
insert into dbo.lieferung values('L01', 'A02', 200, '13.07.90');
insert into dbo.lieferung values('L01', 'A03', 400, '01.01.90');
insert into dbo.lieferung values('L01', 'A04', 200, '25.07.90');
insert into dbo.lieferung values('L01', 'A05', 100, '01.08.90');
insert into dbo.lieferung values('L01', 'A06', 100, '23.07.90');
insert into dbo.lieferung values('L02', 'A01', 300, '02.08.90');
insert into dbo.lieferung values('L02', 'A02', 400, '05.08.90');
insert into dbo.lieferung values('L03', 'A02', 200, '06.08.90');
insert into dbo.lieferung values('L04', 'A02', 200, '09.08.90');
insert into dbo.lieferung values('L04', 'A04', 300, '20.08.90');
insert into dbo.lieferung values('L04', 'A05', 400, '21.08.90');
go




--Sicherstellen von Geschäftsregeln
--Addieren der Liefermenge zur entsprechenden Lagermenge bei neuer Lieferung

create trigger menge_lief_neu
on dbo.lieferung
for insert
as
if (select inserted.lmenge from inserted ) > 0
	begin
	 update dbo.artikel
	 set amenge = amenge + inserted.lmenge
	 from dbo.artikel join inserted on artikel.anr = inserted.anr;
	end;
go

--Subtrahieren der Liefermenge vom der entsprechenden Lagermenge
--beim Löschen einer oder mehrerer Lieferungen

create trigger lief_lösch
on dbo.lieferung
for delete
as
 update dbo.artikel
 set amenge = amenge - deleted.lmenge
 from dbo.artikel join deleted on artikel.anr = deleted.anr;
go


--Ändern der Lagermenge des entsprechenden Artikels bei Änderung
--der Liefermenge einer vorhandenen Lieferung

create trigger menge_lief_ändern
on dbo.lieferung
for update
as
if update(lmenge)
   begin
	update dbo.artikel
	set amenge = amenge + inserted.lmenge - deleted.lmenge
	from dbo.artikel join inserted on artikel.anr = inserted.anr
	join deleted on artikel.anr = deleted.anr;
    end;
go


--Ändern der Lagermenge wenn die Artikelnummer einer
--Lieferung geändert wird

create trigger anummer_lief_ändern
on dbo.lieferung
for update
as
if update(anr)
   begin
	update dbo.artikel
	set amenge = amenge - deleted.lmenge
	from dbo.artikel join deleted on artikel.anr = deleted.anr

	update dbo.artikel
	set amenge = amenge + inserted.lmenge
	from dbo.artikel join inserted on artikel.anr = inserted.anr;
    end;
go
