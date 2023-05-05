create table Channel(
	channel_id				varchar(15) not null,
	number_of_subscribers	int,
	watch_time				bigint,
	total_views				bigint,
	primary key (channel_id)
);

create table Site_User(
	user_id				varchar(15) not null,
	fullname 			varchar(25) not null,
	password			varchar(20) not null,
	email				varchar(100) not null,
	location			varchar(100),
	channel_owning_id	varchar(15),
	primary key (user_id),
	foreign key (channel_owning_id) references Channel (channel_id)
		on delete set null
);

create table Video(
	video_id 			varchar(15) not null,
	type_of_video		varchar(10)
		check(type_of_video in ('video', 'shortclip', 'stream', 'music')),
	video_discription	varchar(400),
	number_of_views		bigint,
	max_quality_support	varchar(9)
		check(max_quality_support in ('144p', '240p', '360p', '480p', '720p', '720p60fps', '1080p60fps', '2k', '2k60fps', '2k120fps' , '4k1202fps')),
	number_of_likes		int,
	date_released		date,
	primary key (video_id)
);

create table Comment(
	comment_id			varchar(15) not null,
	content				varchar(300) not null,
	date_written			date,
	number_of_likes		int,
	replied_comment_id	varchar(15),
	video_id			varchar(15),
	author_id			varchar(15),
	primary key (comment_id),
	foreign key (replied_comment_id) references Comment (comment_id)
		on delete set null,
	foreign key (video_id) references Video (video_id)
		on delete set null,
	foreign key (author_id) references Site_User (user_id)
		on delete set null
);

create table PlayList(
	playlist_id		varchar(15) not null,
	title			varchar(100) not null,
	date_created	date,
	primary key (playlist_id)
);

create table PlayList_Bridge(
	playlist_id	varchar(15),
	video_id	varchar(15),
	primary key (playlist_id, video_id),	
	foreign key (playlist_id) references PlayList (playlist_id)
		on delete set null,
	foreign key (video_id) references Video (video_id)
		on delete set null
);

create table Channel_Video_Bridge(
	channel_id	varchar(15),
	video_id	varchar(15),
	foreign key (channel_id) references Channel (channel_id)
		on delete set null,
	foreign key (video_id) references Video (video_id)
		on delete set null
);

create table History_of_User(
	timestamp_of_action			timestamp,
	type_of_action				int,
	discription_about_action	varchar(150),
	user_id						varchar(15),
	primary key(timestamp_of_action),
	foreign key (user_id) references Site_User (user_id)
		on delete set null
);