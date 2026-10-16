<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="brandbook_assets/logo_grad_white.svg">
    <img src="brandbook_assets/logo_grad_black.svg" alt="КМ БИТ" width="420">
  </picture>
</p>

<p align="center">
  <b>Фирменный стиль «КМ БИТ»</b><br>
  знак · логотипы · руководство по фирменному стилю · версия для ИИ
</p>

<p align="center">
  <a href="https://fuzzze.github.io/kmbit/"><b>Сайт</b></a> ·
  <a href="https://fuzzze.github.io/kmbit/KMBit_brandbook.zip">Скачать архив</a> ·
  <a href="KMBit_brandbook.pdf">Брендбук PDF</a> ·
  <a href="KMBit_brandbook_AI.md">Брендбук для ИИ</a>
</p>

---

## Что внутри

| Файл | Назначение |
|---|---|
| [`KMBit_brandbook.pdf`](KMBit_brandbook.pdf) | Руководство по фирменному стилю, 21 страница, A4 горизонтально |
| [`KMBit_brandbook_AI.md`](KMBit_brandbook_AI.md) | То же руководство в виде инструкций для ИИ-агентов: правила MUST / MUST NOT, токены, дерево выбора логотипа, чек-лист |
| [`KMBit_recursion.html`](KMBit_recursion.html) | Демо «рекурсивности логотипа»: градиентный элемент разворачивается в новый логотип при прокрутке ([смотреть](https://fuzzze.github.io/kmbit/KMBit_recursion.html)) |
| [`KMBit_brandbook.zip`](KMBit_brandbook.zip) | Всё содержимое одним архивом; имя постоянное, при обновлении архив перезаписывается |
| `kmbit_logo_ru.svg` | Горизонтальный логотип, полноцветный, с градиентным элементом — **исходник** |
| `kmbit_logo_sign.svg` | Знак, полноцветный — **исходник** |
| `kmbit_logo_fill.svg` | Знак, монохромный, с просветами — **исходник** |
| `kmbit_logo_line.svg` | Знак, контурный — **исходник** |
| [`brandbook_assets/`](brandbook_assets) | Производные версии: горизонтальная, вертикальная, шрифтовой логотип, знак — в полноцветном, монохромном и контурном вариантах, для светлого и тёмного фона |

## Коротко о стиле

**Знак** — монограмма из совмещённых букв «К» и «М», собранная из шести плоскостей.
**Логотип** — знак и надпись «КМ БИТ» (PT Sans Bold, в кривых) с гармонизирующим градиентным элементом. Надпись с элементом может использоваться отдельно, как шрифтовой логотип.

| | Цвет | HEX |
|---|---|---|
| ![](https://placehold.co/16x16/507AFF/507AFF.png) | Синий КМ | `#507AFF` |
| ![](https://placehold.co/16x16/5BFFCD/5BFFCD.png) | Мятный | `#5BFFCD` |
| ![](https://placehold.co/16x16/53A3F0/53A3F0.png) | Голубой | `#53A3F0` |
| ![](https://placehold.co/16x16/0B1233/0B1233.png) | Глубокий | `#0B1233` |
| ![](https://placehold.co/16x16/111522/111522.png) | Графит | `#111522` |
| ![](https://placehold.co/16x16/2F55E0/2F55E0.png) | Синий тёмный | `#2F55E0` |

Градиент: `linear-gradient(35deg, #507AFF 0%, #53A3F0 43%, #5BFFCD 100%)`.
Шрифты: **PT Sans** — основной, **JetBrains Mono** — акцентный.
Модуль X — ширина вертикального штриха знака; безопасное поле — не меньше X.

Полные правила — в [PDF](KMBit_brandbook.pdf) и в [версии для ИИ](KMBit_brandbook_AI.md).

## Для ИИ-агентов

Передайте агенту файл [`KMBit_brandbook_AI.md`](KMBit_brandbook_AI.md) целиком — как системную инструкцию или как вложение. Логотипы агент должен брать из этого репозитория, а не рисовать сам.

Прямая ссылка на сырой файл:
`https://raw.githubusercontent.com/fuzzze/kmbit/main/KMBit_brandbook_AI.md`

## Публикация обновлений

Репозиторий — это папка проекта как есть. Обновление выкладывается одним действием:

1. Положите новые файлы в папку проекта (поверх старых).
2. Дважды щёлкните `publish.command` (или выполните `./publish.command "что изменилось"` в терминале).

Скрипт пересобирает `KMBit_brandbook.zip`, делает коммит в `main`, обновляет сайт в ветке `gh-pages` и при первом запуске включает GitHub Pages и прописывает ссылку на сайт в описании репозитория. Нужны `git` и (для первого запуска) [GitHub CLI](https://cli.github.com) с выполненным `gh auth login`.

## Автор

Знак, логотип и руководство — **Ложкин Дмитрий** · [lozhkin.net](https://lozhkin.net) · [logo@lozhkin.net](mailto:logo@lozhkin.net)

Права на знак и логотип принадлежат их владельцу. Используйте материалы в соответствии с руководством по фирменному стилю.
