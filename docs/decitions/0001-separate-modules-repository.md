0001 - Separate Terraform Modules Repository

Status:
Accepted

Context:
Multiple AWS projects will reuse networking, IAM, and EC2 modules.

Decision:
Create a dedicated terraform-aws-modules repository versioned with Git tags.

Consequences:
+ Reusable modules
+ Semantic versioning
+ Independent releases
- Slightly more initial setup