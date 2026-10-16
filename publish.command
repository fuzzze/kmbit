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
# большие файлы по HTTPS: без этого GitHub отвечает «RPC failed; HTTP 400»
git config http.postBuffer 524288000
git config http.version HTTP/1.1
git config user.name  >/dev/null || git config user.name  "Ложкин Дмитрий"
git config user.email >/dev/null || git config user.email "logo@lozhkin.net"

[ -f .gitignore ] || printf '.DS_Store\n**/.DS_Store\n' > .gitignore

# 2. Архив с постоянным именем
say "Собираю $ZIP"
rm -f "$ZIP"
zip -qr -X "$ZIP" . \
  -x '.git/*' '.gitignore' '*.DS_Store' "$ZIP" 'publish.command' 'site/*' 'README.md' '.nojekyll'

# 3. Коммит в main (содержимое папки всегда побеждает)
git add -A
if git diff --cached --quiet; then
  say "Изменений в файлах нет"
else
  git commit -q -m "$MSG"
  say "Коммит: $MSG"
fi
push_main() { git push origin main 2>&1; }
if ! OUT="$(push_main)"; then
  if printf '%s' "$OUT" | grep -qE 'rejected|fetch first|non-fast-forward'; then
    say "На GitHub есть более новые коммиты — кладу содержимое папки поверх"
    git fetch -q origin main
    git reset -q --soft origin/main
    git diff --cached --quiet || git commit -q -m "$MSG"
    OUT="$(push_main)" || { printf '%s\n' "$OUT"; fail "Не удалось отправить main"; }
  else
    printf '%s\n' "$OUT"; fail "Не удалось отправить main"
  fi
fi
say "main отправлен"

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
  git -c http.postBuffer=524288000 -c http.version=HTTP/1.1 push -q -f "$REMOTE" gh-pages
) || fail "Не удалось отправить gh-pages"

# 5. Настройки репозитория (повторный запуск безопасен)
#    Pages переключается на «Deploy from a branch → gh-pages / (root)», даже если раньше
#    сайт публиковался иначе (GitHub Actions, ветка main и т. п.)
if [ "$HAVE_GH" = 1 ]; then
  if ! gh api "repos/$REPO/pages" >/dev/null 2>&1; then
    gh api -X POST "repos/$REPO/pages" -f build_type=legacy -f "source[branch]=gh-pages" -f "source[path]=/" >/dev/null \
      || fail "Не удалось включить GitHub Pages"
  else
    gh api -X PUT "repos/$REPO/pages" -f build_type=legacy -f "source[branch]=gh-pages" -f "source[path]=/" >/dev/null \
      || fail "Не удалось переключить GitHub Pages на ветку gh-pages"
  fi
  gh api -X POST "repos/$REPO/pages/builds" >/dev/null 2>&1 || true   # пересобрать сайт сразу
  SRC="$(gh api "repos/$REPO/pages" --jq '.build_type + " · " + .source.branch + .source.path' 2>/dev/null || echo '?')"
  say "Pages: $SRC"
  gh repo edit "$REPO" --homepage "$SITE" --description "$DESC" >/dev/null 2>&1 \
    && say "Ссылка на сайт в описании репозитория — прописана" \
    || say "Не удалось обновить описание репозитория (проверьте права gh)"
elif [ -z "${KMBIT_REMOTE:-}" ]; then
  say "GitHub CLI (gh) не найден или не авторизован — настройки репозитория пропущены."
  say "Один раз: Settings → Pages → Source: Deploy from a branch → gh-pages / (root),"
  say "и укажите $SITE в поле Website (шестерёнка в блоке About)."
  say "Или: brew install gh && gh auth login — и запустите скрипт снова."
fi

printf '\033[1;32m✓ Готово.\033[0m Репозиторий: https://github.com/%s · сайт: %s\n' "$REPO" "$SITE"
pause
