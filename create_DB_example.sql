use master;
go

-- SQL Server Datenbanken

--create database firma;
go

--exec sp_helpdb firma;


-- Datenbank Standard erzeugen
-- Der Systemkatalog der Datenbank befindet sich auf e:\dbdaten
-- Anfangsgröße 5 MB, Endgröße 1 GB, schrittweise Erweiterung 2 %

-- Die Daten befinden sich in einer Datei auf g:\daten
-- Anfangsgröße 10 GB, Endgröße 20 GB, schrittweise Erweiterung 500 MB

-- Das Protokoll befindet sich auf f:\dbprotokoll
-- Anfangsgröße 2 GB, Endgröße 10 GB, schrittweise Erweiterung 20 %

create database standard
on primary 
		(name = standard_kat,
		 filename = 'e:\dbdaten\standard_kat.mdf',
		 size = 5 MB,
		 maxsize = 1 GB,
		 filegrowth = 2%),
filegroup passiv 
		(name = standard_daten1,
		 filename = 'h:\daten\standard_daten1.ndf',
		 size = 10 GB,
		 maxsize = 20 GB,
		 filegrowth = 500 MB)
log on 
		(name = standardlog,
		 filename = 'f:\dbprotokoll\standardlog.ldf',
		 size = 2 GB,
		 maxsize = 10 GB,
		 filegrowth = 20 %);

go

exec sp_helpdb standard;

-- Standard Dateigruppe festlegen

alter database standard modify filegroup passiv default;

use standard;
go
exec sp_helpfilegroup
