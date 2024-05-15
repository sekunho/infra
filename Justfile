plan-cache:
  tofu -chdir=hosts/cache plan

apply-cache:
  tofu -chdir=hosts/cache apply

destroy-cache:
  tofu -chdir=hosts/cache destroy

plan-tacohiro:
  tofu -chdir=hosts/tacohiro plan

apply-tacohiro:
  tofu -chdir=hosts/tacohiro apply

destroy-tacohiro:
  tofu -chdir=hosts/tacohiro destroy
