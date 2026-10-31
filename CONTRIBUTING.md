# Разработка Conflict & War — C&W

Это самостоятельный модифицированный форк. Ограничения locked upstream
относятся к исходному репозиторию Bohemia Interactive.

## Ветки и выпуски (FR-001)

`main` хранит проверенные выпуски с тегами `vX.Y.Z`. Интеграция разработки —
в `develop`. Функции начинаются от `develop` в `feature/<номер>-<имя>` и
возвращаются туда через ревью. Для стабилизации выпуска создаётся
`release/<версия>` от `develop`: только исправления и подготовка выпуска.
Проверенный release сливается в `main` и обратно в `develop`, затем ставится тег.
Исправления выпущенной версии — `hotfix/*` от `main`, с возвратом в `develop`
и активную release-ветку. Ветки не заменяют проверки сборки, тестов и запуска.
Release-ветка создаётся при подготовке конкретного выпуска, а не заранее.

По завершении работы зафиксировать изменения коммитом и открыть PR из feature-ветки
в `develop`. В PR указать требования, выполненные проверки и оставшиеся ограничения.

## Порядок работы

1. Прочитать [AGENTS.md](AGENTS.md) и [политику разработки](docs/engineering.md).
2. Использовать [GitHub Spec Kit](docs/sdd/README.md): спецификация, план, задачи,
   анализ согласованности, реализация и converge по штатным навыкам агента.
3. Сохранить стек и совместимость; архитектурное решение записать в ADR.
4. Реализовать требования без новых антипаттернов. При попытке их применения
   явно указать `АНТИПАТТЕРН: <название>`, риск и исправление.
5. Выполнить проверки по [руководству сборки](docs/building.md), указать результаты
   и непроверенные платформы в verification.md. PR связывает требования и проверки.

Для сообщения об ошибке нужны ОС/архитектура, ревизия, preset, шаги воспроизведения,
ожидаемый и фактический результат. Не включать секреты или сторонние игровые данные.

## Licensing Of Contributions

The project source is licensed under the GNU General Public License v3.0 or
later, with additional Section 7 terms in `LICENSE`.

When working with forks or modified versions:

- source changes are governed by the same GPL-3.0-or-later terms, including
  the Section 7 additional terms,
- you do not grant or imply any right to use "ARMA" or any other Bohemia Interactive trademarks,
- modified versions must be marked as modified and must not be presented as the
  original program.
