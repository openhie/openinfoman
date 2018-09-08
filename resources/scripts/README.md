# Scripts

## Ansible (CentOS only)

Ansible will require sudo privileges but these should be specified at runtime using the `--ask-become-pass` flag.

To use Ansible, your SSH public key should be in `.ssh/authorized_keys` on the remote host and you must also create an /etc/ansible/hosts or similar with the IP address or hostname of the remote host. An `ansible/hosts` file that has an entry for localhost and one server would be:

```sh
[local]
localhost ansible_connection=local country_code=UK

[servers]
172.16.174.137 country_code=US
```
The above example includes a working example for localhost configuration and also the creation of the host variable `country_code` which will become accessible in the playbooks using `{{ country_code }}`.

> Note: The install playbooks invoke bash installation scripts. These do not remove data and logs, but always ensure to backup. See backup and restore below.

To run the full set of Ansible playbooks for an initial installation including a backup if OpenInfoMan used to exist:

```sh
ansible-playbook -i /usr/local/etc/ansible/hosts ansible_backup.yaml
# prep if for centos only -- requires sudo access
ansible-playbook --ask-become-pass -i /usr/local/etc/ansible/hosts ansible_prep.yaml
# any Unix-like platform
ansible-playbook -i /usr/local/etc/ansible/hosts ansible_install.yaml
ansible-playbook -i /usr/local/etc/ansible/hosts ansible_install_test.yaml
```

## Backup and Restores

>For robust a robust backup process, run the ansible_backup playbook which includes creating a cronjob for daily backups including copying over the shell script invoked by cron.

To do an adhoc backup, use the official basex command for backups in order to be robust to jobs in the queue:
```
basex -Vc 'create backup provider_directory'
```
The bash install script (which the Ansible install playbook also calls) does an immediate backup of logs and data and adds.

To restore the backup must be copied back into the main data folder before it can be restored.
```sh
# go into the backups data folder
cd $HOME/backup/data
# copy the backup file you want back into place
cp provider_directory-2018-09-07-22-00-01.zip ~/openinfoman/data
# issue the restore command. do not include the .zip extension of the name, e.g:
$HOME/openinfoman/bin/basex -Vc 'restore provider_directory-2018-07-23-12-09-47'
```

## DATIM-specific

The DATIM OpenInfoMan library requires access to a private repository. Cloning the repo is necessary for the DATIM installation so the remote host must be able to access the private repo. The recommended way to do this is to use SSH agent forwarding. Arranging this is beyond the scope of this document.

> See the [GitHub guide to SSH agent forwarding](https://developer.github.com/v3/guides/using-ssh-agent-forwarding). In short, an entry for the domain and/or IP address must be in `~/.ssh/config`. On CentOS, SSH agent forwarding is off by default (see the output of `grep Agent /etc/ssh/sshd_config`. Change this in `/etc/ssh/ssh_config` and restart the SSH server with `systemctl restart sshd.service`.

> For those on Macs, also note the [issue](https://apple.stackexchange.com/questions/254468/macos-sierra-doesn-t-seem-to-remember-ssh-keys-between-reboots) with connecting using SSH agent forwarding in which the key used may disappear and need to be added again to be visible to the ssh agent.


```
ansible-playbook -i /usr/local/etc/ansible/hosts ansible_install_datim.yaml
ansible-playbook -i /usr/local/etc/ansible/hosts ansible_install_datim_test.yaml
```

To create XXOU-Managed documents for the DATIM use case ensure that there are country_code vars in the hosts inventory, then:

```sh
ansible-playbook -i /usr/local/etc/ansible/hosts ansible_create_datim_doc.yaml
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
7 | ansible_create_datim_doc.yaml | non-sudo | Add country code prefixed XXOU-Managed documents.