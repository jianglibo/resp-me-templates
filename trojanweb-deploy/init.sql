CREATE DATABASE IF NOT EXISTS {{mysql.db_name}};

use {{mysql.db_name}};

CREATE USER IF NOT EXISTS '{{mysql.db_user}}' @'localhost' IDENTIFIED BY
    '{{mysql.db_user_password}}';

GRANT ALL PRIVILEGES ON {{mysql.db_name}}. * TO '{{mysql.db_user}}' @'localhost';

FLUSH PRIVILEGES;

CREATE TABLE IF NOT EXISTS users(
    id int UNSIGNED NOT NULL AUTO_INCREMENT,
    username varchar(64) NOT NULL UNIQUE,
    password CHAR(56) NOT NULL,
    quota bigint NOT NULL DEFAULT 0,
    download bigint UNSIGNED NOT NULL DEFAULT 0,
    upload bigint UNSIGNED NOT NULL DEFAULT 0,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX (PASSWORD)
);

CREATE TABLE IF NOT EXISTS roles(
    id int UNSIGNED NOT NULL AUTO_INCREMENT,
    name varchar(64) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY (name)
);

CREATE TABLE IF NOT EXISTS configs(
    id int UNSIGNED NOT NULL AUTO_INCREMENT,
    password VARCHAR(255) NOT NULL,
    name varchar(255) NOT NULL,
    is_used boolean NOT NULL DEFAULT 0,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    owner_id int UNSIGNED, -- Add the owner_id column
    config text,
    PRIMARY KEY (id),
    FOREIGN KEY (owner_id) REFERENCES users(id), -- Add foreign key reference
    UNIQUE KEY (PASSWORD)
);

CREATE TABLE IF NOT EXISTS downloads(
    id int UNSIGNED NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    url varchar(255),
    pathname varchar(255),
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

INSERT INTO downloads(name, url, pathname)
    VALUES ('Clash.for.Windows.Setup.0.20.34.exe', 'https://github.com/Fndroid/clash_for_windows_pkg/releases/download/0.20.34/Clash.for.Windows.Setup.0.20.34.exe', 'Clash.for.Windows.Setup.0.20.34.exe'),
('cfa-2.5.12-premium-universal-release.apk', 'https://github.com/Kr328/ClashForAndroid/releases/download/v2.5.12/cfa-2.5.12-premium-universal-release.apk', 'cfa-2.5.12-premium-universal-release.apk');

ALTER TABLE users
    ADD COLUMN role_id INT UNSIGNED,
    ADD FOREIGN KEY (role_id) REFERENCES roles(id);

INSERT INTO roles(name)
    VALUES ('admin');

INSERT INTO users(username, PASSWORD, role_id)
SELECT
    'admin',
    'sha224_admin_password',
    id
FROM
    roles
WHERE
    name = 'admin';

