# Scripts

## Ansible (CentOS only)

Ansible will require sudo privileges but these should be specified at runtime using the `--ask-become-pass` flag.

The install playbooks invoke bash installation scripts. These do not remove data and logs, but always ensure to backup. See backup and restore below.

To run the full set of Ansible playbooks for an initial installation including a backup if OpenInfoMan used to exist:

```sh
ansible-playbook -i /usr/local/etc/ansible/hosts ansible_backup.yaml
# prep if for centos only
ansible-playbook --ask-become-pass -i /usr/local/etc/ansible/hosts ansible_prep.yaml
# any Unix-like platform
ansible-playbook --ask-become-pass -i /usr/local/etc/ansible/hosts ansible_install.yaml
ansible-playbook --ask-become-pass -i /usr/local/etc/ansible/hosts ansible_install_test.yaml

> Note: The DATIM OpenInfoMan library requires access to a private repository. Cloning the repo is necessary for the DATIM installation so the remote host must be able to access the private repo. The recommended way to do this is to use SSH agent forwarding. Arranging this is beyond the scope of this document. See the [GitHub guide to SSH agent forwarding](https://developer.github.com/v3/guides/using-ssh-agent-forwarding). On CentOS, SSH agent forwarding is off by default. Change this in `/etc/ssh/ssh_config`. Also note the issue with connecting from [Macs](https://apple.stackexchange.com/questions/254468/macos-sierra-doesn-t-seem-to-remember-ssh-keys-between-reboots)
```

DATIM
```
ansible-playbook --ask-become-pass -i /usr/local/etc/ansible/hosts ansible_install_datim.yaml
ansible-playbook --ask-become-pass -i /usr/local/etc/ansible/hosts ansible_install_datim_test.yaml
```

Ansible playbooks should be used in the following order in the table.

Order | File | Privileges Req | Purpose
--- | --- | --- | ---
1 | ansible_backup.yaml | non-sudo | Backs up any OpenInfoMan data and logs by default into `~/backup`. This should be amended for S3 buckets or other storage as well. There is an additional backup backup in the install script, but this one is recommended.
2 | ansible_prep.yaml | sudo | **CentOS only** Ensures the required dependencies are installed.
3 | ansible_install.yaml | non-sudo | Installs base OpenInfoMan. No additional libraries are installed. Most use cases require more libraries.
4 | ansible_install_test.yaml | non-sudo | Tests to ensure that OIM is running and has some functionality. A first-level support method.
5 | ansible_install_datim.yaml | non-sudo | DATIM additional libraries. If you want to install additional libaries other than just the DATIM ones (which include only DHIS2 and DATIM) then do not use this playbook. Use the install_additional.sh script instead.
6 | ansible_install_datim_test.yaml | non-sudo | Tests to ensure the DATIM libraries are running correctly. A first level support tool.
If needed | ansible_restore.yaml | non-sudo | Restores the latest backup from `~/backup/data`.

To use Ansible, your SSH public key should be in `.ssh/authorized_keys` on the remote host and you must also create an /etc/ansible/hosts or similar with the IP address or hostname of the remote host. An `ansible/hosts` file that has an entry for localhost and one server would be:

```sh
[local]
localhost ansible_connection=local

[servers]
172.16.174.137
```
