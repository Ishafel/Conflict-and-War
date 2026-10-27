# GitHub Spec Kit в Conflict & War

Используется официальный [GitHub Spec Kit](https://github.com/github/spec-kit) 1.2.3,
интеграция `codex`. Правила проекта — в
[конституции](../../.specify/memory/constitution.md), штатные шаблоны — в
`.specify/templates/`, навыки агента — в `.agents/skills/speckit-*/`.
Собственные SDD-шаблоны удалены.

## Короткая памятка

В чате агента из этого проекта выполняйте шаги по одному, просматривая результат:

1. `$speckit-specify <что нужно сделать и зачем>` — описать требование.
2. `$speckit-clarify` — уточнить неоднозначности, если они есть.
3. `$speckit-plan Сохрани текущий стек и соблюдай конституцию` — подготовить план.
4. `$speckit-tasks` — разбить план на задачи.
5. `$speckit-analyze` — проверить согласованность документов.
6. `$speckit-implement` — выполнить задачи.
7. `$speckit-converge` — проверить результат и оставшиеся пробелы.

Это команды **чата**, а не терминала. При оставшихся задачах повторите реализацию
и проверку. Для изменения правил используйте `$speckit-constitution`;
сохранение стека и запрет антипаттернов уже закреплены.
Если навыки не появились сразу, заново откройте проект/начните новый чат в нём.

Артефакты функций хранятся в `specs/<номер>-<название>/`. Текущая подготовка:
[001-project-foundation](../../specs/001-project-foundation/spec.md).
Локальный указатель `.specify/feature.json` создаётся Spec Kit и не хранится в Git.
Чтобы продолжить существующую функцию после клонирования, укажите агенту
`SPECIFY_FEATURE_DIRECTORY=specs/001-project-foundation` перед шагом plan/tasks.

## CLI на другом компьютере

Нужны Python >= 3.11 на PATH и Specify CLI:
`pipx install specify-cli==1.2.3` либо `uv tool install specify-cli==1.2.3`.
Проверки из корня репозитория: `specify version`, `specify integration status`.
После клонирования повторный `init --force` не требуется.
Локальная установка этой рабочей копии: `build/spec-kit-env/Scripts/specify.exe`.

Официальные инструкции: [установка](https://github.github.io/spec-kit/installation.html),
[процесс](https://github.github.io/spec-kit/quickstart.html).
