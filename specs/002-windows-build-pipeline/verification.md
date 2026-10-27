# Verification: Windows build pipeline

Дата: 2026-10-27, Europe/Moscow. Host: Windows x64, 32 GiB RAM / 24 logical CPUs.
Рабочее дерево на базе ffc6183, с незакоммиченными изменениями этой подготовки.

## Инструменты и зависимости

- VS Build Tools 2022 17.14; MSVC 14.44.35207; Windows SDK 10.0.26100.0.
- Clang 19.1.5, CMake 3.31.6-msvc6, Ninja 1.12.1 из установленной VS.
- Ccache 4.14.2; Rust/Cargo 1.99.1 (rust-toolchain.toml).
- Vcpkg baseline 170bd3bfb152a1795b67b5c2190ab7d899fc9971; Cargo.lock не изменён.
- Vcpkg самостоятельно подготовил CMake 4.3.2 и вспомогательные инструменты
  в локальном build/downloads. Собраны 25 пакетов, сохранены 25 архивов binary cache.

## Нативные результаты

| Проверка | Результат | Доказательство |
| --- | --- | --- |
| SC-001: все C++ targets | Успех: 1088 шагов, включая 1057 компиляций | build/logs/windows-win-x64-clang-rwdi-20261027-200402.log |
| SC-001: cargo build --workspace --locked | Успех; отдельный первый Rust build 3m 51s | build/logs/windows-win-x64-clang-rwdi-20261027-202122.log |
| SC-002: Foundation CTest | 475 passed, 0 failed; 35.78 s | первый полный журнал; build/win-x64-clang-rwdi/Testing/Temporary/LastTest.log |
| SC-002: cargo test --workspace --locked | 202 passed, 0 failed, 0 ignored; doc-tests также успешны | первый полный журнал и windows-win-x64-clang-rwdi-20261027-202544.log |
| SC-003: первый успешный полный конвейер | 20:04:02–20:28:28, 24m 26s; exit 0 | windows-win-x64-clang-rwdi-20261027-200402.log |
| SC-003: повторный ./build.cmd | 20:29:06–20:29:54, 48s; exit 0 | windows-win-x64-clang-rwdi-20261027-202906.log |
| SC-003: переиспользование результатов | 0 компиляций C/C++ при повторе; vcpkg install 1.09 ms; Cargo build 0.53s; тесты повторно успешны | повторный полный журнал |
| SC-004: локальный и CI entrypoint | Windows job вызывает ./build.cmd, как README | .github/workflows/build.yml и docs/building.md |

Первый полный процесс был запущен через scripts/windows-build.ps1;
контрольный повтор — через тонкий build.cmd, вызывающий тот же script.
Независимые первые Rust build/test выполнены параллельно C++ для сокращения
времени первичной проверки; затем полный конвейер повторил их успешно.

## Отрицательные и конфигурационные проверки

- Явный LLVM_ROOT с пробелами и обнаружение через PATH успешно проверены CMake.
- Несуществующий LLVM_ROOT останавливает CMake и конвейер; fallback не маскирует ошибку.
- Недопустимый Jobs=0 возвращает ненулевой код; build.cmd передаёт параметры и код ошибки.
- Prepare успешно выполнен в Windows PowerShell 5.1 и PowerShell 7.
- YAML workflow разобран; сохранены три native jobs; Windows использует общий launcher.
- Spec Kit prerequisites, ссылки документов и git diff --check проверены.

## Результаты на диске

C++: dist/x64-win-rwdi/PoseidonGame.exe, PoseidonGameDemo.exe,
PoseidonServer.exe, PoseidonTools.exe, PoseidonStudio.exe, PoseidonTetris.exe,
PoseidonFormats.dll, плагины и PDB. OpenAL32.dll и его LICENSE скопированы.
Evaluator и тестовые executables также собраны в соответствующих build-подкаталогах.
Rust: target/debug/tri.exe, papa.exe, papa-bear-master-service.exe.

## Обнаруженные причины отказов и исправления

1. LLVM искался по одному абсолютному пути: добавлено LLVM_ROOT/PATH discovery.
2. Vcpkg очищал выбранный LLVM из окружения: добавлен tracked passthrough в triplets.
3. После первой установки Cargo каталог не попадал в PATH текущего процесса:
   исправлено добавление после установки.
4. В штатном Windows PowerShell скрипты запрещены по умолчанию: build.cmd
   использует RemoteSigned только для дочернего процесса, без изменения политики пользователя.
5. Native stdout/stderr могли не попадать в transcript: вывод направлен через host.

## Границы проверки

- MacOS build, игровой запуск с данными, полный CTest с графикой/данными,
  переносимый установщик, подпись и notarization не проверялись.
- GitHub Actions ещё не запускался удалённо; локально успешно выполнен тот же entrypoint.
- Существующее предупреждение Rust unused import Instant в Windows test-коде
  engine/Trident/src/client/instance.rs:415 не скрывалось. Vcpkg также предупреждает об отсутствии OpenAL PDB;
  на компиляцию и пройденные тесты это не повлияло.
- Ccache: 30 cacheable / 1057 calls; 1027 calls с PCH не кешируются стандартными
  безопасными настройками. Sloppiness не включалась. Быстрый повтор подтверждён
  прежде всего инкрементальным Ninja и готовыми пакетами vcpkg.

## Анализ и converge

Проверены FR-001–FR-008, SC-001–SC-004, оба пользовательских сценария,
решения плана и пять принципов конституции. Все требования покрыты задачами.
После реализации новых missing/partial/contradicts/unrequested пробелов в объёме
Windows feature не найдено. Итог converge: Converged.

## Попытка игрового запуска по запросу владельца

2026-10-27: запущен dist/x64-win-rwdi/PoseidonGame.exe.
Клиент инициализировал OpenGL и OpenAL Soft, затем завершился с кодом 1:
отсутствуют Fonts/cwr_title.ttf, cwr_body.ttf, cwr_mono.ttf, cwr_serif.ttf,
cwr_hand.ttf, также отсутствуют игровые текстуры/конфигурация.
В packages нет игровых данных; обнаруженный Steam-каталог ARMA Cold War Assault
содержит только Users, без ресурсов игры. Для продолжения нужен каталог данных
Remastered/Demo. Диагностика: build/logs/game-launch.stdout.log и game-launch.stderr.log.
Это не ошибка компиляции; успешный игровой запуск не подтверждён.

## Повторный игровой запуск с предоставленными ресурсами

2026-10-27, 20:46 Europe/Moscow: владелец предоставил каталог Steam-установки.
Ресурсы найдены в её подпапке Remastered. Наш dist/x64-win-rwdi/PoseidonGame.exe
запущен с -C и этим внешним каталогом; процесс 77640, окно Poseidon [GL33],
Responding=true. Инициализированы OpenGL 3.3, OpenAL Soft и FontSystem (5 fonts).
Фатальных ошибок запуска нет; игровой сеанс и миссии пока не проверялись.
В журнале есть предупреждение о текстуре biscamel/icamel2.paa.
Диагностика: build/logs/game-remastered.stdout.log и game-remastered.stderr.log.
Путь сохранён локально в игнорируемом .trident.env; ресурсы не копировались в Git.

Сеанс 20:46:53–20:47:23 завершился штатно: Shutdown begin (exit code 0), Shutdown complete.
