#!/bin/sh
# Тесты плагина review (plenary busted, без загрузки всего конфига)
TESTS="$(cd "$(dirname "$0")" && pwd)"
exec nvim --headless --clean -u "$TESTS/minimal_init.lua" \
  -c "PlenaryBustedDirectory $TESTS { minimal_init = '$TESTS/minimal_init.lua' }"
