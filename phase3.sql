-------------------- Queries
--1) گزارش اطلاعات ویدئوهای یک کانال به خصوص
SELECT channel_id ,video_id, type_of_video, video_discription, number_of_views
FROM Channel natural join Channel_Video_Bridge natural join Video
WHERE channel_id = '2058765130'

--2) گزارش کل کامنت هایی که یک شخص به خصوص نوشته به همراه آیدی ویدئوای که زیر آن کامنت گذاشته
SELECT content, date_written, video_id FROM comment natural join site_user
WHERE user_id = '5'
--3) دومین پلی لیست ساخته شده
SELECT * FROM (SELECT * FROM PlayList ORDER BY date_created OFFSET 1) as foo LIMIT 1

--4) دارند type of action گزارش یوزهایی که بیشتر از یک 
SELECT user_id FROM History_Of_user GROUP BY user_id HAVING count(type_of_action) > 1

--5) گزارش پلی لیست هایی که بین تاریخ های ذکر شده ساخته شده اند
SELECT video_id, video_discription, number_of_views
FROM video natural join PlayList_Bridge natural join PlayList
WHERE date_created between '1/1/2021' and '4/4/2021'

-------------------- Triggers
-- 1) uppercasing title
CREATE OR REPLACE FUNCTION uppercase_playlist_title()
RETURNS TRIGGER AS $$
BEGIN
	NEW.title = upper(NEW.title);
	RETURN NEW;
END$$ LANGUAGE plpgsql;

CREATE TRIGGER playlist_title_trigger
	BEFORE INSERT ON PlayList
	FOR EACH ROW
	EXECUTE PROCEDURE uppercase_playlist_title();

-- 2) making a channel when a new user signed up
CREATE OR REPLACE FUNCTION insert_new_channel()
RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO Channel(channel_id, number_of_subscribers, watch_time, total_views)
	VALUES (NEW.channel_owning_id, 0, 0, 0);
	RETURN NEW;
END;$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_new_channel_trigger
	BEFORE INSERT ON site_user
	FOR EACH ROW
	EXECUTE PROCEDURE insert_new_channel()

select * from site_user
select * from channel
-------------------- Materialized Views
-- 1)
CREATE MATERIALIZED VIEW Channel_Video AS
SELECT channel_id, video_id, type_of_video, video_discription, number_of_views, date_released
FROM Channel natural join Channel_Video_Bridge natural join Video

SELECT * FROM Channel_Video
-- 2)
CREATE MATERIALIZED VIEW PlayList_Video AS
SELECT playlist_id, title, date_created, video_id
FROM playList natural join playlist_bridge natural join video

SELECT * FROM PlayList_Video
-- 3)
CREATE MATERIALIZED VIEW Video_Comment AS
SELECT video_id, type_of_video, number_of_views, comment_id, author_id, content, date_written
FROM Video join Comment using (video_id)
ORDER BY date_written
fetch first 5 rows only

SELECT * FROM Video_Comment
-------------------- User Defined Function
--1) calculating total views
CREATE FUNCTION calc_channel_total_views(cid varchar(15)) RETURNS integer as $$ 
declare
	total_views bigint;
begin
	select sum(number_of_views) into total_views from video natural join Channel_Video_Bridge
	where cid = channel_id;
	return total_views;
end;
$$ LANGUAGE plpgsql
select calc_channel_total_views('2058765130');
select * from channel_video_bridge

--2) Showing total likes a user's comments got
CREATE FUNCTION calc_total_likes(ui varchar(15)) RETURNS integer as $$
declare
	total_likes bigint;
begin
	select sum(number_of_likes) into total_likes from comment
	where author_id = ui;
	return total_likes;
end;
$$ LANGUAGE plpgsql
select calc_total_likes('5');
select * from Comment
-------------------- Stored Procedure
--1) updating number of likes in Video Table
CREATE OR REPLACE PROCEDURE add_video_number_of_likes(vid varchar(15))
LANGUAGE plpgsql
as $$
BEGIN
	update video
	set number_of_likes = number_of_likes + 1
	where video_id = vid;
	commit;
END;$$
select * from video
call add_video_number_of_likes('1');
--2) inserting into channel_video_bridge
CREATE OR REPLACE PROCEDURE insert_channel_video_bridge(cid varchar(15), vid varchar(15))
LANGUAGE plpgsql as $$
BEGIN
	INSERT INTO Channel_Video_Bridge(channel_id, video_id) VALUES (cid, vid);
END;$$

call insert_channel_video_bridge('2058765130', '1')
select * from channel
select * from channel_video_bridge
--3) inserting into playlist_video_bridge
CREATE OR REPLACE PROCEDURE insert_playlist_video_bridge(pid varchar(15), vid varchar(15))
LANGUAGE plpgsql as $$
BEGIN
	INSERT INTO Playlist_Bridge(playlist_id, video_id) VALUES (pid, vid);
END;$$

call insert_playlist_video_bridge('555', '1')
select * from Playlist_Bridge