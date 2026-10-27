# Data Model: артефакты разработки

Изменений runtime-моделей или схем БД нет.

- `.specify/memory/constitution.md`: принципы, версия, даты; общий файл в Git.
- `specs/001-project-foundation/`: spec, plan, tasks и доказательства этой функции.
- `.specify/feature.json`: локальный `feature_directory` относительно корня;
  указатель на текущую функцию, исключённый из Git штатным .specify/.gitignore.
- `.specify/integration.json` и manifests: версия и штатные файлы установки;
  обновляются Specify CLI, а не вручную.
