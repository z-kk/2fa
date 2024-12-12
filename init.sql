ALTER USER root@localhost IDENTIFIED BY 'pwd';
CREATE USER `tfauser` IDENTIFIED BY 'tfapass';
GRANT ALL ON *.* TO `tfauser` WITH GRANT OPTION;
