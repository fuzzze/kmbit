#!/bin/bash
# КМ БИТ — публикация папки проекта на GitHub
#   main      — всё содержимое папки как есть + KMBit_brandbook.zip (перезаписывается)
#   gh-pages  — сайт https://fuzzze.github.io/kmbit/
# Запуск: двойной щелчок по файлу или ./publish.command "что изменилось"

set -euo pipefail
cd "$(dirname "$0")"

REPO="fuzzze/kmbit"
REMOTE="${KMBIT_REMOTE:-https://github.com/$REPO.git}"
SITE="https://fuzzze.github.io/kmbit/"
DESC="Фирменный стиль «КМ БИТ»: знак, логотипы, брендбук PDF и версия для ИИ"
ZIP="KMBit_brandbook.zip"
MSG="${1:-Обновление брендбука — $(date '+%Y-%m-%d %H:%M')}"

say()  { printf '\033[1;34m▸\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m✕ %s\033[0m\n' "$*"; pause; exit 1; }
pause(){ [ -t 0 ] && [ -z "${KMBIT_NOPAUSE:-}" ] && read -r -n1 -p "Нажмите любую клавишу…" _ && echo || true; }

command -v git >/dev/null || fail "Не найден git. Установите: xcode-select --install"
command -v zip >/dev/null || fail "Не найден zip"

HAVE_GH=0
if [ -z "${KMBIT_REMOTE:-}" ] && command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
  HAVE_GH=1
  gh auth setup-git >/dev/null 2>&1 || true      # git push берёт авторизацию из gh
fi

# 1. Репозиторий в папке проекта
if [ ! -d .git ]; then
  say "Первый запуск: подключаю папку к $REPO"
  git init -q -b main
  git remote add origin "$REMOTE"
  if git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
    git fetch -q origin main
    git reset -q origin/main        # история с GitHub; файлы в папке остаются как есть
  fi
fi
git config user.name  >/dev/null || git config user.name  "Ложкин Дмитрий"
git config user.email >/dev/null || git config user.email "logo@lozhkin.net"

[ -f .gitignore ] || printf '.DS_Store\n**/.DS_Store\n' > .gitignore

# 2. Архив с постоянным именем
say "Собираю $ZIP"
rm -f "$ZIP"
zip -qr -X "$ZIP" . \
  -x '.git/*' '.gitignore' '*.DS_Store' "$ZIP" 'publish.command' 'site/*' 'README.md'

# 3. Коммит в main (содержимое папки всегда побеждает)
git add -A
if git diff --cached --quiet; then
  say "Изменений в файлах нет"
else
  git commit -q -m "$MSG"
  say "Коммит: $MSG"
fi
if ! git push -q origin main 2>/dev/null; then
  say "На GitHub есть более новые коммиты — кладу содержимое папки поверх"
  git fetch -q origin main
  git reset -q --soft origin/main
  git diff --cached --quiet || git commit -q -m "$MSG"
  git push -q origin main || fail "Не удалось отправить main"
fi

# 4. Сайт в ветке gh-pages (перезаписывается целиком)
say "Обновляю сайт (gh-pages)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp site/index.html "$TMP/"
cp -R brandbook_assets "$TMP/"
cp KMBit_brandbook.pdf KMBit_brandbook_AI.md KMBit_recursion.html "$ZIP" kmbit_logo_*.svg "$TMP/"
touch "$TMP/.nojekyll"
(
  cd "$TMP"
  git init -q -b gh-pages
  git add -A
  git -c user.name="Ложкин Дмитрий" -c user.email="logo@lozhkin.net" commit -q -m "Сайт: $MSG"
  git push -q -f "$REMOTE" gh-pages
) || fail "Не удалось отправить gh-pages"

# 5. Настройки репозитория (повторный запуск безопасен)
if [ "$HAVE_GH" = 1 ]; then
  gh api -X POST "repos/$REPO/pages" -f "source[branch]=gh-pages" -f "source[path]=/" >/dev/null 2>&1 \
    || gh api -X PUT "repos/$REPO/pages" -f "source[branch]=gh-pages" -f "source[path]=/" >/dev/null 2>&1 \
    || true
  gh repo edit "$REPO" --homepage "$SITE" --description "$DESC" >/dev/null 2>&1 || true
  say "Pages и ссылка на сайт в описании репозитория — настроены"
elif [ -z "${KMBIT_REMOTE:-}" ]; then
  say "GitHub CLI не найден: один раз включите Pages (Settings → Pages → ветка gh-pages)"
  say "и укажите сайт $SITE в описании репозитория — или установите gh и запустите скрипт снова"
fi

printf '\033[1;32m✓ Готово.\033[0m Репозиторий: https://github.com/%s · сайт: %s\n' "$REPO" "$SITE"
pause
