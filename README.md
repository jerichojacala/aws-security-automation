# aws-security-automation

## Problems I ran into (to talk about in interviews)

1. Race conditions

Before setting out on this project, I had never used terraform to build infrastructure where components relied on each other. During this project, I ran into an issue where I tried to create a public policy while simultaneously disabling the aws public access block. When I tried to deploy the system, I ran into an error, read it, developed a theory that this was the case. Based off of my limited knowledge of Terraform I asked myself, *At a high level, how would Terraform execute the code I gave it? How might that cause problems?* I recognized the potential of a race condition, searched for other potential issues, fed the error message to an LLM to corroborate, and cross-checked the recommended fix with Terraform documentation. From there, the issue was quickly solved.