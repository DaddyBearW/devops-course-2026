# Ansible-проект практической работы № 11

Управляющий узел — WSL Ubuntu, управляемый — VM `devops-vm` (192.168.56.101).

## Файлы

- `inventory/bootstrap.ini` — первичный доступ (student, ключ);
- `inventory/prod.ini` — рабочий доступ (devops, ключ `~/.ssh/devops_vm`);
- `group_vars/all.yml` — образ GHCR и полный SHA;
- `site.yml` — роли `base`, `ssh`, `nginx`, `app`;
- `verify.yml` — read-only аудит.

## Запуск

```bash
cd ~/devops-course-2026/ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml
ansible-playbook verify.yml
```

Повторный запуск `site.yml` должен давать `changed=0`, `failed=0`.
