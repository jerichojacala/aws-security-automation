# aws-security-automation

## How It Works

Using Terraform, I turned off the AWS public access block. When configuring access control lists for resources, it's possible that one might accidentally make sensitive resources publicly accessible. In order to protect against this, AWS blocks ACLs that allow for public access. I disabled this in order to make a proof-of-concept of automated monitoring. Upon deploying the architecture, a chain reaction starts as follows:

1. Disable AWS public access block
1. Create an intentionally publicly accessible s3 bucket
1. A config recorder detects the change in state, audits the system for compliance with config rules, and determines that the bucket is non-compliant
1. An EventBridge rule detects the compliance change
1. A Lambda function targetted by the EventBridge rule is triggered
1. The Lambda function creates a warning log

## Problems I ran into (to talk about in interviews)

1. Race conditions

Before setting out on this project, I had never used terraform to build infrastructure where components relied on each other. During this project, I ran into an issue where I tried to create a public policy while simultaneously disabling the aws public access block. When I tried to deploy the system, I ran into an error, read it, developed a theory that this was the case. Based off of my limited knowledge of Terraform I asked myself, *At a high level, how would Terraform execute the code I gave it? How might that cause problems?* I recognized the potential of a race condition, searched for other potential issues, fed the error message to an LLM to corroborate, and cross-checked the recommended fix with Terraform documentation. From there, the issue was quickly solved.

1. Permissions

Permissions seem particularly complicated within AWS. Other cloud platforms might have a set of pre-defined roles, but AWS has their own roles while also offering the option to define specific permissions that allow for precise control over what users can and cannot do. However, this complicates things. If you aren't well versed in the mechanisms behind how infrastructure is raised, configured, and deleted, this might be a headache, especially if security is your goal. In Terraform, I ran into many different issues which lead to incomplete states related to permissions. An interesting example was creating a simple s3 bucket with a service account that just had permission to create a bucket, and nothing else. When I tried to create the bucket, the bucket was successfully created, but the Terraform process was stuck hanging. 

It is in these situations where it might help to remove variables from the process in order to determine what is wrong. In this case, I thought about how I would go about creating a bucket using the service account in the console. If it would go smoothly, then something is likely wrong with Terraform. If not, I revise accordingly. In this case, I didn't even have to try making a bucket in the console- after some thinking, I realized Terraform needed to confirm that the bucket was successfully created- something that required permissions to list s3 buckets! I gave the service account the correct permissions and continued on.