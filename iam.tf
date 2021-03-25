#User and Groups

# IAM Users

# System Admin 1
resource "aws_iam_user" "sysAdmin1" {
  name = "sysAdmin1"
}
resource "aws_iam_access_key" "sysAdmin1" {
  user = aws_iam_user.sysAdmin1.name
}
resource "aws_iam_user_login_profile" "SystemAdmin1" {
  user            = aws_iam_user.sysAdmin1.name
  password_length = 10

  pgp_key = "keybase:terraform"
}
output "SysAdmin1-Password" {
  value = aws_iam_user_login_profile.SystemAdmin1.encrypted_password
}
output "SysAdmin1-AccessKeyID" {
  value = aws_iam_access_key.sysAdmin1.id
}
output "SysAdmin1-SecretAccessKey" {
  value = aws_iam_access_key.sysAdmin1.ses_smtp_password_v4
}


resource "aws_iam_user" "sysAdmin2" {
  name = "sysAdmin2"
}

resource "aws_iam_user" "dbAdmin1" {
  name = "dbAdmin1"
}

resource "aws_iam_user" "dbAdmin2" {
  name = "dbAdmin2"
}

resource "aws_iam_user" "monitoring1" {
  name = "monitoring1"
}

resource "aws_iam_user" "monitoring2" {
  name = "monitoring2"
}

resource "aws_iam_user" "monitoring3" {
  name = "monitoring3"
}

resource "aws_iam_user" "monitoring4" {
  name = "monitoring4"
}

# IAM Groups
resource "aws_iam_group" "sysAdminGr" {
  name = "sysAdminGr"
}

resource "aws_iam_group" "dbAdminGr" {
  name = "dbAdminGr"
}

resource "aws_iam_group" "monitorGr" {
  name = "monitorGr"
}

# Attaching users to Groups
resource "aws_iam_group_membership" "Systeam" {
  name = "Systeam"
  users = [
    aws_iam_user.sysAdmin1.name,
    aws_iam_user.sysAdmin2.name
  ]
  group = aws_iam_group.sysAdminGr.name
}

resource "aws_iam_group_membership" "DBteam" {
  name = "BDteam"
  users = [
    aws_iam_user.dbAdmin1.name,
    aws_iam_user.dbAdmin2.name
  ]
  group = aws_iam_group.dbAdminGr.name
}

resource "aws_iam_group_membership" "Monitorteam" {
  name = "Monitorteam"
  users = [
    aws_iam_user.monitoring1.name,
    aws_iam_user.monitoring2.name,
    aws_iam_user.monitoring3.name,
    aws_iam_user.monitoring4.name
  ]
  group = aws_iam_group.monitorGr.name
}

# Attaching policies to groups
resource "aws_iam_policy" "SysAdminPolicy" {
  name        = "SysAdminPolicy"
  description = "Sysadmins administrator policy"
  policy      = file("adminpolicy.json")
}

resource "aws_iam_group_policy_attachment" "sysadmin-attach" {
  group      = aws_iam_group.sysAdminGr.name
  policy_arn = aws_iam_policy.SysAdminPolicy.arn
}

resource "aws_iam_policy" "DBAdminPolicy" {
  name        = "DBAdminPolicy"
  description = "Database administrator policy"
  policy      = file("dbadminpolicy.json")
}

resource "aws_iam_group_policy_attachment" "dbadmin-attach" {
  group      = aws_iam_group.dbAdminGr.name
  policy_arn = aws_iam_policy.DBAdminPolicy.arn
}

resource "aws_iam_policy" "MonitorPolicy" {
  name        = "MonitorPolicy"
  description = "Monitoring policy"
  policy      = file("monitorpolicy.json")
}

resource "aws_iam_group_policy_attachment" "monitor-attach" {
  group      = aws_iam_group.monitorGr.name
  policy_arn = aws_iam_policy.MonitorPolicy.arn
}
