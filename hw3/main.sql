/****** create and use database ******/
CREATE DATABASE AniMangaDB;
USE AniMangaDB;


/****** info ******/
CREATE TABLE self (
    StuID varchar(10) NOT NULL,
    Department varchar(10) NOT NULL,
    SchoolYear int DEFAULT 1,
    Name varchar(10) NOT NULL,
    PRIMARY KEY (StuID)
)engine=InnoDB,charset=utf8;


/****** create table *****/
CREATE TABLE studio (
    StudioID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) CHECK (LENGTH(Name) > 0),
    Location_City VARCHAR(50) NOT NULL ,
    Location_State VARCHAR(50) NOT NULL,
    Location_Street VARCHAR(50) ,
    Location_Street_Number VARCHAR(10),
    Location_Apartment_number VARCHAR(10)
) ENGINE=InnoDB,CHARSET=utf8;



/* multi-valued attribute use table to repersent */
CREATE TABLE studio_works (
    StudioID INT NOT NULL,
    WorkTitle VARCHAR(50)  NOT NULL CHECK (LENGTH(WorkTitle) > 0),
    FOREIGN KEY (StudioID) REFERENCES studio(StudioID),
    PRIMARY KEY (StudioID, WorkTitle)
) ENGINE=InnoDB,CHARSET=utf8;


CREATE TABLE artist (
    ArtistID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Role ENUM('mangaka', 'animator', 'both') NOT NULL DEFAULT 'both',
    CHECK (Name <> '')
) ENGINE=InnoDB,CHARSET=utf8;



CREATE TABLE artist_works (
    ArtistID INT,
    WorkTitle VARCHAR(50) NOT NULL CHECK (LENGTH(WorkTitle) > 0),
    FOREIGN KEY (ArtistID) REFERENCES artist(ArtistID),
    PRIMARY KEY (ArtistID, WorkTitle)
) ENGINE=InnoDB,CHARSET=utf8;

/* recursive relationship */
/* mentor table */
CREATE TABLE mentor (
    MentorID INT NOT NULL,
    ArtistID INT NOT NULL,
    FOREIGN KEY (MentorID) REFERENCES artist(ArtistID),
    FOREIGN KEY (ArtistID) REFERENCES artist(ArtistID) ,
    PRIMARY KEY (MentorID, ArtistID),
    CHECK (MentorID <> ArtistID)
) ENGINE=InnoDB,CHARSET=utf8;


CREATE TABLE animator (
    ArtistID INT PRIMARY KEY,
    Level ENUM('Intern','Junior', 'Senior', 'Staff','Principal')   DEFAULT 'Junior',
    ExpYears INT NOT NULL,
    FOREIGN KEY (ArtistID) REFERENCES artist(ArtistID),
    CHECK (ExpYears >= 0)
) ENGINE=InnoDB,CHARSET=utf8;


CREATE TABLE mangaka (
	ArtistID INT PRIMARY KEY,
    PenName VARCHAR(255),
    DebutWork VARCHAR(255) NOT NULL,
    FOREIGN KEY (ArtistID) REFERENCES artist(ArtistID)
) ENGINE=InnoDB,CHARSET=utf8;


CREATE TABLE mangaka_awards (
    ArtistID INT,
    Award VARCHAR(255) NOT NULL,
    FOREIGN KEY (ArtistID) REFERENCES mangaka(ArtistID),
    PRIMARY KEY (ArtistID, Award)
) ENGINE=InnoDB,CHARSET=utf8;


CREATE TABLE manga (
    MangaID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(255) NOT NULL,
    PublicationDate DATE NOT NULL,
    Genres VARCHAR(255) DEFAULT 'Kodomo',
    AuthorID INT,
    FOREIGN KEY (AuthorID) REFERENCES mangaka(ArtistID) ON DELETE SET NULL
) ENGINE=InnoDB,CHARSET=utf8;

CREATE TABLE illustrate (
    MangaID INT NOT NULL ,
    ArtistID INT NOT NULL,
    FOREIGN KEY (MangaID) REFERENCES manga(MangaID),
    FOREIGN KEY (ArtistID) REFERENCES mangaka(ArtistID),
    PRIMARY KEY (MangaID, ArtistID)
) ENGINE=InnoDB,CHARSET=utf8;


CREATE TABLE anime (
    AnimeID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(255) UNIQUE NOT NULL,
    AirDate DATE,
    StudioID INT NOT NULL,
    AnimatorID INT NOT NULL,
	FOREIGN KEY (StudioID) REFERENCES studio(StudioID) ,
    FOREIGN KEY (AnimatorID) REFERENCES animator(ArtistID) 
) ENGINE=InnoDB,CHARSET=utf8;


CREATE TABLE produce (
	StudioID INT NOT NULL,
    AnimeID  INT NOT NULL,
    FOREIGN KEY (StudioID) REFERENCES studio(StudioID),
	FOREIGN KEY (AnimeID) REFERENCES anime(AnimeID),
    PRIMARY KEY (StudioID, AnimeID)
) ENGINE=InnoDB,CHARSET=utf8;

CREATE TABLE animate (
	AnimeID  INT NOT NULL,
    ArtistID INT NOT NULL,
    FOREIGN KEY (AnimeID) REFERENCES anime(AnimeID),
	FOREIGN KEY (ArtistID) REFERENCES animator(ArtistID),
    PRIMARY KEY (AnimeID, ArtistID)
) ENGINE=InnoDB,CHARSET=utf8;

CREATE TABLE anime_CV (
    AnimeID INT,
    CV_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (AnimeID) REFERENCES anime(AnimeID),
    PRIMARY KEY (AnimeID, CV_name)
) ENGINE=InnoDB,CHARSET=utf8;



/* episode table as a weak entity dependent on anime */
CREATE TABLE episode (
	AnimeID INT NOT NULL,
    EpisodeTitle VARCHAR(255) ,
    Synopsis TEXT,
    Duration INT DEFAULT 24,
    FOREIGN KEY (AnimeID) REFERENCES anime(AnimeID),
    PRIMARY KEY (AnimeID, EpisodeTitle)
) ENGINE=InnoDB,CHARSET=utf8;


CREATE TABLE content (
    ContentID INT PRIMARY KEY AUTO_INCREMENT,
    Status VARCHAR(255) NOT NULL,
    Rating  ENUM('1','2','3','4','5') NOT NULL  DEFAULT '3',
    Format VARCHAR(255),
    AnimeID INT ,
    MangaID INT ,
    FOREIGN KEY (AnimeID) REFERENCES anime(AnimeID),
    FOREIGN KEY (MangaID) REFERENCES manga(MangaID)
) ENGINE=InnoDB,CHARSET=utf8;

/* participation table to link studios and animator */
CREATE TABLE participation (
    StudioID INT NOT NULL,
    ArtistID INT NOT NULL,
    FOREIGN KEY (StudioID) REFERENCES studio(StudioID) ,
    FOREIGN KEY (ArtistID) REFERENCES artist(ArtistID),
    PRIMARY KEY (StudioID, ArtistID)
) ENGINE=InnoDB,CHARSET=utf8;


CREATE TABLE characterData (
    CharacterID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    ContentID INT NOT NULL,
    FOREIGN KEY (ContentID) REFERENCES content(ContentID)
) ENGINE=InnoDB,CHARSET=utf8;



CREATE TABLE character_role (
    CharacterID INT NOT NULL,
    role VARCHAR(255) NOT NULL,
    FOREIGN KEY (CharacterID) REFERENCES characterData(CharacterID),
    PRIMARY KEY (CharacterID, role)
) ENGINE=InnoDB, CHARSET=utf8;


/* hero table specializing from characterData */
CREATE TABLE hero (
    CharacterID INT PRIMARY KEY ,
    HeroAlias VARCHAR(255) NOT NULL,
    Ally TEXT,
    FOREIGN KEY (CharacterID) REFERENCES characterData(CharacterID)
) ENGINE=InnoDB , CHARSET=utf8;


CREATE TABLE hero_power (
    CharacterID INT NOT NULL,
    power VARCHAR(255) DEFAULT '超能力',
    FOREIGN KEY (CharacterID) REFERENCES hero(CharacterID),
    PRIMARY KEY (CharacterID, power)
) ENGINE=InnoDB , CHARSET=utf8;


/* villain table specializing from characterData */
CREATE TABLE villain (
    CharacterID INT PRIMARY KEY,
    Origin VARCHAR(255) DEFAULT '人界',
    VillainScheme TEXT NOT NULL,
    FOREIGN KEY (CharacterID) REFERENCES characterData(CharacterID) 
) ENGINE=InnoDB , CHARSET=utf8;


CREATE TABLE villain_motivation (
    CharacterID INT NOT NULL,
    motivation VARCHAR(255) DEFAULT '痛みを感じろ，痛みを考えろ，痛みを受け取れ，痛みを知れ',
    FOREIGN KEY (CharacterID) REFERENCES villain(CharacterID),
    PRIMARY KEY (CharacterID, motivation)
) ENGINE=InnoDB , CHARSET=utf8;


/***** INSERT section *****/
INSERT INTO self VALUES ('b000000', '機械系', 0, 'xxx');

INSERT INTO studio (Name, Location_City, Location_State, Location_Street, Location_Street_Number, Location_Apartment_number) VALUES
('Studio Ghibli', '東京', '東京都', '青山', '1-2-3', '101'),
('Toei Animation', '大阪', '大阪府', '梅田', '4-5-6', '202'),
('Kyoto Animation', '京都', '京都府', '四條', '7-8-9', '303'),
('Sunrise', '東京', '東京都', '新宿', '10-1', '404'),
('Bones', '東京', '東京都', '渋谷', '11-2', '505'),
('Madhouse', '東京', '東京都', '六本木', '12-3', '606'),
('MAPPA', '福岡', '福岡県', '博多', '2-4-1', '707'),
('A-1 Pictures', '名古屋', '愛知県', '栄', '3-5-2', '808'),
('Wit Studio', '札幌', '北海道', '大通', '4-6-3', '909');

INSERT INTO studio_works (StudioID, WorkTitle) VALUES 
(1, '神秘海域'),
(2, '未來日記'),
(3, '攻殼機動隊'),
(4, '紫羅蘭永恆花園'),
(5, '銀魂'),
(6, '進擊的巨人'),
(7, '自然之歌'),
(8, '歷史的回聲'),
(9, '未來的遺產'),
(1, '天空之城'),
(1, '幽靈公主'),
(1, '起風了'),
(3, '寒蟬鳴泣之時'),
(3, '龍與虎'),
(5, '交響詩篇'),
(5, '我的英雄學院'),
(9, '甲鐵城的卡巴內里'),
(9, '大神與七位伙伴');

INSERT INTO artist (Name, DateOfBirth, Role) VALUES 
('宮崎駿', '1941-01-05', 'animator'),
('尾田榮一郎', '1975-01-01', 'mangaka'),
('岡部倫史', '1980-12-12', 'both'),
('新海誠', '1973-02-09', 'animator'),
('荒木飛呂彥', '1960-06-07', 'mangaka'),
('大暮維人', '1973-07-03', 'both'),
('細田守', '1966-09-19', 'animator'),
('久保帯人', '1977-06-26', 'mangaka'),
('田中芳樹', '1952-02-10', 'both');

INSERT INTO artist_works (ArtistID, WorkTitle) VALUES 
(1, '龍貓'),
(2, '海賊王'),
(3, '命運石之門'),
(4, '你的名字'),
(5, 'JOJO的奇妙冒險'),
(6, '神之雫'),
(7, '時をかける少女'),
(8, 'BLEACH'),
(9, '銀河英雄傳說');

INSERT INTO mentor (MentorID, ArtistID) VALUES 
(1, 2),
(1, 3),
(7, 4),
(7, 5),
(8, 6);

INSERT INTO participation (StudioID, ArtistID) VALUES 
(1, 1),
(4, 4),
(5, 5),
(7, 7),
(8, 8),
(9, 9);

INSERT INTO animator (ArtistID, Level, ExpYears) VALUES 
(1,'Senior', 30),
(4 ,'Junior', 5),
(7,'Senior', 25);

INSERT INTO mangaka (ArtistID, PenName, DebutWork) VALUES 
(2, '尾田榮一郎', '海賊王'),
(3, '岡部倫史', '命運石之門'),
(5, '荒木飛呂彥', 'JOJO的奇妙冒險'),
(6, '大暮維人', '神之雫'),
(8, '久保帯人', 'BLEACH'),
(9, '田中芳樹', '銀河英雄傳說');

INSERT INTO mangaka_awards (ArtistID, Award) VALUES 
(2, '漫畫銷量冠軍'),
(3, '科幻文學大獎'),
(5, '奇幻文學大獎'),
(8, '年度最佳漫畫'),
(9, '文化勳章');

INSERT INTO anime (Title, AirDate, StudioID, AnimatorID) VALUES 
('龍貓', '1988-07-16', 1, 1),
('命運石之門', '2011-04-06', 7, 4),
('你的名字', '2016-08-26', 4, 7),
('天空之城', '1986-08-02', 1, 1),
('幽靈公主', '1997-07-12', 1, 1),
('起風了', '2013-07-20', 1, 1),
('寒蟬鳴泣之時', '2006-04-04', 3, 1),
('龍與虎', '2008-10-02', 3, 1),
('交響詩篇', '2005-04-17', 5, 4),
('我的英雄學院', '2016-04-03', 5, 4),
('甲鐵城的卡巴內里', '2013-01-11', 9, 4),
('大神與七位伙伴', '2010-07-06', 9, 7);

INSERT INTO produce (StudioID, AnimeID) VALUES 
(1,1),
(7,2),
(4,3);

INSERT INTO animate (AnimeID, ArtistID) VALUES 
(1, 1),
(2, 7),
(3, 4);


INSERT INTO manga (Title, PublicationDate, Genres, AuthorID) VALUES 
('海賊王', '1997-07-22', '冒險', 2),
('命運石之門', '2009-10-15', '科幻', 3),
('BLEACH', '2001-08-20', '冒險, 超自然', 8);

INSERT INTO illustrate (MangaID, ArtistID) VALUES 
(1, 2),
(2, 3),
(3, 8);

INSERT INTO anime_CV (AnimeID, CV_name) VALUES 
(1, '高山南'),
(2, '宮野真守'),
(3, '田中真弓');

INSERT INTO episode (AnimeID, EpisodeTitle, Synopsis, Duration) VALUES 
(1, '龍貓登場', '龍貓的第一次登場。', 90),
(2, '時間的扭曲', '通過微波爐發送消息的實驗。', 24),
(3, '開端', '故事的開始。', 25);

INSERT INTO content (Status, Rating, Format, AnimeID, MangaID) VALUES 
('Complete', 5, 'TV', 1, NULL),
('Complete', 5, 'TV', 2, NULL),
('Complete', 5, 'Movie', 3, NULL),
('Ongoing', 4, 'TV', NULL, 1),
('Complete', 5, 'Web', NULL, 2),
('Complete', 5, 'Web', NULL, 3);



INSERT INTO characterData (Name, ContentID) VALUES 
('龍貓', 1),
('岡部倫太郎', 2),
('宮水三葉', 3),
('路飛', 4),
('岡部倫太郎', 5),
('黑崎一護', 6);

INSERT INTO character_role (CharacterID, role) VALUES 
(1, '森林守護者'),
(2, '科學家'),
(3, '女主角'),
(4, '海賊王'),
(5, '瘋狂科學家'),
(6, '代理死神');

INSERT INTO hero (CharacterID, HeroAlias, Ally) VALUES 
(1, '森林之王', '小梅'),
(4, '橡膠人', '草帽一伙'),
(6, '你說甚麼', '護廷十三隊');

INSERT INTO hero_power (CharacterID, power) VALUES 
(1, '飛行'),
(1, '自然掌控'),
(4, '伸縮自如'),
(6, '主角光環'),
(6, '月牙天衝');

INSERT INTO villain (CharacterID, Origin, VillainScheme) VALUES 
(2, '未來', '改變世界'),
(4, '大海', '尋找One Piece'),
(6, '屍魂界', '你說甚麼???');

INSERT INTO villain_motivation (CharacterID, motivation) VALUES 
(2, '拯救朋友'),
(4, '成為海賊王'),
(6, '還要更快');


-- new insert
INSERT INTO studio_works (StudioID, WorkTitle) VALUES 
(9, '甲鐵城的卡巴內里'),
(9, '大神與七位伙伴');
INSERT INTO produce (StudioID, AnimeID) VALUES 
(1, 22),
(1, 23),
(1, 24),
(1, 25),
(1, 26),
(1, 27),
(1, 28),
(1, 29),
(1, 30);
INSERT INTO anime_CV (AnimeID, CV_name) VALUES 
(22, '井上真樹夫'), -- 天空之城
(23, '松田洋治'), -- 幽靈公主
(24, '西島秀俊'), -- 起風了
(25, '保志總一朗'), -- 寒蟬鳴泣之時
(26, '釘宮理惠'), -- 龍與虎
(27, '阪本真綾'), -- 交響詩篇
(28, '山下大輝'), -- 我的英雄學院
(29, '花澤香菜'), -- 甲鐵城的卡巴內里
(30, '福山潤'); -- 大神與七位伙伴
INSERT INTO content (Status, Rating, Format, AnimeID, MangaID) VALUES 
('Complete', 5, 'Movie', 22, NULL), -- 天空之城
('Complete', 2, 'Movie', 23, NULL), -- 幽靈公主
('Complete', 4, 'Movie', 24, NULL), -- 起風了
('Complete', 3, 'TV', 25, NULL), -- 寒蟬鳴泣之時
('Complete', 5, 'TV', 26, NULL), -- 龍與虎
('Complete', 4, 'TV', 27, NULL), -- 交響詩篇
('Ongoing', 2, 'TV', 28, NULL), -- 我的英雄學院
('Complete', 1, 'TV', 29, NULL), -- 甲鐵城的卡巴內里
('Complete', 2, 'TV', 30, NULL); -- 大神與七位伙伴


/***** Creating views *****/ 
CREATE VIEW StudioWorkView AS
SELECT s.StudioID, s.Name AS StudioName, s.Location_City, sw.WorkTitle
FROM studio s
JOIN studio_works sw ON s.StudioID = sw.StudioID
WHERE s.Location_City = '東京'
ORDER BY s.StudioID;

CREATE VIEW ArtistWorkView AS
SELECT a.ArtistID, a.Name AS ArtistName, a.DateOfBirth, a.Role, aw.WorkTitle
FROM artist a
JOIN artist_works aw ON a.ArtistID = aw.ArtistID
WHERE a.DateOfBirth >= '1970-01-01'
ORDER BY a.ArtistID;

/***** SELECT Section*****/

SELECT DATABASE();
SELECT * FROM self;

/*Basic Select*/
SELECT *
FROM anime
WHERE ( AirDate < '2000-01-01' AND StudioID NOT IN (SELECT StudioID FROM studio WHERE Location_City = '東京') ) OR AnimatorID = 1;

/*Basic Projection*/
SELECT Title, AirDate
FROM anime;

/*Basic Rename*/
SELECT Name AS StudioName, Location_City AS City, Location_State AS State
FROM studio;

/*Equijoin*/
SELECT a.Name AS ArtistName, aw.WorkTitle
FROM artist AS a
JOIN artist_works AS aw ON a.ArtistID = aw.ArtistID;

SELECT cd.Name AS CharacterName, v.VillainScheme
FROM hero AS h
JOIN villain AS v ON h.CharacterID = v.CharacterID
JOIN characterdata as cd ON v.CharacterID = cd.CharacterID ;

/*Natural Join*/
SELECT *
FROM manga
NATURAL JOIN illustrate;

/*Theta Join*/
SELECT *
FROM manga AS m
JOIN artist AS a ON m.AuthorID = a.ArtistID AND a.DateOfBirth > '1970-01-01';

/*Three-table Join*/
SELECT s.Name AS StudioName, a.Title AS AnimeTitle, ar.Name AS ArtistName
FROM studio AS s
JOIN produce AS p ON s.StudioID = p.StudioID
JOIN anime AS a ON p.AnimeID = a.AnimeID
JOIN animate AS an ON a.AnimeID = an.AnimeID
JOIN artist AS ar ON an.ArtistID = ar.ArtistID;

/*Aggregate*/
SELECT StudioID, COUNT(*) AS TotalAnimes
FROM anime
GROUP BY StudioID;

/*Aggregate with HAVING */
SELECT s.name AS studio , round(AVG(content.Rating),2) AS WorkAverageRating
FROM studio AS s
JOIN studio_works AS sw ON s.StudioID = sw.StudioID
JOIN anime ON anime.title = sw.WorkTitle
JOIN content ON content.AnimeID = anime.AnimeID
GROUP BY s.StudioID
HAVING COUNT(s.StudioID) > 1;

/*****  drop database *****/
DROP DATABASE AniMangaDB;
