package terraform.security

# Ensure the Docker image used for the Akaunting app is from the trusted source
trusted_akaunting_image {
    input.resource.name == "akaunting-app"
    input.resource.image == "hicham2004/akaunting-app:v1"
}

# Ensure the Docker image used for MySQL is of the correct version
correct_mysql_version {
    input.resource.name == "mysql-db"
    input.resource.image == "mysql:8.0"
}

# Deny if the Akaunting image is not from the trusted source
deny_untrusted_akaunting_image[msg] {
    not trusted_akaunting_image
    msg = "Akaunting app image must be from 'hicham2004/akaunting-app:v1'"
}

# Deny if the MySQL image is not the correct version
deny_wrong_mysql_version[msg] {
    not correct_mysql_version
    msg = "MySQL image version must be 'mysql:8.0'"
}

# Ensure containers don't run as root (for security)
deny_root_user[msg] {
    input.resource.name == "akaunting-app"
    input.resource.user == "root"
    msg = "Akaunting app container should not run as root"
}

deny_root_user[msg] {
    input.resource.name == "mysql-db"
    input.resource.user == "root"
    msg = "MySQL container should not run as root"
}

# Ensure the Akaunting app has a specific environment variable for database connection
required_env_vars[msg] {
    input.resource.name == "akaunting-app"
    not input.resource.env["MYSQL_PASSWORD"]
    msg = "Akaunting app container must have MYSQL_PASSWORD environment variable set"
}

# Ensure the MySQL container has the correct database credentials environment variables
required_mysql_env_vars[msg] {
    input.resource.name == "mysql-db"
    not input.resource.env["MYSQL_ROOT_PASSWORD"]
    msg = "MySQL container must have MYSQL_ROOT_PASSWORD environment variable set"
}

# Ensure containers are not running with excessive privileges
deny_privileged_mode[msg] {
    input.resource.name == "akaunting-app"
    input.resource.privileged == true
    msg = "Akaunting app container should not run in privileged mode"
}

deny_privileged_mode[msg] {
    input.resource.name == "mysql-db"
    input.resource.privileged == true
    msg = "MySQL container should not run in privileged mode"
}

# Deny if the container's image is not from a trusted registry
deny_untrusted_registry[msg] {
    input.resource.name == "akaunting-app"
    not startswith(input.resource.image, "hicham2004/")
    msg = "Akaunting app container image must be from a trusted registry"
}

deny_untrusted_registry[msg] {
    input.resource.name == "mysql-db"
    not startswith(input.resource.image, "mysql:")
    msg = "MySQL container image must be from a trusted registry"
}

# Combine all deny rules
deny[msg] {
    deny_untrusted_akaunting_image[msg]
}
deny[msg] {
    deny_wrong_mysql_version[msg]
}
deny[msg] {
    deny_root_user[msg]
}
deny[msg] {
    deny_privileged_mode[msg]
}
deny[msg] {
    deny_untrusted_registry[msg]
}
deny[msg] {
    required_env_vars[msg]
}
deny[msg] {
    required_mysql_env_vars[msg]
}
