create view Volunteer_City as
select distinct v.vol_name,c.city_name from City c 
inner join Unesco_office u on
(u.latitude, u.longitude) = (c.latitude, c.longitude) 
inner join office o on o.off_id=u.off_id
inner join Volunteer v on v.vol_id=o.vol_id
order by v.vol_name;

create view Volunteer_Language as
select vol.vol_name,l.lan_name from Languages l
inner join Calendar c on l.lan_id=c.lan_id
inner join Volres v on v.res_id=c.res_id
inner join Volunteer vol on vol.vol_id=v.vol_id
order by vol.vol_name;

create view Government_Consent as
select r.res_id,g.country_name,c.consent_start,c.consent_end
from Consent c 
inner join research r on c.res_id=r.res_id
inner join Government g on g.gov_id=c.gov_id
order by c.consent_start;

create view Language_Proverb as
select l.lan_name, p.p_desc
from Cultural_heritage c 
inner join Languages l on l.lan_id=c.lan_id
inner join Proverb p on p.cult_id=c.cult_id
order by l.lan_name;

create view Language_Literature as
select l.lan_name,li.l_name,li.l_writer,li.l_desc
from Cultural_heritage c 
inner join Languages l on l.lan_id=c.lan_id
inner join Literature li on li.cult_id=c.cult_id
order by l.lan_name;

create view Language_Knownpeople as
select l.lan_name,k.kp_name,k.kp_desc
from Cultural_heritage c 
inner join Languages l on l.lan_id=c.lan_id
inner join Knownpeople k on k.cult_id=c.cult_id
order by l.lan_name;

create view Language_Song as
select l.lan_name, s.s_desc
from Cultural_heritage c 
inner join Languages l on l.lan_id=c.lan_id
inner join Song s on s.cult_id=c.cult_id
order by l.lan_name;