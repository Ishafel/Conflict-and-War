# Проверка 001

Дата: 2026-10-27. Окружение: Windows x64, локальное рабочее дерево.
Статус спецификации: **Implemented** для обязательных Windows x64/macOS arm64
по уточнённому объёму от 2026-10-31. Первоначальные результаты сохранены ниже;
актуальные подтверждения и решение по Intel — в дополнениях в конце отчёта.

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

## Нативная macOS arm64 — 2026-10-31

Проверка FR-005, SC-003 и T012: Apple M4 Max (arm64), macOS 27.0.1,
Xcode 27.1 / AppleClang 21.0.0, CMake 4.4.5, Ninja 1.13.2,
Rust 1.99.1. Исходный commit: `984d375`.
Baseline vcpkg и Cargo.lock сохранены. Исправлений исходников для сборки не потребовалось.

| Проверка | Результат |
| --- | --- |
| `cmake --preset macos-arm64-clang-rwdi` | PASS; зависимости manifest собраны нативно |
| `cmake --build --preset macos-arm64-clang-rwdi --parallel 3` | PASS; все C++ targets, 1087 шагов; журнал `build/cpp-build-macos.log` |
| `ctest --preset macos-arm64-clang-rwdi` | PASS, 496/496; журнал `build/foundation-tests-macos.log` |
| `cargo build --workspace --locked` | PASS; весь Rust workspace |
| `cargo test --workspace --locked` | PASS, 205 тестов, без падений и пропусков; журнал `build/rust-tests-macos.log` |
| `file dist/arm64-macos-rwdi/PoseidonGame` | Mach-O 64-bit executable arm64 |
| Клиент с внешними ресурсами, оконный режим 1280×720 | PASS: OpenGL 4.1 Apple M4 Max, конфигурация и ресурсы C&W загружены; главное меню осмотрено по нативному снимку `build/macos-menu.png`; контрольный запуск завершился с кодом 0 |

Для этого окружения дополнительно понадобились pkgconf и autotools; список
инструментов в docs/building.md обновлён (SC-004). Полный LLVM не требуется:
используются Xcode Clang и отдельный clang-format. Rust установлен в локальные
`build/rustup` и `build/cargo`; настройки окружения сохранены в игнорируемом
`build/macos-env.sh`, для повторных команд в этой рабочей копии:

```sh
source build/macos-env.sh
cmake --build --preset macos-arm64-clang-rwdi --parallel 3
ctest --preset macos-arm64-clang-rwdi
cargo test --workspace --locked

# CW_DATA_DIR задаётся пользователем и указывает на внешнюю установку с Worlds/BIN/DTA.
POSEIDON_USER_DIR="$PWD/build/macos-user" \
  ./dist/arm64-macos-rwdi/PoseidonGame -C "$CW_DATA_DIR" \
  --window --width 1280 --height 720
```

Первый Foundation-прогон внутри песочницы дал 6 ошибок создания пользовательских
каталогов macOS; повторён вне песочницы без изменения тестов, все 496 прошли.
Загрузки vcpkg/Cargo также потребовали сетевого доступа вне песочницы.
Линкер сообщил о повторяющихся библиотеках; при запуске были предупреждения
об отсутствии GL_ARB_clip_control и текстуры `biscamel/icamel2.paa` во внешних данных.
Они не помешали отображению главного меню; отсутствие расширения снижает точность глубины.

Полный CTest, игровой сценарий Everon, фактическое воспроизведение звука,
сетевая игра, перенос на другой Mac, подпись и notarization не проверялись.
Intel macOS в этом прогоне не собиралась; с решением владельца от 2026-10-31
её проверка исключена из обязательной приёмки. T012/SC-003 закрыты по
подтверждённым Windows x64 и macOS arm64 build/test.
Сторонние игровые данные оставлены во внешней установке.

## Решение владельца: Intel вне обязательной проверки — 2026-10-31

FR-008 / SC-005 / T013–T014: владелец исключил проверку macOS Intel из-за
отсутствия доступного хоста. Конституция 2.0.0 сохраняет обязательные
Windows x64 и macOS arm64; Intel presets остаются необязательными.
Это изменение объёма платформ, а не успешная Intel-проверка.
T012/SC-003 закрыты по существующим нативным результатам Windows и ARM.

Из .github/workflows/build.yml удалён только Intel entry. Проверка через Ruby YAML
подтвердила точную матрицу Windows x64/macOS arm64, равенство всех steps до и
после изменения и отсутствие иных изменений workflow. Через JSON проверено
сохранение всех Intel configure/build/test presets Debug/RelWithDebInfo/Release.
Активные spec/plan/tasks, AGENTS.md, README и docs/building.md согласованы.
`git diff --check` PASS. Нативную сборку для изменения только матрицы и
документации повторно не запускали; новый удалённый CI оценивается отдельно.
Игровые T016/T027 функции 003 остаются открытыми для arm64.
