
#!/usr/bin/env bash

ERRORS=0

check() {
    name="$1"
    shift

    if "$@"; then
        printf '[OK]   %s\n' "$name"
    else
        printf '[FAIL] %s\n' "$name"
        ERRORS=$((ERRORS + 1))
    fi
}

# 1. Docker service
check "Docker service is active" \
    ssh devops 'systemctl is-active --quiet docker'

# 2. PostgreSQL health
check "PostgreSQL container is healthy" \
    ssh devops 'test "$(docker inspect -f "{{.State.Health.Status}}" app-db-1 2>/dev/null)" = healthy'

# 3. Ports must not be published on external interfaces
check "Application and PostgreSQL ports are not exposed externally" \
    ssh devops 'if ss -ltn | grep -E "0\.0\.0\.0:(5000|5001|5432)|\[::\]:(5000|5001|5432)"; then exit 1; else exit 0; fi'

# 4. Environment file permissions
check ".env permissions are 600" \
    ssh devops 'test "$(stat -c "%a" /home/devops/app/.env 2>/dev/null)" = 600'

echo
if [ "$ERRORS" -eq 0 ]; then
    echo "Audit passed."
    exit 0
else
    echo "Audit failed: $ERRORS check(s) failed."
    exit 1
fi

