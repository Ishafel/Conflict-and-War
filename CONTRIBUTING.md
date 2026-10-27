# Разработка Conflict & War — C&W

Это самостоятельный модифицированный форк. Ограничения locked upstream
относятся к исходному репозиторию Bohemia Interactive.

## Порядок изменений

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
