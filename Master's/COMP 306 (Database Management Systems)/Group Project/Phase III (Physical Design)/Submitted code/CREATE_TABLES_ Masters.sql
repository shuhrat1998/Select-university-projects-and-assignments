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