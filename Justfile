plan-cache:
  tofu -chdir=hosts/cache plan

apply-cache:
  tofu -chdir=hosts/cache apply

destroy-cache:
  tofu -chdir=hosts/cache destroy
