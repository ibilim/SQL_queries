use standard;
go

/*
Eine Variable wird mit eine´m Tabellennamen der Datenbank Standard belegt.
Über einen Cursor soll jeder Index der angegebenen Tabelle auf
seinen Fragmentierungsgrad überprüft werden.
Bei einem Wiert unter 10 % soll mit dem Index nichts passieren, bei 11 bis
30 % soll der Index reorganisiert werden und bei über 30 % neu
gebildet werden.
Der Anwender des Skripts soll über die entsprechenden Aktivitäten
informiert werden.
Für den Tasbellennamen soll ein qualifizierter Name, schema.tabelle,
verwendet werden.
*/

declare @tab sysname, @tabvoll sysname, @objekt varchar(100), @indid int,
@indname sysname;

set @tab = 'lieferant';
select  @tabvoll = b.name + '.' + a.name from sys.tables as a join 
	 sys.schemas as b on a.schema_id = b.schema_id and a.name = @tab;

declare indfrag cursor for
select object_id, index_id, name from sys.indexes 
where object_id = object_id(@tabvoll);

open indfrag;
fetch indfrag into @objekt, @indid, @indname;
while @@fetch_status = 0
begin
  if(select avg_fragmentation_in_percent
	 from sys.dm_db_index_physical_stats(db_id(),object_id(@tabvoll),
	      @indid,null,null)) <= 10
  begin
	raiserror('Index %s ist nicht fragmentiert.',10,1,@indname);
  end;
  if(select avg_fragmentation_in_percent
	 from sys.dm_db_index_physical_stats(db_id(),object_id(@tabvoll),
	      @indid,null,null)) between 11 and 30
  begin
	 execute('alter index ' + @indname + ' on ' + @tabvoll + ' reoganize;');
	 raiserror('Index %s ist leicht fragmentiert, er wurde reorganisiert.',10,1,@indname);
  end;
  if(select avg_fragmentation_in_percent
	 from sys.dm_db_index_physical_stats(db_id(),object_id(@tabvoll),
	      @indid,null,null)) > 30
  begin
	 execute('alter index ' + @indname + ' on ' + @tabvoll + ' rebuild;');
	 raiserror('Index %s ist start fragmentiert, er wurde neu gebildet.',10,1,@indname);
  end;
  fetch indfrag into @objekt, @indid, @indname;
end;
deallocate indfrag;
go
