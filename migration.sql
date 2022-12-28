PRAGMA foreign_keys=off;

BEGIN TRANSACTION;

ALTER TABLE `tblDocumentContent` ADD COLUMN `revisiondate` TEXT default NULL;

ALTER TABLE `tblUsers` ADD COLUMN `secret` varchar(50) default NULL;

ALTER TABLE `tblWorkflows` ADD COLUMN `layoutdata` text default NULL;

CREATE TABLE `new_tblWorkflowDocumentContent` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `parent` INTEGER DEFAULT NULL REFERENCES `tblWorkflowDocumentContent` (`id`) ON DELETE CASCADE,
  `workflow` INTEGER DEFAULT NULL REFERENCES `tblWorkflows` (`id`) ON DELETE CASCADE,
  `document` INTEGER DEFAULT NULL REFERENCES `tblDocuments` (`id`) ON DELETE CASCADE,
  `version` INTEGER DEFAULT NULL,
  `state` INTEGER DEFAULT NULL REFERENCES `tblWorkflowStates` (`id`) ON DELETE CASCADE,
  `date` datetime NOT NULL
) ;

INSERT INTO `new_tblWorkflowDocumentContent` (`parent`, `workflow`, `document`, `version`,     `state`, `date`) SELECT NULL as `parent`, `workflow`, `document`, `version`, `state`, `date` FROM `tblWorkflowDocumentContent`;

INSERT INTO `new_tblWorkflowDocumentContent` (`parent`, `workflow`, `document`, `version`, `state`, `date`) SELECT NULL, `a`.`workflow`, `a`.`document`, `a`.`version`, NULL AS `state`, max(`a`.`date`) FROM `tblWorkflowLog` `a` LEFT JOIN `tblWorkflowDocumentContent` `b` ON `a`.`document`=`b`.`document` AND `a`.`version`=`b`.`version` AND `a`.`workflow`=`b`.`workflow` WHERE `b`.`document` IS NULL GROUP BY `a`.`document`, `a`.`version`, `a`.`workflow`;

CREATE TABLE `new_tblWorkflowLog` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
	`workflowdocumentcontent` INTEGER DEFAULT NULL REFERENCES `tblWorkflowDocumentContent` (`id`) ON DELETE CASCADE,
  `userid` INTEGER default NULL REFERENCES `tblUsers` (`id`) ON DELETE CASCADE,
  `transition` INTEGER default NULL REFERENCES `tblWorkflowTransitions` (`id`) ON DELETE CASCADE,
  `date` datetime NOT NULL,
  `comment` text
) ;

INSERT INTO `new_tblWorkflowLog` (`id`, `workflowdocumentcontent`, `userid`, `transition`, `date`, `comment`) SELECT `a`.`id`, `b`.`id`, `a`.`userid`, `a`.`transition`, `a`.`date`, `a`.`comment` FROM `tblWorkflowLog` `a` LEFT JOIN `new_tblWorkflowDocumentContent` `b` ON `a`.`document`=`b`.`document` AND `a`.`version`=`b`.`version` AND `a`.`workflow`=`b`.`workflow` WHERE `b`.`document` IS NOT NULL;

DROP TABLE `tblWorkflowLog`;

ALTER TABLE `new_tblWorkflowLog` RENAME TO `tblWorkflowLog`;

DROP TABLE `tblWorkflowDocumentContent`;

ALTER TABLE `new_tblWorkflowDocumentContent` RENAME TO `tblWorkflowDocumentContent`;

CREATE TABLE `tblUserSubstitutes` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `user` INTEGER NOT NULL default '0' REFERENCES `tblUsers` (`id`) ON DELETE CASCADE,
  `substitute` INTEGER NOT NULL default '0' REFERENCES `tblUsers` (`id`) ON DELETE CASCADE,
  UNIQUE (`user`, `substitute`)
);

CREATE TABLE `tblDocumentCheckOuts` (
  `document` INTEGER REFERENCES `tblDocuments` (`id`) ON DELETE CASCADE,
  `version` INTEGER unsigned NOT NULL default '0',
  `userID` INTEGER NOT NULL default '0' REFERENCES `tblUsers` (`id`),
  `date` TEXT NOT NULL,
  `filename` varchar(255) NOT NULL default '',
  UNIQUE (`document`)
) ;

CREATE TABLE `tblDocumentRecipients` (
  `receiptID` INTEGER PRIMARY KEY AUTOINCREMENT,
  `documentID` INTEGER NOT NULL default '0' REFERENCES `tblDocuments` (`id`) ON DELETE CASCADE,
  `version` INTEGER unsigned NOT NULL default '0',
  `type` INTEGER NOT NULL default '0',
  `required` INTEGER NOT NULL default '0',
  UNIQUE (`documentID`,`version`,`type`,`required`)
) ;
CREATE INDEX `indDocumentRecipientsRequired` ON `tblDocumentRecipients` (`required`);

CREATE TABLE `tblDocumentReceiptLog` (
  `receiptLogID` INTEGER PRIMARY KEY AUTOINCREMENT,
  `receiptID` INTEGER NOT NULL default 0 REFERENCES `tblDocumentRecipients` (`receiptID`) ON DELETE CASCADE,
  `status` INTEGER NOT NULL default 0,
  `comment` TEXT NOT NULL,
  `date` TEXT NOT NULL,
  `userID` INTEGER NOT NULL default 0 REFERENCES `tblUsers` (`id`) ON DELETE CASCADE
) ;
CREATE INDEX `indDocumentReceiptLogReceiptID` ON `tblDocumentReceiptLog` (`receiptID`);

CREATE TABLE `tblDocumentRevisors` (
  `revisionID` INTEGER PRIMARY KEY AUTOINCREMENT,
  `documentID` INTEGER NOT NULL default '0' REFERENCES `tblDocuments` (`id`) ON DELETE CASCADE,
  `version` INTEGER unsigned NOT NULL default '0',
  `type` INTEGER NOT NULL default '0',
  `required` INTEGER NOT NULL default '0',
  `startdate` TEXT default NULL,
  UNIQUE (`documentID`,`version`,`type`,`required`)
) ;
CREATE INDEX `indDocumentRevisorsRequired` ON `tblDocumentRevisors` (`required`);

CREATE TABLE `tblDocumentRevisionLog` (
  `revisionLogID` INTEGER PRIMARY KEY AUTOINCREMENT,
  `revisionID` INTEGER NOT NULL default 0 REFERENCES `tblDocumentRevisors` (`revisionID`) ON DELETE CASCADE,
  `status` INTEGER NOT NULL default 0,
  `comment` TEXT NOT NULL,
  `date` TEXT NOT NULL,
  `userID` INTEGER NOT NULL default 0 REFERENCES `tblUsers` (`id`) ON DELETE CASCADE
) ;
CREATE INDEX `indDocumentRevisionLogRevisionID` ON `tblDocumentRevisionLog` (`revisionID`);

CREATE TABLE `tblTransmittals` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `name` text NOT NULL,
  `comment` text NOT NULL,
  `userID` INTEGER NOT NULL default '0' REFERENCES `tblUsers` (`id`) ON DELETE CASCADE,
  `date` TEXT default NULL,
  `public` INTEGER NOT NULL default '0'
);

CREATE TABLE `tblTransmittalItems` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
	`transmittal` INTEGER NOT NULL DEFAULT '0' REFERENCES `tblTransmittals` (`id`) ON DELETE CASCADE,
  `document` INTEGER default NULL REFERENCES `tblDocuments` (`id`) ON DELETE CASCADE,
  `version` INTEGER unsigned NOT NULL default '0',
  `date` TEXT default NULL,
  UNIQUE (transmittal, document, version)
);

CREATE TABLE `tblRoles` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `name` varchar(50) default NULL,
  `role` INTEGER NOT NULL default '0',
  `noaccess` varchar(30) NOT NULL default '',
  UNIQUE (`name`)
);

INSERT INTO `tblRoles` (`id`, `name`, `role`) VALUES (1, 'Admin', 1);
INSERT INTO `tblRoles` (`id`, `name`, `role`) VALUES (2, 'Guest', 2);
INSERT INTO `tblRoles` (`id`, `name`, `role`) VALUES (3, 'User', 0);

UPDATE `tblUsers` SET role=3 WHERE role=0;

CREATE TABLE `new_tblUsers` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `login` varchar(50) default NULL,
  `pwd` varchar(50) default NULL,
  `fullName` varchar(100) default NULL,
  `email` varchar(70) default NULL,
  `language` varchar(32) NOT NULL,
  `theme` varchar(32) NOT NULL,
  `comment` text NOT NULL,
  `role` INTEGER NOT NULL REFERENCES `tblRoles` (`id`),
  `hidden` INTEGER NOT NULL default '0',
  `pwdExpiration` TEXT default NULL,
  `loginfailures` INTEGER NOT NULL default '0',
  `disabled` INTEGER NOT NULL default '0',
  `quota` INTEGER,
  `homefolder` INTEGER default NULL REFERENCES `tblFolders` (`id`),
  `secret` varchar(50) default NULL,
  UNIQUE (`login`)
);

INSERT INTO new_tblUsers SELECT * FROM tblUsers;

DROP TABLE tblUsers;

ALTER TABLE new_tblUsers RENAME TO tblUsers;

CREATE TABLE `tblAros` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `parent` INTEGER,
  `model` TEXT NOT NULL,
  `foreignid` INTEGER NOT NULL DEFAULT '0',
  `alias` TEXT
) ;

CREATE TABLE `tblAcos` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `parent` INTEGER,
  `model` TEXT NOT NULL,
  `foreignid` INTEGER NOT NULL DEFAULT '0',
  `alias` TEXT
) ;

CREATE TABLE `tblArosAcos` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `aro` INTEGER NOT NULL DEFAULT '0' REFERENCES `tblAros` (`id`) ON DELETE CASCADE,
  `aco` INTEGER NOT NULL DEFAULT '0' REFERENCES `tblAcos` (`id`) ON DELETE CASCADE,
  `create` INTEGER NOT NULL DEFAULT '-1',
  `read` INTEGER NOT NULL DEFAULT '-1',
  `update` INTEGER NOT NULL DEFAULT '-1',
  `delete` INTEGER NOT NULL DEFAULT '-1',
  UNIQUE (aco, aro)
) ;

CREATE INDEX `indDocumentStatusLogStatusID` ON `tblDocumentStatusLog` (`StatusID`);
CREATE INDEX `indDocumentApproversRequired` ON `tblDocumentApprovers` (`required`);
CREATE INDEX `indDocumentApproveLogApproveID` ON `tblDocumentApproveLog` (`approveID`);
CREATE INDEX `indDocumentReviewersRequired` ON `tblDocumentReviewers` (`required`);
CREATE INDEX `indDocumentReviewLogReviewID` ON `tblDocumentReviewLog` (`reviewID`);

CREATE TABLE `tblSchedulerTask` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `description` TEXT DEFAULT NULL,
  `disabled` INTEGER NOT NULL DEFAULT '0',
  `extension` varchar(100) DEFAULT NULL,
  `task` varchar(100) DEFAULT NULL,
  `frequency` varchar(100) DEFAULT NULL,
  `params` TEXT DEFAULT NULL,
  `nextrun` TEXT DEFAULT NULL,
  `lastrun` TEXT DEFAULT NULL
) ;

UPDATE tblVersion set major=6, minor=0, subminor=0;

COMMIT;

PRAGMA foreign_keys=on;