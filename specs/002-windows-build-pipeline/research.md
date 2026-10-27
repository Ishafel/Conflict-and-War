# Research: Windows build pipeline

## Решение: повторно использовать VS Build Tools

Обнаружены VS 2022 17.14, MSVC 14.44, Windows SDK 10.0.26100,
Clang 19.1.5, CMake 3.31 и Ninja. Они отсутствуют на обычном PATH.
Vswhere + импорт VsDevCmd позволяют использовать их из обычного PowerShell.
Альтернатива — повторная установка: не нужна и создаёт конфликтующие копии.

## Решение: LLVM_ROOT/PATH вместо hardcoded LLVM

CMake helper должен принимать явно заданный LLVM_ROOT, затем искать clang-cl
на PATH и в стандартных каталогах установки. Архитектура проверяется;
ошибка явного LLVM_ROOT не маскируется fallback-компилятором.
Это также сохраняет поиск sanitizer runtime относительно выбранного LLVM.

## Решение: локальные tools/cache и pinned зависимости

Ccache берётся из официального релиза; Rust toolchain устанавливается rustup
локально без изменения пользовательского PATH. Rust 1.99.1 закреплён в rust-toolchain.toml; ccache 4.14.2 — в entrypoint.
Фактические версии остальных tools фиксируются в журнале. vcpkg checkout соответствует manifest baseline; Cargo использует --locked.
Повторный запуск использует имеющиеся каталоги. Первичная сеть нужна для загрузок.
Альтернатива — ручная установка или полная пересборка каждый раз — усложняет разработку.

## Решение: один конвейер для локальной среды и CI

Windows job вызывает scripts/windows-build.ps1. macOS шаги сохраняются.
Журналы локальны; upload/deploy в эту задачу не входят.

## Уточнение после первого configure

Vcpkg очищает окружение дочерних процессов: PATH и LLVM_ROOT терялись
при определении компилятора target triplet. Добавлен VCPKG_ENV_PASSTHROUGH
для LLVM_ROOT в Windows clang triplets. Переменная учитывается в ABI,
поэтому выбор LLVM не приводит к повторному использованию несовместимых пакетов.

## Уточнение: штатный Windows PowerShell

На текущей машине Windows PowerShell 5.1 имеет стандартную Restricted policy.
Тонкий build.cmd запускает доступный PowerShell с per-process RemoteSigned,
без изменения политики пользователя. Проверка Prepare прошла и в PowerShell 5.1.
Вся логика остаётся в одном scripts/windows-build.ps1; CI вызывает тот же launcher.
