# 创建数据表

CREATE TABLE IF NOT EXISTS `ops_user`(
   `user_id` INT UNSIGNED AUTO_INCREMENT,
   `user_name` VARCHAR(40) NOT NULL,
   `user_mobile` VARCHAR(100) NOT NULL,   
   PRIMARY KEY ( `user_id` )
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- ----------------------------
-- Table structure for itdevops
-- ----------------------------
DROP TABLE [dbo].[itdevops]
GO
CREATE TABLE [dbo].[itdevops] (
[id] int NULL ,
[name] nvarchar(50) NULL ,
[quantity] int NULL 
)

GO

CREATE TABLE IF NOT EXISTS `itdevops`(
   `id` int NULL ,
   `name` nvarchar(50) NULL ,
   `quantity` int NULL,
    PRIMARY KEY ( `id` )
)ENGINE=InnoDB DEFAULT CHARSET=utf8;