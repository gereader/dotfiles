# Terraform / Terragrunt
- Before reporting done: `terraform fmt -recursive` (or `terragrunt hclfmt`), `terraform validate`.
- `plan` only when asked; summarize adds/changes/destroys, flag any destroy or replace.
- Follow the repo's module layout and version pins; don't upgrade providers or modules unasked.
