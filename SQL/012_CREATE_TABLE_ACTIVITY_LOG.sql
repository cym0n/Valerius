CREATE TABLE ACTIVITY_LOG
(ID INTEGER PRIMARY KEY AUTO_INCREMENT,
 USER VARCHAR(100),
 ACTION VARCHAR(100),
 ENTITY_TYPE VARCHAR(100),
 ENTITY_ID INTEGER,
 TIMESTAMP TIMESTAMP
);
