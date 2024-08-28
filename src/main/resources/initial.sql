
drop database expense_tracker;
create database expense_tracker;


INSERT IGNORE INTO `expense_tracker`.`organization`
(`id`,
`name`)
VALUES
(1,
'egcity');

INSERT IGNORE INTO `expense_tracker`.`organization`
(`id`,
`name`)
VALUES
(2,
'anonymous');

INSERT INTO `expense_tracker`.`users`
(`id`,
`password`,
`username`,
`organization_id`)
VALUES
(101,
'$2a$04$dzz91QUINWlllzzX7cK/TudKCZb5ZMlvCHdxEkx/nHUaX7d/dbFIa',
'raja',
1);
