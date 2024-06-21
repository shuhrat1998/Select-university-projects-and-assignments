
create trigger if not exists check1
before insert on Languages
begin
  select
    case
      when new.speaker_no > 500000000 then
      raise(abort, 'It is not an endangered language anymore!')
    end; 
end;

create trigger if not exists check2
before update of speaker_no on Languages
begin
  select
    case
      when new.speaker_no > 500000000 then
      raise(abort, 'It is not an endangered language anymore!')
    end; 
end;

create trigger if not exists con_duration1
after insert on Consent
begin
  update Consent
  set con_duration = julianday(consent_end) - julianday(consent_start)
  where rowid = new.rowid;
end;

create trigger if not exists con_duration2
after update of consent_start, consent_end on Consent
begin
  update Consent
  set con_duration = julianday(consent_end) - julianday(consent_start)
  where rowid = new.rowid;
end;

create trigger if not exists event_duration1
after insert on Events
begin
  update Events
  set event_duration = julianday(event_end) - julianday(event_start)
  where rowid = new.rowid;
end;

create trigger if not exists event_duration2
after update of event_start, event_end on Events
begin
  update Events
  set event_duration = julianday(event_end) - julianday(event_start)
  where rowid = new.rowid;
end;

create trigger if not exists res_duration1
after insert on Calendar
begin
  update Calendar
  set res_duration = julianday(res_end) - julianday(res_start)
  where rowid = new.rowid;
end;

create trigger if not exists res_duration2
after update of res_start, res_end on Calendar
begin
  update Calendar
  set res_duration = julianday(res_end) - julianday(res_start)
  where rowid = new.rowid;
end;

create trigger if not exists res_importance
after insert on Calendar
begin
  update Research
  set res_importance = 
  ( select (L.lan_gen_transmission + L.speaker_prop + L.educ_literacy + L.gov_policy)/4 from Research R
  inner join Calendar C on R.res_id = C.res_id
  inner join Languages L on C.lan_id = L.lan_id )
  
  where rowid in ( select R.rowid from Research R
  inner join Calendar C on R.res_id = C.res_id
  inner join Languages L on C.lan_id = L.lan_id );
end;

create trigger if not exists country1
before delete on Citizenship
begin
  select
    case when (select country_name from Citizenship) = 'Tajikistan' then
    raise(abort, 'Cannot remove the country from the database!')
    end;
end;

create trigger if not exists country2
after delete on Citizenship
begin
  select
    case when old.country_name = 'Turkey' then
    raise(rollback, 'Cannot remove the country from the database!')
    end;
end;