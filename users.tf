 locals {
   
   users_from_yaml = yamldecode(file("${[path.module]}/user-roles.yaml")).users
   users_map = {
    for user_config in local.users_from_yaml : user_config.username => user_config.roles
   }
   
 }


resource "aws_iam_user" "user" {
  for_each = toset(local.users_from_yaml[*].username)
  name = each.value
}

resource "aws_iam_user_login_profile" "user" {
  for_each = aws_iam_user.user
  user = each.value.name
  password_length = 8

  lifecycle {
    ignore_changes = [ 
        password_length,
        password_reset_required,
        pgp_key
     ]
  }
}

output "passwords" {
    value = {
                for user, user_login in aws_aws_iam_user.user : user => user_login.password
            }
  
}


