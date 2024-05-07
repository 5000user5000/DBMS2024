/***** use database *****/
USE DB_class;

/***** info *****/
CREATE TABLE self (
    StuID varchar(10) NOT NULL,
    Department varchar(10) NOT NULL,
    SchoolYear int DEFAULT 1,
    Name varchar(10) NOT NULL,
    PRIMARY KEY (StuID)
);

INSERT INTO self
VALUES ('b09502132', '機械系', 4, '周哲瑋');

SELECT DATABASE();
SELECT * FROM self;

/* Prepared statement */
PREPARE dept_students FROM 'SELECT * FROM student WHERE department = ?';

-- 設定系所參數
SET @my_dept = '機械系';
EXECUTE dept_students USING @my_dept;

-- 改變參數值為另一個系所
SET @other_dept = '資工所';
EXECUTE dept_students USING @other_dept;

-- 清除預備語句
DEALLOCATE PREPARE dept_students;


/* Stored-function */
-- 創建提取中文名的儲存函數
DELIMITER //
CREATE FUNCTION GetChineseName(fullname VARCHAR(255)) RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    RETURN SUBSTRING_INDEX(fullname, ' (', 1);
END//
DELIMITER ;

-- 創建提取英文名的儲存函數
DELIMITER //
CREATE FUNCTION GetEnglishName(fullname VARCHAR(255)) RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    RETURN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(fullname, '(', -1), ')', 1));
END//
DELIMITER ;

-- 使用儲存函數列出組員姓名
SELECT name, GetChineseName(name) AS ChineseName, GetEnglishName(name) AS EnglishName FROM student WHERE `group` = 7;


/* Stored procedure */
-- 創建存儲過程以計算特定系所的學生數量
DELIMITER //
CREATE PROCEDURE CountStudentsInDepartment(IN dept_name VARCHAR(255))
BEGIN
    SELECT COUNT(*) INTO @STCOUNT FROM student WHERE department = dept_name;
END//
DELIMITER ;

-- 呼叫存儲過程
CALL CountStudentsInDepartment('機械系');
SELECT @STCOUNT;
CALL CountStudentsInDepartment('資工所');
SELECT @STCOUNT;

/* View  */
-- 創建視圖，將姓名拆分為中文名和英文名
CREATE VIEW new_student AS
SELECT id, GetChineseName(name) AS ChineseName, GetEnglishName(name) AS EnglishName, department FROM student;

-- 查詢視圖
SELECT * FROM new_student WHERE department = '機械系';


/* Trigger */
-- 創建記錄表和觸發器
CREATE TABLE record_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    action_type VARCHAR(10),
    student_id VARCHAR(100),
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_user VARCHAR(100)
);

-- 設定變數
SET @NUMINS = 0;
SET @NUMDEL = 0;


-- 創建觸發器
DELIMITER //
CREATE TRIGGER after_student_insert AFTER INSERT ON student
FOR EACH ROW
BEGIN
    INSERT INTO record_table (action_type, student_id, action_user) VALUES ('INSERT', NEW.student_id, USER());
    SET @NUMINS = @NUMINS + 1;
END;

CREATE TRIGGER after_student_delete AFTER DELETE ON student
FOR EACH ROW
BEGIN
    INSERT INTO record_table (action_type, student_id, action_user) VALUES ('DELETE', OLD.student_id, USER());
    SET @NUMDEL = @NUMDEL + 1;
END; //

DELIMITER ;


-- 測試觸發器
-- 插入三個學生
INSERT INTO student (name, department, degree, student_id, email, class, identity) VALUES ('學生A', '機械系', 3, '1001', 'studenta@school.com', '3A', 'Student');
INSERT INTO student (name, department, degree, student_id, email, class, identity) VALUES ('學生B', '物理系', 2, '1002', 'studentb@school.com', '2C', 'Student');
INSERT INTO student (name, department, degree, student_id, email, class, identity) VALUES ('學生C', '化學系', 1, '1003', 'studentc@school.com', '1B', 'Student');

-- 刪除兩個學生
DELETE FROM student WHERE student_id = '1001';
DELETE FROM student WHERE student_id = '1003';

-- 查询record_table的内容和變量
SELECT * FROM record_table;
SELECT @NUMINS AS Total_Inserts, @NUMDEL AS Total_Deletes;

/* drop database */
DROP DATABASE DB_class;