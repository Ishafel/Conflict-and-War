# Проверка 001

Дата: 2026-10-27. Окружение: Windows x64, локальное рабочее дерево.
Статус спецификации: **In progress** до подтверждения нативных сборок.

| Критерий | Проверка | Результат |
| --- | --- | --- |
| SC-001 | README, CONTRIBUTING, AGENTS, политика, ADR и шаблон | Добавлены; имя и правила согласованы |
| SC-002 | CMake 4.4.4 `--list-presets=all` | Успех; Windows presets и ссылки build/test читаются |
| SC-002 | Изолированная копия presets с разрешением Darwin-конфигураций на тестовом host | CMake прочитал шесть macOS presets; это проверка схемы, не macOS сборка |
| SC-002 | Сопоставление configure/build/test | Все 3 Windows и 6 macOS конфигураций покрыты |
| SC-002 | RunClangFormat/RunClangTidy через CMake с тестовой командой | Для обоих скриптов проверены check/fix, два пути с пробелами, остановка и ненулевой результат при ошибке инструмента, отказ без SOURCE_LIST |
| SC-002 | JSON, YAML workflow и ссылки локальной документации | Проверены отдельно от компиляции |
| SC-003 | `cmake --preset win-x64-clang-rwdi` | Остановлен: VCPKG_ROOT не задан, vcpkg и Ninja не установлены; компиляторы недоступны |
| SC-003 | Windows C++/Rust build/test | Не выполнены: нет Clang/SDK окружения, Ninja, ccache, vcpkg, Rust/Cargo |
| SC-003 | macOS arm64 и Intel C++/Rust build/test | Не выполнены: нет macOS host; добавлена нативная CI-матрица |
| SC-004 | docs/building.md | Инструменты, baseline, команды, выходные каталоги и границы проверки описаны |

## Ограничения и следующие шаги

- Запустить workflow на GitHub и сохранить фактические результаты всех трёх jobs.
  CI ещё не запускался; файл workflow сам по себе не доказывает готовность порта.
- На Windows установить инструменты и VS SDK, задать VCPKG_ROOT по инструкции.
  Для проверки конфигурации CMake установлен только в игнорируемый `build/_tools`.
- Проверить полный набор C++ тестов, игровой запуск и загрузку runtime DLL/dylib
  на каждой платформе при наличии данных; CI выполняет только Foundation и Rust tests.
- Проверка переносимой дистрибуции, подпись и notarization требуют отдельной задачи.
- Унаследованные жёсткий путь LLVM в Windows toolchain и глобальные подавления
  предупреждений зарегистрированы как долг в документации; новые случаи не добавлены.
- Автоматическая проверка безопасности отклонила публикацию binaries как Actions
  artifacts из-за неподтверждённого места хранения. Шаг исключён; итоговый workflow
  выполняет сборку и тесты без загрузки артефактов.

## Миграция на GitHub Spec Kit — 2026-10-27

- Официальный Specify CLI 1.2.3 установлен локально в build/spec-kit-env.
- Выполнен `specify init --here --force --non-interactive --integration codex --script py --ignore-agent-tools`.
  Проверка исполняемого файла агента пропущена, поскольку агент работает в приложении;
  шаблоны, навыки и штатные скрипты установлены полностью.
- `specify integration upgrade codex` с Python на PATH штатно перегенерировал
  навыки с переносимой командой `python`, устранив абсолютный путь разработчика.
- `specify integration status --json`: status=ok; missing_managed_files=0,
  modified_managed_files=0, invalid_manifest_paths=0.
- Штатный resolve_template.py успешно разрешил constitution/spec/plan/tasks templates.
- Штатный check_prerequisites.py --json --require-spec --require-tasks --include-tasks
  нашёл specs/001-project-foundation и связанные документы.
- Конституция 1.0.0 заполнена без неопределённых placeholders; правила исходной
  задачи сохранены. Spec/plan/tasks перенесены в штатные разделы Spec Kit;
  собственные файлы specs/_template удалены.
- Проверены ссылки документации, идентификаторы задач и требований,
  отсутствие путей локального компьютера в навыках. git diff --check проходит.
- Короткая памятка добавлена в README.md и docs/sdd/README.md.
- Нативная компиляция не выполнялась при миграции: SC-003/T012 остаются открытыми.

## Обновление Windows — 2026-10-27

В функции [002](../002-windows-build-pipeline/verification.md) Windows x64
полностью собран: C++ targets и Rust workspace; 475 Foundation + 202 Rust tests
успешны. Повторная сборка с тестами — 48s, без новой компиляции C/C++.
Старые записи выше описывают первоначальное окружение до обнаружения VS tools.
MacOS arm64/x64 остаются непроверенными; общий SC-003/T012 спецификации 001 открыт.
