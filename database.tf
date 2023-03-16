
# Postgres Database for the app
resource "aws_db_instance" "database" {

  db_name = "testappdb"
  identifier = "testapp-db"

  instance_class = "db.t3.micro"
  engine = "postgres"
  engine_version = "15.2"

  multi_az = false
  allocated_storage    = 10 # gibibytes

  username = "root"
  password = "xw3489sf"

  apply_immediately = true
  skip_final_snapshot = true
}