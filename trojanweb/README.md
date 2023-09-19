## dependencies


sudo apt install libmysqlclient-dev cpanminus -y

sudo cpanm DBI Mojolicious cpanm DBD::mysql Data::Page Mojolicious::Plugin::HTMX Number::Bytes::Human Crypt::RandPasswd Mojolicious::Plugin::AssetPack Session::Token Mojolicious::Plugin::I18N

mysql -uroot -pmy-secret-pw -h 192.168.3.30


## Trojan database schema

```json
{
	"mysql": {
		"enabled": true,
		"server_addr": "127.0.0.1",
		"server_port": 3306,
		"database": "trojan",
		"username": "trojan",
		"password": "",
		"key": "",
		"cert": "",
		"ca": ""
	}
}
```

```sql

CREATE TABLE users (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    username VARCHAR(64) NOT NULL UNIQUE,
    password CHAR(56) NOT NULL,
    quota BIGINT NOT NULL DEFAULT 0,
    download BIGINT UNSIGNED NOT NULL DEFAULT 0,
    upload BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX (password)
);

CREATE TABLE roles (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY (name)
);

CREATE TABLE configs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    is_used BOOLEAN NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	owner_id INT UNSIGNED, -- Add the owner_id column
    config TEXT,
    PRIMARY KEY (id),
	FOREIGN KEY (owner_id) REFERENCES users(id), -- Add foreign key reference
    UNIQUE KEY (password)
);

CREATE TABLE IF NOT EXISTS downloads (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    url VARCHAR NOT NULL,
    pathname VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);


ALTER TABLE users
ADD COLUMN role_id INT UNSIGNED,
ADD FOREIGN KEY (role_id) REFERENCES roles(id);


```

```sql
use trojan;
ALTER TABLE users
ADD created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE users ADD UNIQUE (`username`);

INSERT INTO roles (name) values ('admin');
SELECT id FROM roles WHERE name = 'admin';
INSERT INTO users (username, password, role_id) values ('admin', 'f8cdb04495ded47615258f9dc6a3f4707fd2405434fefc3cbf4ef4e6', 1);
```

## codemirror rollup
```shell

mkdir codemirror-rollup
cd codemirror-rollup
npm init

npm i rollup @rollup/plugin-node-resolve codemirror @codemirror/legacy-modes
node_modules/.bin/rollup editor.mjs -f iife -o editor.bundle.js -p @rollup/plugin-node-resolve

```

## i18n

sudo apt install gettext

msgfmt i18n/en.po -o i18n/en.mo
msgfmt i18n/zh.po -o i18n/zh.mo
