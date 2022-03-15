use standard;
go
declare @name varchar(50), @stadt varchar(50), @aname varchar(50), @status int,
			 @anummer varchar(3), @menge int, @datum datetime, @nr varchar(3);
set @nr = 'L02';

if not exists(select * from lieferant where lnr = @nr)
  begin
	raiserror('Den Lieferanten %s gibt es nicht.',10,1,@nr);
	return;
  end;
else if not exists(select * from lieferung where lnr = @nr)
  begin
	raiserror('Der Lieferant %s hat nicht geliefert.',10,1,@nr);
	return;
  end;

select @name = lname, @status = status, @stadt = lstadt
from lieferant where lnr = @nr;
print 'Lieferantennummer:' + space(3) + @nr;
print 'Lieferantenname: ' + space(4) + @name;
print 'Status: ' + space(13 ) + cast(@status as varchar(3));
print 'Wohnort: ' + space(12) + @stadt;
print '';
print 'Der Lieferant hat folgende Lieferungen:';
declare lief_cur cursor for
select a.anr, aname, lmenge, ldatum 
from lieferung a join artikel b on a.anr = b.anr
where  lnr = @nr;
open lief_cur;
fetch from lief_cur into @anummer, @aname, @menge, @datum;
print '';
print 'Artikelnummer' + space(2) + 'Artikelname' + space(9) +
         'Liefermenge'+ space(4) + 'Lieferdatum';
print replicate('-',len('Artikelnummer')) + space(2) + replicate('-',len('Artikelname')) + 
         space(9) + replicate('-',len('Liefermenge')) + space(4) + replicate('-',len('Lieferdatum'));
while @@fetch_status = 0
  begin
	 print @anummer + space(15 - len(@anummer)) +
	          rtrim(@aname) + space(20 - len(rtrim(@aname))) + 
	          cast(@menge as varchar(5)) + space(15 - len(cast(@menge as varchar(5)))) +
	          convert(char(10),@datum,104);
	  fetch from lief_cur into @anummer, @aname, @menge, @datum;
  end;
deallocate lief_cur;
go
