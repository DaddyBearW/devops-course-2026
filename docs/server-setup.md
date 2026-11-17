
# Настройка DevOps-сервера

## 9. Контейнеризация

### Docker Engine
На сервере Ubuntu установлен Docker Engine и Docker Compose Plugin.
Проверка версий:
```bash
docker --version
docker compose version
```

### Размещение приложения
Исходный код приложения размещается на сервере в каталоге `/home/devops/app`.

### Переменные окружения
Файл `/home/devops/app/.env` содержит параметры подключения к PostgreSQL.
Файл должен иметь права доступа `600` и не должен попадать в Git.

### Контейнеры и сеть
Приложение запускается через Docker Compose.
Сервисы приложения и PostgreSQL находятся в отдельной сети Docker.
Данные PostgreSQL хранятся в именованном Docker volume.

### Публикация портов
Порт приложения публикуется только на `127.0.0.1`.
Порт PostgreSQL не должен быть опубликован на интерфейсах хоста.

### Обратный прокси
Nginx принимает HTTPS-запросы для `devops.local`.
Запросы к `/app/` проксируются на Docker-приложение через `127.0.0.1:5001`.

## 10. Ansible

### Расположение проекта
Проект находится в репозитории `devops-course-2026` в каталоге `ansible/`.
Управляющий узел — WSL Ubuntu, управляемый — VM `devops-vm` с адресом
`192.168.56.101`.

### Inventory и доступ
- `inventory/bootstrap.ini` — первичный доступ от `student` по ключу;
- `inventory/prod.ini` — рабочий доступ от `devops` по ключу
  `~/.ssh/devops_vm`.

Пароли и закрытые ключи в репозиторий не добавляются. Для неинтерактивного
запуска пользователю `devops` разрешён `sudo` без пароля.

### Роли
- `base` — проверка платформы, базовые пакеты, официальный репозиторий Docker,
  Docker Engine;
- `ssh` — пользователь `devops`, открытый ключ, sudo, hardening SSH, UFW;
- `nginx` — установка Nginx, reverse proxy, проверка `nginx -t`, reload;
- `app` — загрузка образа из GHCR, контейнер, health-check.

### Образ и порт
- образ: `ghcr.io/daddybearw/devops-ci-app`;
- полный SHA: `bb196bc709df5b9004c709a0bf8aaca22b0e29eb`;
- контейнер: `devops-ci-app`;
- публикация: `127.0.0.1:5000 -> 5000/tcp`;
- health endpoint: `/health`.

### Команды
```bash
cd ~/devops-course-2026/ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml
ansible-playbook verify.yml
```

Повторный запуск `site.yml` должен завершаться `changed=0`, `failed=0`.
`verify.yml` не изменяет конфигурацию и также должен давать `changed=0`.
