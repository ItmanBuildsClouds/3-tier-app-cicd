data "aws_ssm_parameter" "db_username" {
  name = "/3tierapp/database/username"
}
data "aws_ssm_parameter" "db_password" {
  name            = "/3tierapp/database/password"
  with_decryption = true
}