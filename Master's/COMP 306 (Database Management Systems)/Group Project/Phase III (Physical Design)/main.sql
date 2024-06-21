-----creates:

create table City(
latitude int(3.2) not null,
longitude int(3.2) not null,
city_name varchar(10) not null,
country_name varchar(10) not null unique,
city_population int(8),

primary key (latitude, longitude)
);

create table Unesco_office(
off_id integer not null primary key autoincrement,
latitude int(3.2) not null,
longitude int(3.2) not null,
postcode int(6) not null, 
street varchar(10) not null,
street_no int(4) not null,
off_name varchar(15) not null unique,
no_people int(2),

constraint fk_city foreign key (latitude, longitude) references City(latitude, longitude)
);

create table Volunteer(
  vol_id integer not null primary key autoincrement,
  vol_name varchar(20) not null,
  vol_DoB datetime not null,
  vol_type varchar(1) not null check(vol_type='P' or vol_type='V' or vol_type='B')
);

create table Office(
  vol_id int(5) not null,
  off_id int(5) not null,

  constraint fk_volunteer foreign key (vol_id) references Volunteer(vol_id),
  constraint fk_unoffice foreign key (off_id) references Unesco_office(off_id)
  );

create table President(
  vol_id int(5) not null primary key,
  duty_start datetime not null unique,
  duty_end datetime not null unique,

  constraint fk_volunteer foreign key(vol_id) references Volunteer(vol_id)
);

create table Vice_president(
  vol_id int(5) not null primary key,
  duty_start datetime not null unique,
  duty_end datetime not null unique,

  constraint fk_volunteer foreign key(vol_id) references Volunteer(vol_id)
);

create table Languages(
  lan_id integer not null primary key autoincrement,
  lan_name varchar(20) not null unique,
  lan_gen_transmission int(1) not null check(lan_gen_transmission>=0 and lan_gen_transmission<=5),
  speaker_no int(9) not null,
  speaker_prop int(1) not null check(speaker_prop>=0 and speaker_prop<=5),
  educ_literacy int(1) not null check(educ_literacy>=0 and educ_literacy<=5),
  gov_policy int(1) not null check(gov_policy>=0 and gov_policy<=5),
  lan_year int(5) not null
);

create table Research(
  res_id integer not null primary key autoincrement,
  eth_consent varchar(1) not null check(eth_consent='Y' or eth_consent='N'),
  res_place varchar(20),
  res_desc varchar(250),
  res_importance int(1.2) default(null)
  );
  
create table Government(
  gov_id integer not null primary key autoincrement,
  country_name varchar(20) not null unique,
  un_recognition varchar(1) not null check(un_recognition='Y' or un_recognition='N'),
  unesco_relation varchar(50)
);

create table Consent(
  consent_id integer not null primary key autoincrement,
  gov_id int(5) not null,
  res_id int(5) not null,
  consent varchar(1) not null check(consent='Y' or consent='N'),
  consent_start datetime,
  consent_end datetime,
  con_duration int(4) default(null),

  constraint fk_gov foreign key(gov_id) references Government(gov_id),
  constraint fk_res foreign key(res_id) references Research(res_id)
);

create table Events(
  event_id integer not null primary key autoincrement,
  event_name varchar(25) not null,
  event_desc varchar(250),
  event_start datetime not null,
  event_end datetime not null,
  event_duration int(4) default(null)
);

create table Calendar(
  calendar_id integer not null primary key autoincrement,
  res_id int(5) not null unique,
  lan_id int(5) not null,
  res_start datetime not null,
  res_end datetime not null,
  res_duration int(4) default(null),

  constraint fk_res foreign key (res_id) references Research(res_id),
  constraint fk_lan foreign key (lan_id) references Languages(lan_id)
);

create table Cultural_heritage(
  cult_id integer not null primary key autoincrement,
  lan_id int(5) not null,
  cult_type varchar(1) not null check (cult_type in ('P', 'S', 'X', 'L')),

  constraint fk_lan foreign key (lan_id) references Languages(lan_id)
);

create table Proverb(
  cult_id int(10) not null primary key,
  p_year int(5) not null, 
  p_desc varchar(250),
  proverb varchar(250) not null,
  
  constraint fk_cult foreign key (cult_id) references Cultural_heritage(cult_id)
);

create table Song(
  cult_id int(10) not null primary key,
  s_year int(5) not null,
  singer varchar(20),
  s_desc varchar(250),
  song_lyrics varchar(250) not null,
  
  constraint fk_cult foreign key (cult_id) references Cultural_heritage(cult_id)
);

create table Knownpeople(
  cult_id int(10) not null primary key,
  kp_name varchar(20) not null,
  kp_job varchar(20) not null,
  kp_desc varchar(250),
  
  constraint fk_cult foreign key (cult_id) references Cultural_heritage(cult_id)
);
create table Literature(
  cult_id int(10) not null primary key,
  l_name varchar(20) not null,
  l_writer varchar(20),
  l_desc varchar(250),

  constraint fk_cult foreign key (cult_id) references Cultural_heritage(cult_id)
);

create table Participation(
  vol_id int(5) not null,
  event_id int(5) not null,
  
  primary key(vol_id, event_id),
  constraint fk_volunteer foreign key(vol_id) references Volunteer(vol_id),
  constraint fk_event foreign key(event_id) references Events(event_id)
);

create table Volres(
  vol_id int(5) not null,
  res_id int(5) not null,
  
  primary key(vol_id, res_id),
  constraint fk_volunteer foreign key(vol_id) references Volunteer(vol_id),
  constraint fk_research foreign key(res_id) references Research(res_id)
);

create table Citizenship(
  country_id integer not null primary key autoincrement,
  country_name varchar(20) not null
);

create table Vol_citizenship(
  vol_id int(5) not null,
  country_id int(3) not null,
  
  primary key(vol_id, country_id),
  constraint fk_volunteer foreign key(vol_id) references Volunteer(vol_id),
  constraint fk_citizenship foreign key(country_id) references Citizenship(country_id)
);

-----triggers:

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

-----inserts:

insert into Volunteer
(vol_name, vol_DoB, vol_type)
values 
('Rachel Green', '1997-11-23', 'B'),
('Joey Tribbiani','1998-05-11','V'),
('Ned Stark','1978-03-25','P'),
('Joffrey Baratheon','2001-09-01','B'),
('Micheal Scott','1981-08-13','B');

insert into events
(event_name,event_desc,event_start,event_end)
values
('UNESCO World Conference on Education for Sustainable Development','o kick off the new world programme for ESD ‘ESD for 2030’, UNESCO is organising an international conference in Berlin, Germany.
The meeting will raise global awareness on sustainable development challenges and the crucial role of ESD as a key enabler for the successful achievement of all SDGs and provide impulses for strengthening ESD in education policy and practice','2020-06-02 09:00','2020-06-04 14:00'),
('Responding to the global COVID -19 crisis: the training on illicit trafficking of cultural property in Africa going online','The UNESCO Dakar Office, in partnership with the WCO et INTERPOL, is organizing an online training workshop from June 2020 to build the capacities of museum/heritage professionals as well as law enforcement and security forces including customs and police in six countries: Burkina Faso, Mali, Mauritania, Morocco, Niger and Senegal.','2020-06-01 08:00', '2020-07-15 20:00'),
('Webinar - Art-Lab for Human Rights and Dialogue Special Edition','UNESCO and the Office of the High Commissioner for Human Rights (OHCHR) organize an “Art-Lab for Human Rights and Dialogue” special edition webinar in response to COVID-19 and beyond…. It will be held on 22 May 2020 (4 p.m. -5 p.m., UTC+2), on the occasion of the World Day for Cultural Diversity for Dialogue and Development.','2020-05-22 16:00','2020-05-22 17:00'),
('1st Conference of Ministers and High Authorities of Sports in Iberoamerica','UNESCO, jointly with the Ibero-American Council of Sports – CID and the General Secretary of Ibero-America – SEGIB, are organizing the 1st Conference of Ministers and High Authorities of Sport in Iberoamerica to discuss the impact of COVID-19 on sports, physical activity and physical education in the region.','2020-05-22 11:00','2020-05-22 12:00'),
('Webinar : Opportunities, Challenges, and Best practices in the development of distance Education resources for museums in Eastern Africa','The webinar will provide an opportunity to learn about the current context of distance learning educational programmes and resources at museums in the Eastern Africa region, the availability of national, regional and global resources for distance learning at museums, and the formulation of informed recommendations for the elaboration of a regional project proposal to support the development of distance learning educational programmes and resources for museums in the Eastern Africa region.','2020-05-14 16:00', '2020-05-14 17:30');

insert into City
(latitude,longitude,city_name,country_name,city_population)
values
('31.768','35.213','Kudd?s','Palestine','1253000'),
('41.008','28.978','Istanbul','Turkey','18753000'),
('40.712','-74.005','New York','USA','19.006.798'),
('48.856','2.352','Paris','France',' 2.200.000'),
('38.567','68.771','Dushanbe','Tajikistan','997254');

insert into Unesco_office
(latitude,longitude,postcode,street,street_no,off_name,no_people)
values
('31.768','35.213','9088500','Harimon str','2','EK1','145'),
('41.008','28.978','34550','S?leymaniye str.','1','Fatih','120'),
('40.712','-74.005','10007','West Broadway str.','6','Captain','52'),
('48.856','2.352','75001','Rue De Harley str.','3','Libert?','81'),
('38.567','68.771','734064','Ayni str.','3','Istiqlol','79');

insert into Languages
(lan_name,lan_gen_transmission,speaker_no,speaker_prop,educ_literacy,gov_policy,lan_year)
values
('Dothraki','2','54000','4','1','1','-542'),
('High Valyrian','4','2545','2','4','3','-1042'),
('Quenya','3','370','3','3','2','-4800'),
('Rohirric','1','99980','5','3','2','692'),
('Low Valyrian','5','897','1','2','2','1071');

insert into Cultural_heritage
(lan_id,cult_type)
values
('1','P'),('2','P'),('3','P'),('4','P'),('5','P'),
('1','S'),('2','S'),('3','S'),('4','S'),('5','S'),
('1','X'),('2','X'),('3','X'),('4','X'),('5','X'),
('1','L'),('2','L'),('3','L'),('4','L'),('5','L');

insert into Proverb
(cult_id,p_year,p_desc,proverb)
values
('1','234','When someone has done something bad to you, trying to get revenge will only make things worse','Two wrongs does not make a right'),
('2','-379','You can get better service if you complain about something. If you wait patiently, no one s going to help you','The squeaky wheel gets the grease'),
('3','-1679','You cant live completely independently. Everyone needs help from other people','No man is an island.'),
('4','800','Do not criticize other people if you are not perfect yourself','People who live in glass houses should not throw stones'),
('5','1900','It is best to do something on time. But if you ca not do it on time, do it late.','Better late than never');

insert into Song
(cult_id,s_year,singer,s_desc,song_lyrics)
values
('6','1971','Led Zeppelin','Stairway to heaven','Theres a lady whos sure
All that glitters is gold
And shes buying a stairway to Heaven
When she gets there she knows
If the stores are all closed
With a word she can get what she came for 
Oh oh oh oh and shes buying a stairway to Heaven'),
('7','-387','Traditionally attributed to Saint Ambrose and Saint Augustine','Te Deum','We praise thee, O God: we acknowledge Thee to be the Lord.
All the earth doth worship Thee, the Father everlasting.
To Thee all Angels cry aloud: the Heavens and all the powers therein.
To Thee Cherubim and Seraphim continually do cry, Holy, Holy, Holy: Lord God of Sabaoth;
Heaven and earth are full of the Majesty of Thy Glory.
The glorious company of the Apostles praise Thee.
The godly fellowship of the Prophets praise Thee.'),
('8','1300',null,'Sumer is icumen in','Summer has come in,
Loudly sing, cuckoo!
The seed grows and the meadow blooms
And the wood springs anew,
Sing, cuckoo!'),
('9','400',null,'Let All Mortal Flesh Keep Silence','Let all mortal flesh keep silence,
And with fear and trembling stand;
Ponder nothing earthly-minded,
For with blessing in his hand,
Christ our God to earth descendeth,
Our full homage to demand.'),
('10','380',null,'Phos Hilaron','Hail Gladdening Light
Of His pure glory poured
Who is the Immortal Father, Heavenly Blest
Holiest of Holies, Jesus Christ our Lord');

insert into Knownpeople
(cult_id,kp_name,kp_job,kp_desc)
values
('11','Achilles','Swordsman','Best Swordsman in Grecce important role in conquest of Troy'),
('12','Jim Halpert','Salesman','Best salesman in Dunder Mifflin'),
('13','Sheldon Cooper','Physicist','Having grown up in Houston, and its northern suburb of Spring, he made his first stage appearance in a school play at the age of 6. Parsons then went on to study theater at the University of Houston. From there he won a place on a two-year Masters course in classical theater at the University of San Diego/The Old Globe Theater, graduating in 2001.'),
('14','Gregory House','Doctor','An antisocial maverick doctor who specializes in diagnostic medicine does whatever it takes to solve puzzling cases that come his way using his crack team of doctors and his wits.'),
('15','Chandler M. Bing','statistical analysis and data reconfiguration',null);

insert into Literature
(cult_id,l_name,l_writer,l_desc)
values
('16','A Song Of Ice and Fire','George RR Martin','the Seven Kingdoms of Westeros were united under the Targaryen dynasty by Aegon I and his sister-wives Visenya and Rhaenys, establishing military supremacy through their control of dragons. The Targaryen dynasty ruled for three hundred years, although civil war and infighting among the Targaryens was frequent. Due to being held and bred in captivity, their dragons became ever smaller until they finally went extinct. At the beginning of A Game of Thrones, 15 peaceful years have passed since the rebellion led by Lord Robert Baratheon that deposed and killed the last Targaryen king, Aerys II "the Mad King", and proclaimed Robert king of the Seven Kingdoms, with a nine-year-long summer coming to an end.'),
('17','Lord of the Rings','JRR Tolkein','The narrative follows on from The Hobbit, in which the hobbit Bilbo Baggins finds the Ring, which had been in the possession of the creature Gollum. The story begins in the Shire, where Frodo Baggins inherits the Ring from Bilbo, his cousin[c] and guardian. Neither hobbit is aware of the Rings nature, but Gandalf the Grey, a wizard and an old friend of Bilbo, suspects it to be the Ring lost by Sauron, the Dark Lord, long ago. Seventeen years later, after Gandalf confirms this is true, he tells Frodo the history of the Ring and counsels him to take it away from the Shire.'),
('18','Harry Potter','JK Rowling','The central character in the series is Harry Potter, a boy who lives in the fictional town of Little Whinging, Surrey with his aunt, uncle, and cousin – the Dursleys – and discovers at the age of eleven that he is a wizard, though he lives in the ordinary world of non-magical people known as Muggles. The wizarding world exists parallel to the Muggle world, albeit hidden and in secrecy. His magical ability is inborn, and children with such abilities are invited to attend exclusive magic schools that teach the necessary skills to succeed in the wizarding world.'),
('19','Wild Cards','Georger RR Martin,Michael Cassutt, Stephen Leigh, John J. Miller, Walton Simons, and Snodgrass','Set during an alternate history of post-World War II United States, the series follows events after an airborne alien virus is released over New York City in 1946 and eventually infects tens of thousands globally. The virus, designed to rewrite DNA, was developed as a bioweapon by a noble family on the planet Takis, and it is taken to Earth to test on humans, who are genetically identical to the people of Takis. Dr. Tachyon, a member of this family, objects and attempts to stop them. However, his attempt crashes their ship, releasing the virus.'),
('20','Sherlock Holmes','Sir Arthur Conan Doyle','Holmess clients vary from the most powerful monarchs and governments of Europe, to wealthy aristocrats and industrialists, to impoverished pawnbrokers and governesses. He is known only in select professional circles at the beginning of the first story, but is already collaborating with Scotland Yard. However, his continued work and the publication of Watsons stories raises Holmess profile, and he rapidly becomes well known as a detective; so many clients ask for his help instead of (or in addition to) that of the police that, Watson writes, by 1895 Holmes has "an immense practice".');

insert into Government
(country_name,un_recognition,unesco_relation)
values
('Azerbaijan','Y','In connection with the 25th anniversary of Azerbaijan - UNESCO relations, the Presidential Library prepared the E-project entitled "Azerbaijan - UNESCO Relations".'),
('USA','N',null),
('Turkey','Y',null),
('Italy','Y','Organized by UNESCO in collaboration with the Government of the Italian Republic, with the support of the Emilia Romagna Region and the Municipality of Parma, the World Forum will analyze the linkages between food, culture and society, and their pivotal role for the implementation of the 2030 Agenda for Sustainable Development.'),
('Israel','N',null);

insert into Research
(eth_consent,res_place,res_desc)
values
('Y','Georgia',null),
('N','France',null),
('Y','Germany','They provide an understanding of our history and connect people across borders. Artists often build on the diversity of heritage when developing cultural expressions'),
('Y','Poland','With a view to promoting human resource capacities in the developing countries and to enhancing international understanding and friendship among nations and the people of Poland, the Polish National Commission for UNESCO and the UNESCO Chair for Science, Technology and Engineering Education at the AGH University of Science and Technology in Krakow have placed at the disposal of certain Member States'),
('N','China',null);

insert into President
(vol_id,duty_start,duty_end)
values
('3','2020-03-15','2021-04-14'),
('4','2019-02-09','2020-03-14');

insert into Vice_president
(vol_id,duty_start,duty_end)
values
('2','2018-06-11','2023-10-30'),
('5','2015-03-08','2018-06-10');

insert into Participation
(vol_id,event_id)
values
('2','2'),('2','1'),('3','2'),('3','1'),('4','5'),('5','3'),('4','1');

insert into Volres
(vol_id,res_id)
values
('1','3'),('1','2'),('2','3'),('2','4'),('3','1'),('5','4'),('4','2');

insert into Citizenship
(country_name)
values
('Turkey'),('Tajikistan'),('Germany'),('France'),('Spain'),('Portugal'),('Egytp'),('Brazil'),('England'),('Georgia'),('Iran'),('India'),('China'),('USA'),('Russia'),('Ukraine'),('Albenia');

insert into Vol_citizenship
(vol_id,country_id)
values
('1','3'),('2','3'),('2','4'),('3','10'),('3','15'),('4','17'),('5','2');

insert into Office
('vol_id','off_id')
values
('2','2'),('3','2'),('3','3'),('4','5'),('4','5'),('5','1'),('1','2');

insert into Calendar
(res_id,lan_id,res_start,res_end)
values
('1','1','2012-04-18','2013-07-11'),
('2','3','1999-05-15','2000-12-10'),
('3','4','1987-06-12','1989-11-13'),
('4','2','1965-07-09','1970-10-16'),
('5','5','1995-09-06','2021-09-21');

insert into Consent
(gov_id,res_id,consent,consent_start,consent_end)
values
('3','1','Y','2012-04-18','2013-07-11'),
('3','2','Y','1999-05-15','2000-12-10'),
('3','3','Y','1987-06-12','1989-11-13'),
('3','4','N',null,null),
('5','4','N','1965-07-09','1970-10-16'),
('3','5','Y','1995-09-06','2021-09-21'),
('2','5','N',null,null);

-----updates:

update Citizenship set Country_name='Belarus' where country_id='7';
update Volunteer set Vol_DoB='2002-09-01' where vol_name='Joffrey Baratheon';
update President set Vol_id='5' where duty_end='2020-03-14';
update Research set eth_consent='N' where res_place='Georgia';
update Languages set speaker_no='78900' where lan_name='Rohirric';

-----deletes:

delete from Citizenship where country_name='India';
delete from vol_citizenship where vol_id='2' and country_id='4';
delete from Events where event_name like '%Iberoamerica%';
delete from Office where vol_id='1' OR off_id='2';
delete from Vice_president Where duty_end='2018-06-10';

-----views:

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

-----selects:

---which events joined Presidents and Vice presidents 
select e.event_name,v.vol_name,v.vol_type from Events e
inner join Participation p on p.event_id=e.event_id
inner join Volunteer v on v.vol_id=p.vol_id
where v.vol_type='V' or v.vol_type='P';

---Citizenships of the Volunteer named Joey
select v.vol_name,c.country_name from Volunteer v
inner join vol_citizenship vc on vc.vol_id=v.vol_id
inner join Citizenship c on c.country_id=vc.country_id
where v.vol_name like 'Joey%';

---How many Volunteers attended which events
select e.event_name,count(p.vol_id) from Participation p 
inner join events e on e.event_id=p.event_id;

---How many Volunteers attended which researches
select r.res_id,count(vr.vol_id) from Volres vr 
inner join research r on r.res_id=vr.res_id;

---Volunteers who attended an event about education
select v.vol_name from Volunteer v
inner join Participation p on p.vol_id=v.vol_id
inner join Events e on e.event_id=p.event_id
where event_name like '%education%';

---which countries didnt give consent for which languages' research
select l.lan_name,g.country_name from Languages l
inner join calendar c on c.lan_id=l.lan_id
inner join consent con on con.res_id=c.res_id
inner join Government g on g.gov_id=con.gov_id
where consent='N';

---Number of languages with less than 3000 speakers and average of speakers of those languages
select count(*),avg(speaker_no) from languages
where speaker_no <3000;

----Population of Dushanbe
select city_population from City
where city_name = 'Dushanbe';

---Number of registered volunteers (on DB) in each Unesco office
select u.off_name, count(o.vol_id) from Unesco_office u, Office o
where u.off_id = o.off_id
group by u.off_name
order by 1;

---Volunteer that speaks Dothraki (selecting from view)
select vol_name from Volunteer_Language
where lan_name = 'Dothraki'
order by 1;

---The End.