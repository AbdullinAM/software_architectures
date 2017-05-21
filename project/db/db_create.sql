# drop all tables
DROP TABLE IF EXISTS BUGREPORT_COMMENTS;
DROP TABLE IF EXISTS TICKET_ASSIGNEES;
DROP TABLE IF EXISTS TICKET_COMMENTS;
DROP TABLE IF EXISTS DEVELOPERS;
DROP TABLE IF EXISTS TESTERS;
DROP TABLE IF EXISTS TEAMLEADERS;
DROP TABLE IF EXISTS COMMENTS;
DROP TABLE IF EXISTS BUGREPORT;
DROP TABLE IF EXISTS TICKET;
DROP TABLE IF EXISTS MILESTONE;
DROP TABLE IF EXISTS PROJECT;
DROP TABLE IF EXISTS MESSAGE;
DROP TABLE IF EXISTS USERS;

# create tables
CREATE TABLE USERS (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  login VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(100) NOT NULL,
  password CHAR(40)   # sha1 hash
);

CREATE TABLE MESSAGE (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user INT NOT NULL,
  message VARCHAR(1000) NOT NULL,
  FOREIGN KEY (user) REFERENCES USERS(id)
);

CREATE TABLE PROJECT (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  manager INT NOT NULL,
  FOREIGN KEY (manager) REFERENCES USERS(id)
);

CREATE TABLE BUGREPORT (
  id INT AUTO_INCREMENT PRIMARY KEY,
  project INT NOT NULL,
  creator INT NOT NULL,
  developer INT,
  status ENUM("OPENED", "ACCEPTED", "FIXED", "CLOSED") NOT NULL,
  creationTime DATETIME NOT NULL,
  description VARCHAR(1000) NOT NULL,
  FOREIGN KEY (project) REFERENCES PROJECT(id),
  FOREIGN KEY (creator) REFERENCES USERS(id),
  FOREIGN KEY (developer) REFERENCES USERS(id)
);

CREATE TABLE COMMENTS (
  id INT AUTO_INCREMENT PRIMARY KEY,
  time DATETIME NOT NULL,
  commenter INT NOT NULL,
  description VARCHAR(1000) NOT NULL,
  FOREIGN KEY (commenter) REFERENCES USERS(id)
);

CREATE TABLE MILESTONE (
  id INT AUTO_INCREMENT PRIMARY KEY,
  project INT NOT NULL,
  status ENUM("OPENED", "ACTIVE", "CLOSED") NOT NULL,
  startDate DATETIME NOT NULL,
  activeDate DATETIME,
  endDate DATETIME NOT NULL,
  closingDate DATETIME,
  FOREIGN KEY (project) REFERENCES PROJECT(id)
);

CREATE TABLE TICKET (
  id INT AUTO_INCREMENT PRIMARY KEY,
  milestone INT NOT NULL,
  creator INT NOT NULL,
  status ENUM("NEW", "ACCEPTED", "IN_PROGRESS", "FINISHED", "CLOSED") NOT NULL,
  creationTime DATETIME NOT NULL,
  task VARCHAR(1000),
  FOREIGN KEY (milestone) REFERENCES MILESTONE(id),
  FOREIGN KEY (creator) REFERENCES USERS(id)
);

# connection tables
CREATE TABLE BUGREPORT_COMMENTS (
  commentid INT PRIMARY KEY,
  bugreport INT NOT NULL,
  FOREIGN KEY (bugreport) REFERENCES BUGREPORT(id),
  FOREIGN KEY (commentid) REFERENCES COMMENTS(id)
);

CREATE TABLE TICKET_ASSIGNEES (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ticket INT NOT NULL,
  assignee INT NOT NULL,
  FOREIGN KEY (ticket) REFERENCES TICKET(id),
  FOREIGN KEY (assignee) REFERENCES USERS(id)
);

CREATE TABLE TICKET_COMMENTS (
  commentid INT PRIMARY KEY,
  ticket INT NOT NULL,
  FOREIGN KEY (ticket) REFERENCES TICKET(id),
  FOREIGN KEY (commentid) REFERENCES COMMENTS(id)
);

CREATE TABLE TEAMLEADERS (
  project INT PRIMARY KEY,
  teamleader INT NOT NULL,
  FOREIGN KEY (project) REFERENCES PROJECT(id),
  FOREIGN KEY (teamleader) REFERENCES USERS(id)
);

CREATE TABLE DEVELOPERS (
  project INT NOT NULL,
  developer INT NOT NULL,
  PRIMARY KEY (project, developer),
  FOREIGN KEY (project) REFERENCES PROJECT(id),
  FOREIGN KEY (developer) REFERENCES USERS(id)
);

CREATE TABLE TESTERS (
  project INT NOT NULL,
  tester INT NOT NULL,
  PRIMARY KEY (project, tester),
  FOREIGN KEY (project) REFERENCES PROJECT(id),
  FOREIGN KEY (tester) REFERENCES USERS(id)
);

# inserting some data
INSERT INTO USERS(USERS.name, USERS.login, USERS.email, USERS.password) VALUES ("Manager", "manager", "email", SHA1("pass"));
INSERT INTO USERS(USERS.name, USERS.login, USERS.email, USERS.password) VALUES ("Developer", "developer", "email", SHA1("pass"));
INSERT INTO USERS(USERS.name, USERS.login, USERS.email, USERS.password) VALUES ("TeamLeader", "teamleader", "email", SHA1("pass"));
INSERT INTO USERS(USERS.name, USERS.login, USERS.email, USERS.password) VALUES ("Tester", "tester", "email", SHA1("pass"));
INSERT INTO USERS(USERS.name, USERS.login, USERS.email, USERS.password) VALUES ("Developer", "wrongDev", "email", SHA1("pass"));

INSERT INTO PROJECT(PROJECT.name, PROJECT.manager) VALUES(
  "First project",
  (SELECT (USERS.id) FROM USERS WHERE USERS.login = "manager")
);

INSERT INTO TEAMLEADERS(TEAMLEADERS.teamleader, TEAMLEADERS.project) VALUES (
  (SELECT (USERS.id) FROM USERS WHERE USERS.login = "teamleader"),
  (SELECT (PROJECT.id) FROM PROJECT WHERE PROJECT.name = "First project")
);

INSERT INTO DEVELOPERS (DEVELOPERS.project, DEVELOPERS.developer) VALUES (
  (SELECT (PROJECT.id) FROM PROJECT WHERE PROJECT.name = "First project"),
  (SELECT (USERS.id) FROM USERS WHERE USERS.login = "developer")
);

INSERT INTO TESTERS(TESTERS.project, TESTERS.tester) VALUES (
  (SELECT (PROJECT.id) FROM PROJECT WHERE PROJECT.name = "First project"),
  (SELECT (USERS.id) FROM USERS WHERE USERS.login = "tester")
);

INSERT INTO MILESTONE(MILESTONE.project, MILESTONE.status, MILESTONE.startDate, MILESTONE.endDate) VALUES (
  (SELECT (PROJECT.id) FROM PROJECT WHERE PROJECT.name = "First project"),
  "OPENED",
  NOW(),
  20171218131717
);

INSERT INTO TICKET(TICKET.milestone, TICKET.creator, TICKET.status, TICKET.creationTime, TICKET.task) VALUES (
  1,
  (SELECT (USERS.id) FROM USERS WHERE USERS.login = "teamleader"),
  "NEW",
  NOW(),
  "Do this"
);

INSERT INTO BUGREPORT(BUGREPORT.project, BUGREPORT.creator, BUGREPORT.status, BUGREPORT.creationTime, BUGREPORT.description) VALUES (
  (SELECT (PROJECT.id) FROM PROJECT WHERE PROJECT.name = "First project"),
  (SELECT (USERS.id) FROM USERS WHERE USERS.login = "developer"),
  "OPENED",
  NOW(),
  "New bug"
);