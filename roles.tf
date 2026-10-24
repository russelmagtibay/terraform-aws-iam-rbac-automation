
#here we create our plan 
locals {
  role_policies = {
    readonly =[ 
        "ReadOnlyAccess" #policies
    ]
    admin = [ #role
        "AdministratorAccess" #policies
    ]
    auditor = [#role
        "SecurityAudit"
    ]
    developer = [#role
        "AmazonVPCFullAccess",#policies
        "AmazonEC2FullAccess",#policies
        "AmazonRDSFullAccess"#policies

    ]

  }
    #creating mapping to 
  role_policies_list = flatten([
    for role, policies in local.role_policies : [
        for policy in policies : {
            role = role
            policy = policy
        }
    ]
  ])
} 

# What flatten does is magic: it turns that group into this simple shopping list:

# Give readonly ➔ ReadOnlyAccess
# Give admin ➔ AdministratorAccess
# Give auditor ➔ SecurityAudit
# Give developer ➔ AmazonVPCFullAccess
# Give developer ➔ AmazonEC2FullAccess
# Give developer ➔ AmazonRDSFullAccess

output "polices" {
  value = local.role_policies_list
}

data "aws_caller_identity" "current "{}

data "aws_iam_policy_document" "assume_role_policy" {
  for_each = toset(keys(local.role_policies))
  statement {
    actions = ["sts: AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        for username in keys(aws.iam_user.user) : "arn:aws:iam::${data.aws_caller_identity.current.account_id}: user/${username}"
        if contains(local.users_map[username],each.each.value)
      ]
    }
  }
}

#Before we attach keys, the badges must actually exist in AWS!
#keys(...) gets just the 4 badge names: admin, readonly, auditor, developer.
#keys(...) gets just the 4 badge names: admin, readonly, auditor, developer.

  
  
resource "aws_iam_role" "role" {
  for_each = toset(keys(local.role_policies))
  name = each.key
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy[each.value].json
}

#Before we staple them, we have to look up where AWS keeps them:
data "aws_iam_policy" "managed_policies" {
  for_each = toset(local.role_policies_list[*].policy)
  arn      ="arn:aws:iam::aws:policy/${each.value}" 
  #In AWS, every item has an official ID called an ARN (like a tracking barcode).
  #This block just looks up the official barcode for each key name so we can grab the right one.
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  count = length(local.role_policies_list)
  
  role  = aws.iam_role.role[local.role_policies_list
  [count.index].role].name

  policy_arn = data.aws_iam_policy.managed_policies[local.role_policies_list
  [count.index].policy].arn

}

# count = 6: This runs 6 times (once for each line on our to-do list).

  
# Round 1: Grab readonly badge, staple ReadOnlyAccess key.

  
# Round 2: Grab admin badge, staple AdministratorAccess key.

  
# Round 3: Grab auditor badge, staple SecurityAudit key.

  
# Round 4: Grab developer badge, staple AmazonVPCFullAccess key.

  
# Round 5: Grab developer badge, staple AmazonEC2FullAccess key.

  
# Round 6: Grab developer badge, staple AmazonRDSFullAccess key.