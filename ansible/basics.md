# Ansible - Basics
## Facts and filtering
### Gather facts on all hosts

`ansible all -m setup`

### use threading?

`ansible all -m setup --fork=4`

### filter results
`ansible all -m setup -a "filter=ansbile_all_ipv4_addresses" --tree facts`

*(facts are saved in the /facts directory)*

## Conditionals
Install A on Debian, install B on Redhat

```
---
- hosts: all
  become: yes
  tasks:
  - name: install A
    apt: name=apache2
    when: anisble_os_family == "Debian"
  - name: install b
    yum: name=httpd 
    when: anisble_os_family == "Redhat"
```
