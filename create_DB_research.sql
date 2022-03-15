---------> Datenbank FORSHUNG <-------
use master;
go

---erstellen von datenbank Forshung
drop database Forschung;
create database Forschung
on primary
	(name=forschung_kat,
	filename='e:\dbdaten\forschung_kat.mdf',
	size=1 GB,
	maxsize=20 GB,
	filegrowth= 500 MB),
filegroup passiv
	(name=forschung_daten1,
	filename= 'h:\dbdaten\forschung_ndf.ndf',
	size=1 GB,
	maxsize=20 GB,
	filegrowth= 500 MB),
filegroup aktiv
	(name=forschung_daten2,
	filename='i:\dbdaten\forschung_daten2.ndf',
	size=1 GB,
	maxsize=20 GB,
	filegrowth= 500 MB)
log on 
	(name=forshung_prot,
	filename= 'f:\dbprotokoll\forshung_prot.ldf',
	size= 300 MB,
	maxsize= 20 GB,
	filegrowth= 10 %);

use Forschung;
go

exec sp_helpdb Forschung;

---Erstellen von standard typen

create type namen from nvarchar(200) not null;


--- erstellen von ARBEITEN Tabellen in Aktiv Dataigruppe

create table dbo.arbeiten
		(m_nr int  not null identity(1000,1),    ---??
		pr_nr char(4) not null,
		aufgabe namen not null,
		einst_dat datetime,
		check (pr_nr like 'p%'),
		check ((cast (substring(pr_nr,2,3) as int)<151)),
		check (substring(aufgabe,1,1) like '%[A-Z]'),
		check (datediff(dd,getdate(),einst_dat)<8)) on aktiv;
go


exec sp_help arbeiten;

--- Änderung des filegroups to passiv   ---> notmalawise wurde speicherung auf primary gestellt. 
Alter database Forschung modify filegroup passiv default;


create table dbo.mitarbeiter 
		(m_nr int not null identity(1000,1),
		m_name  namen not null ,
		m_vorname  namen not null,
		ortid int not null    ,
		strasse namen  ,
		geb_dat datetime ,
		abt_nr  char(3),
		check (substring(abt_nr,1,1)='a' and (cast (substring(abt_nr,2,2) as int) between 1 and 50)),
		 check (substring(abt_nr,1,1)='a' and (cast (substring(abt_nr,2,2) as int) between 1 and 50)));
go

create table dbo.telefon
		(m_nr int not null identity(1000,1),
		vorw smallint not null,
		tel_nr smallint not null);
go

create table dbo.orte 
		(ortid int  not null  ,
		plz  char(5) not null,
		ortsname namen not null,
		check (plz like '%[0-9]%' ),
		check (substring(ortsname,1,1) like '%[A-Z]'));

go

create table dbo.abteilung
		(abt_nr char(3) not null,
		abt_name  namen not null,
		ortid  int not null,
		check (substring(abt_nr,1,1)='a' and (cast (substring(abt_nr,2,2) as int) between 1 and 50)),
		check (abt_name in ('Weimar','Erfurt','Jena','Gotha','Suhl','Nordhausen','Sömmerda')),
		check (substring(abt_name,1,1) like '%[A-Z]'));
go

create table dbo.projekt
		(pr_nr char(4) not null ,
		pr_name  namen not null,
		mittel money not null,
		check (pr_nr like 'p%'),
		check ((cast (substring(pr_nr,2,3) as int)<151)),
		check (mittel<2000000),
		check (substring(pr_name,1,1) like '%[A-Z]'));
go


-- Erstellen von primary keys

alter table mitarbeiter add constraint mitarbeiter_pk primary key(m_nr);
go

alter table telefon add constraint telefon_pk primary key(vorw,tel_nr);
go

alter table arbeiten add constraint arbeiten_pk primary key(m_nr,pr_nr);
go

alter table projekt add constraint projekt_pk primary key(pr_nr);
go

alter table orte add constraint orte_pk primary key(ortid);
go

alter table abteilung add constraint abteilung_pk primary key(abt_nr);
go

--erstellen von foreign keys

alter table mitarbeiter add constraint abt_nr_fk foreign key(abt_nr) references abteilung(abt_nr)
on update cascade;
go

alter table mitarbeiter add constraint ort_nr_fk foreign key(ortid) references orte(ortid)
on update cascade;
go

alter table telefon add constraint mitarbeiter_fk foreign key(m_nr) references mitarbeiter(m_nr)
on update cascade;
go

alter table arbeiten add constraint projekt_nr_fk foreign key(pr_nr) references projekt(pr_nr)
on update cascade;
go

alter table arbeiten add constraint mitarbeiter_nr_fk foreign key(m_nr) references mitarbeiter(m_nr)
on update cascade;
go

alter table abteilung add constraint orte_nr_fk foreign key(ortid) references orte(ortid);
go




-- addition von constraints

alter table arbeiten add constraint pr_nr_chk1 check (pr_nr like 'p%');
alter table arbeiten add constraint pr_nr_chk2 check ((cast (substring(pr_nr,2,3) as int)<151  );  

alter table arbeiten add constraint aufgabe_name_chk1 check (substring(aufgabe,1,1) like '%[A-Z]');
alter table arbeiten add constraint einstieg_datum_chk1 check (datediff(dd,getdate(),einst_dat)<8);


alter table mitarbeiter add constraint mr_nr_chk1 check (m_nr>=1000);
alter table mitarbeiter add constraint mr_nr_chk2 check (m_nr like '____');
alter table mitarbeiter add constraint abt_nr_chk1 check (substring(abt_nr,1,1)='a' and (cast (substring(abt_nr,2,2) as int) between 1 and 50)); 


alter table telefon add constraint mr_nr_chk3 check (m_nr>=1000);

alter table projekt add constraint pr_nr_chk1 check (pr_nr like 'p%');
alter table projekt add constraint pr_nr_chk2 check (int(substring(pr_nr,2,3))<151 );
alter table projekt add constraint mittel_chk1 check (mittel<2000000);
alter table projekt add constraint pr_name_chk1 check (substring(pr_name,1,1) like '%[A-Z]');


alter table abteilung add constraint abt_nr_chk2 check (substring(abt_nr,1,1)='a' and (cast (substring(abt_nr,2,2) as int) between 1 and 50));
alter table abteilung add constraint abt_name_chk1  check (abt_name in ('Weimar','Erfurt','Jena','Gotha','Suhl','Nordhausen','Sömmerda'));
alter table abteilung add constraint abt_name_chk2 check (substring(abt_name,1,1) like '%[A-Z]');

alter table orte add constraint plz_chk1 check (plz like '%[0-9]%' );
alter table orte add constraint ort_name_chk1 check (substring(ortsname,1,1) like '%[A-Z]');

alter table mitarbeiter add constraint mit_name_chk1 check (substring(m_name,1,1) like '%[A-Z]');
