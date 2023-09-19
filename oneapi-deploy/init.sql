CREATE DATABASE IF NOT EXISTS {{mysql.db_name}};

use {{mysql.db_name}};

CREATE USER IF NOT EXISTS '{{mysql.db_user}}' @'localhost' IDENTIFIED BY
    '{{mysql.db_user_password}}';

GRANT ALL PRIVILEGES ON {{mysql.db_name}}. * TO '{{mysql.db_user}}' @'localhost';

FLUSH PRIVILEGES;

