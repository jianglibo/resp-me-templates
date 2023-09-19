{
	host => 'localhost',
	post => 3306,
	database => 'trojan',
	username => 'trojan',
	password => '{{mysql.db_user_password}}',
	secret => '{{mojolicious.secret}}',
	domain_name => '{{cert_dependency.domain_name}}',
}