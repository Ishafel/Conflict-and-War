# Сборка Conflict & War

Обязательные цели: Windows x64 и macOS arm64 (Apple Silicon).
Собирать нативно на соответствующей ОС и архитектуре. Windows x64 сборка и тесты подтверждены в [отчёте](../specs/002-windows-build-pipeline/verification.md).
Нативная macOS arm64 сборка, Foundation/Rust tests и игровой прогон Everon подтверждены
в [отчёте сборки](../specs/001-project-foundation/verification.md#нативная-macos-arm64--2026-10-31)
и [отчёте игрового прогона](../specs/003-everon-rts-slice/verification.md).
Проверка macOS x86_64 (Intel) исключена из обязательной приёмки и CI решением
владельца от 2026-10-31 из-за отсутствия доступного хоста. Intel presets сохранены
для необязательного использования; это не подтверждает работоспособность Intel.

## Инструменты

- Git и Git LFS (`git lfs install`, затем `git lfs pull` для тестовых fixtures).
- CMake >= 3.25, Ninja, ccache; `clang-format` обязателен для конфигурации,
  `clang-tidy` опционален.
- Clang/LLVM; на Windows дополнительно Visual Studio 2022 Build Tools:
  Desktop development with C++, MSVC x64 и Windows SDK. Сборка использует clang-cl,
  а библиотеки и SDK — из VS. LLVM обнаруживается через LLVM_ROOT или PATH; Windows-сценарий
  также находит LLVM из Visual Studio.
- Rust/Cargo версии из rust-toolchain.toml; зависимости закреплены в Cargo.lock.
- vcpkg на baseline из vcpkg.json. Первая конфигурация скачивает и компилирует зависимости.

Не подменять отсутствующий инструмент отключением проверок. Сборочные каталоги
и локальные зависимости должны оставаться в `build/` либо вне репозитория.

## Windows: одна команда

Установленный Visual Studio 2022 / Build Tools должен содержать Desktop development
with C++, Windows SDK, C++ Clang tools и CMake tools. Также нужен Git.
Открывать специальный Developer Prompt больше не требуется:

```powershell
./build.cmd
```

build.cmd выбирает PowerShell 7 или штатный Windows PowerShell и разрешает
локальный скрипт только для этого процесса (RemoteSigned), без изменения
пользовательской политики. Сценарий сам находит Visual Studio через vswhere, активирует x64 SDK/MSVC,
использует имеющиеся LLVM/CMake/Ninja, подготавливает ccache и локальный Rust,
проверяет baseline vcpkg, собирает все C++ targets и Rust workspace и запускает
Foundation CTest и Rust tests. Версия Rust закреплена в rust-toolchain.toml;
Cargo.lock и baseline из vcpkg.json сохраняются.

Повторный запуск — та же команда. Инструменты находятся в build/windows-tools,
vcpkg — в build/vcpkg, загрузки — в build/downloads, binary cache — в
build/vcpkg-cache, compiler cache — в build/ccache. Каталоги сохраняются между
запусками и исключены из Git. Сценарий не меняет системный PATH и не удаляет кеши.
Первый запуск требует сеть и существенно дольше повторного. На проверенной машине
успешный первый конвейер занял 24m 26s, повторный с тестами — 48s.
PCH-компиляции используют инкрементальный Ninja; стандартный ccache кеширует
не все такие вызовы. Небезопасные послабления кеширования не включены.

Полезные варианты:

```powershell
./build.cmd -Component Cpp           # C++ build + Foundation tests
./build.cmd -Component Rust          # Rust build + tests
./build.cmd -Stage Prepare           # только подготовка окружения/tools
./build.cmd -Stage Configure         # подготовка и CMake configure
./build.cmd -Stage Build -Jobs 2      # после configure, только build
./build.cmd -Stage Test              # после build, только tests
./build.cmd -Preset win-x64-clang-dbg # отдельная Debug-сборка
```

При ошибке сценарий возвращает код 1 и путь журнала build/logs/windows-*.log.
По журналу видно последний этап и оригинальную ошибку компилятора/теста.
Исправьте причину и повторите ту же команду. Для нехватки памяти уменьшите -Jobs.
Для нового preset сначала выполните All или Configure; Build/Test предполагают
уже настроенный/собранный каталог.

Внешние LLVM_ROOT, VCPKG_ROOT и настройки кешей поддерживаются.
Явный неверный LLVM_ROOT считается ошибкой. Внешний VCPKG_ROOT должен быть
на baseline из vcpkg.json; сценарий не выполняет reset/clean или автоматическое
переключение существующего checkout. Это защищает локальные изменения.
Импорт окружения Visual Studio сохраняет заданный VCPKG_ROOT; встроенная копия
vcpkg из VS не заменяет зафиксированный checkout проекта.
При обновлении baseline сначала явно подготовьте соответствующий checkout
либо выберите новый каталог VCPKG_ROOT.

Для ручных команд CMake/Cargo нужны активированное окружение разработчика,
те же tools на PATH и VCPKG_ROOT; основной поддерживаемый путь — сценарий выше.

## macOS

Установить Xcode Command Line Tools (`xcode-select --install`), Rust stable,
Git LFS и инструменты через Homebrew:

```sh
brew install cmake ninja ccache clang-format git-lfs pkgconf autoconf automake libtool
export PATH="$(brew --prefix)/bin:$PATH"
export CC="$(xcrun --find clang)"
export CXX="$(xcrun --find clang++)"
export SDKROOT="$(xcrun --show-sdk-path)"
git lfs install
git lfs pull

git clone https://github.com/microsoft/vcpkg.git build/vcpkg
baseline=$(sed -n 's/.*"builtin-baseline": "\([^"]*\)".*/\1/p' vcpkg.json)
git -C build/vcpkg checkout "$baseline"
./build/vcpkg/bootstrap-vcpkg.sh -disableMetrics
export VCPKG_ROOT="$PWD/build/vcpkg"

# Обязательная macOS-платформа: Apple Silicon.
cmake --preset macos-arm64-clang-rwdi
cmake --build --preset macos-arm64-clang-rwdi --parallel 3
ctest --preset macos-arm64-clang-rwdi
cargo build --workspace --locked
cargo test --workspace --locked
```

При ошибке остановиться и устранить её до следующего шага. Debug presets называются
`macos-arm64-clang` / `macos-x64-clang`, Release — с суффиксом `-rel`.

На macOS проект и зависимости используют Clang из активного Xcode, согласованный
с его SDK. Отдельный пакет Homebrew clang-format предоставляет форматтер. Это исключает случайную
подмену SDK-компилятора новой основной версией Homebrew LLVM. Baseline vcpkg
не меняется; overlay enkiTS явно подключает type_traits, используемый upstream.
Intel presets с заменой arm64 на x64 доступны для необязательных прогонов;
они не входят в текущую приёмку. Universal binary пока не создаётся.

## Результаты и проверки

| Конфигурация | Каталог компиляции | Скопированные C++ binaries |
| --- | --- | --- |
| Windows RelWithDebInfo | build/win-x64-clang-rwdi | dist/x64-win-rwdi |
| macOS ARM RelWithDebInfo | build/macos-arm64-clang-rwdi | dist/arm64-macos-rwdi |
| macOS Intel RelWithDebInfo | build/macos-x64-clang-rwdi | dist/x64-macos-rwdi |

Rust workspace помещает binaries в `target/debug/`; `cargo build --workspace --locked --release`
использует `target/release/`. Внутренние имена PoseidonGame/PoseidonServer/tri сохраняются.
`dist/` — результат существующего копирования целей, а не проверенный переносимый установщик.
Компиляция сама по себе не проверяет разрешение DLL/dylib на другом компьютере.

Test presets намеренно запускают только `PoseidonFoundationTests` без игровых данных;
отсутствие тестов считается ошибкой. Полный список: `ctest --test-dir build/<preset> -N`.
Полный CTest: `ctest --test-dir build/<preset> --output-on-failure`;
требования данных и Trident описаны в [tests/README.md](../tests/README.md).
Игровой запуск с лицензированными данными, графикой, звуком, сервером и клиентом
проверяется отдельно на каждой платформе. Игровые данные не загружаются в CI.

Проверка форматирования: `cmake --build --preset <preset> --target Format`;
анализ при наличии clang-tidy: цель `Tidy`. Эти проверки могут обнаружить старый
технический долг; не скрывать его глобальным отключением предупреждений.

## CI

[Workflow](../.github/workflows/build.yml) вызывает на Windows ту же build.cmd → scripts/windows-build.ps1.
На macOS сохраняются отдельные configure, все C++ targets,
Foundation CTest, сборку и тесты Rust workspace. Нативные runners: Windows 2022,
macOS 15 arm64; соответствие меток проверено по
[официальному списку GitHub](https://github.com/actions/runner-images).
Workflow не публикует binaries и не выполняет деплой. Запуск произойдёт после
попадания изменения в GitHub либо через `workflow_dispatch`; локальное добавление
файла не означает успешный CI.
