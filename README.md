# terraform-examples
Some example for me to refrence when learning terraform on GCP

## Important to remember

Specify credentials environmental variable for it to authenticate
```bash
$Env:GOOGLE_APPLICATION_CREDENTIALS="C:\Users\fkubawsx\OneDrive - Intel Corporation\terraform-examples\key.json"
```

## Files in the repo
- [basic.tf](https://github.com/Filip3Kx/terraform-examples/blob/main/basic.tf)
  - remote backend on gcs
  - one ubuntu vm that has docker installed
