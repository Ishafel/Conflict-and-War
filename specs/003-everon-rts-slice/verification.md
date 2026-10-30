# Проверка первого среза Everon RTS

Дата: 2026-10-27. Ветка: `feature/003-everon-rts-slice`, от `develop`. Windows x64, Clang, preset `win-x64-clang-rwdi`. Ниже приведены результаты локальных проверок перед публикацией PR; удалённый CI на момент этих проверок ещё не запускался.

## Требования и доказательства

| Требование | Реализация / задачи | Проверка и результат |
|---|---|---|
| FR-001 | CONTRIBUTING.md; T001 | Созданы develop и feature от неё; описаны release/*, теги main и обратное слияние. Release без номера не создавался. |
| FR-002 | content/cw, CWRContent, run-cw.ps1; T002/003/005/007 | Нативный старт Everon из внешней установки, Trident menu → Everon PASS. Сторонние игровые данные не добавлены. |
| FR-003/009 | RTSViewport/RTSProjection, session.sqf; T004–006/018–020 | Настоящий 3D-мир, панорамирование, зум, Home, построение и выбор мировыми кликами; camera/interface PASS. Чистая проекция покрыта Catch2. |
| FR-004/010 | resources.cpp; T006/009/021/023 | Правая миникарта, кредиты, категории, две колонки, портреты, очередь и прогресс; interface PASS в 1280×720 и 1920×1080, снимки осмотрены. |
| FR-005 | session.sqf; T008/011 | Нельзя строить у штаба/слишком далеко/на занятой площадке, отмена бесплатна, повторная казарма отклоняется; production PASS, реальные клики interface PASS. |
| FR-006 | session.sqf/tick.sqs; T009–011/020 | Два солдата, выбор, фактическое перемещение, максимум пять заказов, возврат очереди при потере казармы, сброс сессии; production/interface PASS. |
| FR-007 | CWR_Main/CWR_Startup и оригинальные изображения; T012–014 | Menu/settings/direct launch PASS; запуск с заставкой PASS. Главное меню и игровые карточки осмотрены. Заставка исполнялась при запуске, отдельный её кадр не снят. Промпты и происхождение в content/cw/ui/ARTWORK.md. |
| FR-008 | T015/022/024/025 | Windows build, Foundation, целевые Catch2/CTest и Trident PASS. macOS остаётся непроверенной (T016). |
| SC-001/002 | T011/023 | Игровой интерфейс: казарма, два солдата и движение за 32.8–32.9 с; остаток 1800. Командный сценарий дополнительно проверяет отказы, очередь и возвраты. |
| SC-003/005 | T014/023 | Нативные снимки 720p/1080p одновременно показывают 3D-мир и панель. Клики миникарты изолированы, правый клик отменяет строительство/двигает солдата. |
| SC-004 | T007/015 | Воспроизводимый запуск описан в quickstart.md; путь к игровым данным задаётся аргументом. |

## Выполненные проверки

- `./build.cmd -Component Cpp -Stage Build -Jobs 3`: PASS. Последняя нативная сборка — `build/logs/windows-win-x64-clang-rwdi-20261027-215700.log`. После неё в C++ менялись только комментарии.
- `./build.cmd -Component Cpp -Stage Test -Jobs 3`: Foundation 475/475 PASS, 47.18 с (`build/logs/windows-win-x64-clang-rwdi-20261027-212959.log`).
- `PoseidonTests.exe '[rts],[generic-assert]'`: 24 случая, 102 проверки PASS. Отдельно тот же фильтр CTest, используемый в CI: 3/3 PASS. Это целевые регрессии, а не заявление о полном прогоне всех PoseidonTests.
- PoseidonTools: синтаксис UI ресурсов и bootable lint миссии PASS. YAML CI и синтаксис PowerShell launcher проверены.
- Trident production: 1/1 PASS, 31.2 с; `build/rts-production-final.log`.
- Trident interface 720p: 1/1 PASS, 32.8 с; `build/rts-interface-final.log`, кадры `build/rts-3d-720-final/interface/`.
- Trident interface 1080p: 1/1 PASS, 32.9 с; `build/rts-1080.log`, кадры `build/rts-3d-1080/interface/`.
- Trident camera: 1/1 PASS, 3.1 с; `build/rts-camera.log`. Ввод проверен с текущей русской раскладкой: используются физические клавиши.
- Trident menu: 1/1 PASS, 2.7 с; дополнительно запуск с заставкой 1/1 PASS, 4.8 с (`build/rts-splash.log`).
- Trident readiness обычной миссии Everon без RTS-диалога: 1/1 PASS, 2.0 с; `build/rts-readiness/`. Сохранены проверки готовности мира, игрока и кадров. Все игровые сценарии запускались со штатными strict/readiness, без повторов.

Артефакты build/ локальные и игнорируются Git. Прогон автоматически завершает свои процессы; окончательная демонстрация запускается отдельно без автоматического выхода.

## Границы доказательства и оставшиеся задачи

- Нативные macOS arm64/x86_64 build/test/run недоступны на этом Windows-хосте. T016 открыт; готовность macOS не заявляется. Удалённый CI не запускался.
- Две существующие проверки `camcreate_any_type` и `map_zoom` не смогли начать сценарий: установленный внешний набор данных не содержит мира Demo. Эти проверки не считаются пройденными; штатная готовность отдельно проверена на Everon.
- Унаследованный **АНТИПАТТЕРН: ложноположительные проверки boolean** в GameStateExtTestGeneric.cpp исправлен: раньше `triAssertEq(true,false)` мог вернуть успех. Добавлен тест различения true/false; экономика/UI проверены после исправления.
- Унаследованная ошибка области EvalBreak у call/exitWith отмечена T026 для отдельной спецификации. Срез использует обычные условные выражения; новую копию ошибки не добавляет.
- Это одиночная песочница: один штаб, одна казарма, пехота, конечные кредиты. Бой, добыча ресурсов, туман войны, сохранения и мультиплеер — последующие спецификации. После Windows-review проверяется геометрия здания (см. ниже); призрачный предпросмотр модели и полноценный анализ уклона остаются будущими задачами.
- Имена совместимости сохранены, LICENSE/CREDITS.md/THIRD_PARTY_NOTICES.md не менялись. Используются внешние классы зданий и солдат; собственная графика панели не является заменой их моделей.

## Windows review corrections — 2026-10-27

Эта секция дополняет исходный прогон и относится к FR-011–013, SC-006, T029–032.

| Замечание | Исправление | Игровое доказательство |
|---|---|---|
| P2: пересечение зданий | Вместо расстояния между центрами используется Landscape::ObjectCollision с геометрией временного кандидата Barracks. При отсутствии геометрии отказ; после проверки кандидат удаляется. Баланс меняется только при принятом строительстве. | placement.test: препятствие Barracks повёрнуто на 45°, центр в 13 м. Старый NearestObjectDistance возвращает null; геометрия отклоняет стройку, баланс 3000, здания в состоянии нет. После удаления препятствия строительство принимается за 1000. Logic без геометрии не принимается. |
| P2: Everon в demo | Единственный RegisterRTSModule вызывается Game и GameDemo. Остальные ограничения demo сохранены. | menu.test и menu_demo.test: обычное меню → настройки → возврат → Everon → рабочий 3D-диалог. |
| Выбор и приказ ЛКМ | ЛКМ по своему солдату выбирает его; ЛКМ по пустой земле двигает выбранного. ПКМ сохранён. Порог ближайшего юнита 4 м вместо 10 м, чтобы соседние солдаты различались. Двойной щелчок RTSViewport обрабатывается как очередной приказ. | mouse.test: курсор и состояние кнопки проходят штатное UI hit testing / polling без прямого вызова обработчика. Выбор первого солдата, приказ ЛКМ и фактическое смещение >5 м, выбор второго, нажатие панели без изменения цели и баланса. |

- Windows C++ build PASS: `build/logs/windows-win-x64-clang-rwdi-20261027-224910.log`, собраны Game и GameDemo.
- Целевые C++ регрессии: 24 теста / 102 проверки PASS после исправлений.
- Общий Trident прогон: **8/8 PASS**, 105.7 с, 1280×720, без повторов, штатные strict/readiness. Артефакты: `build/rts-review-suite/{camera,interface,menu,menu_demo,mouse,placement,production,readiness}/`.
- Повтор интерфейса и обычного ввода мыши в 1920×1080: **2/2 PASS**, 64.1 с; `build/rts-review-1080/{interface,mouse}/`. Снимки выбора и движения осмотрены.
- Дополнительные отдельные прогоны: production + menu_demo 2/2 PASS (34.0 с); mouse 1/1 PASS (31.7 с); placement 1/1 PASS (2.1 с). Первая попытка placement не нашла площадку из-за порядка подготовки самого теста: запрос старого радиуса выполнялся после создания/удаления временной модели. Исправлен порядок fixture, а не ослаблена проверка пересечения.
- PoseidonTools lint: миссия parseable, bootable=yes. Повторное копирование контента во время активного игрового прогона встретило занятые файлы; после завершения игр CWRContent PASS. Компиляция уже была успешной; ошибки копирования не подавлялись.
- Сверка Spec Kit: новые FR-011–013 и SC-006 покрыты T029–032 и тремя целевыми сценариями; изменения используют прежний стек, совместимые имена и внешние данные. Противоречий новым требованиям и новых пробелов в корректирующей фазе не найдено. Ранее открытые macOS и отдельный legacy EvalBreak остаются T016/T026–028; готовность macOS не заявляется.

## CI repair — 2026-10-28

FR-014/015, SC-007, T033–037. Исходный PR [run 40574368341](https://github.com/Ishafel/Conflict-and-War/actions/runs/40574368341) на 0867ffc завершился ошибками до компиляции проекта:

- Windows Prepare: `VCPKG_ROOT exists but is not a Git checkout`. Импорт VS окружения мог заменить явный checkout копией vcpkg из VS. Теперь сохраняется исходный VCPKG_ROOT, включая отсутствие; guard неправильного каталога не ослаблен.
- macOS arm64: pinned enkiTS TaskScheduler.cpp:1216 использует std::is_trivial без прямого type_traits include. Добавлен минимальный overlay patch, прежние revision/hash/version/install/license сохранены; меняется только port revision 3 → 4.
- macOS x64: OpenAL/CoreFoundation не компилировался с Homebrew LLVM 22.1.8 и Xcode 16.4 SDK. CI теперь выбирает xcrun Clang/SDKROOT вместе. Никакие ошибки/предупреждения не подавляются; Homebrew LLVM остаётся источником clang-format. Полная матрица и тесты сохранены, добавлена выгрузка журналов при ошибке.

Полная повторная локальная сборка выявила дополнительный дефект опубликованного 0867ffc: в GameApplication.cpp отсутствовало определение RegisterRTSModule при наличии вызова из GameDemo. Ранее записанный успешный binary-прогон demo не подтверждает собираемость того коммита. Определение и общий вызов восстановлены, новый прогон ниже выполнен после пересборки обеих версий.

Локальные результаты:

- `tests/scripts/test_windows_build_environment.ps1`: PASS — реальная функция импорта сохраняет явный/default VCPKG_ROOT и импортирует другие переменные, включая значения с `=`.
- Prepare с существующим каталогом без .git: ожидаемый FAIL с явной диагностикой, тест PASS (`build/ci-invalid-vcpkg-prepare.log`).
- `./build.cmd -Component Cpp -Stage Configure -Jobs 3`: PASS; overlay enkiTS успешно применён и скомпилирован для Windows Debug/Release. Лог `build/logs/windows-win-x64-clang-rwdi-20261028-192518.log`.
- `./build.cmd -Jobs 3`: полный C++/Rust build + tests **PASS**. Лог `build/logs/windows-win-x64-clang-rwdi-20261028-192734.log`. Первая попытка выявила отсутствующий метод demo и была исправлена; ошибка не скрывалась.
- После пересборки menu/menu_demo: **2/2 PASS**, 5.9 с (`build/ci-repair-menu/`). Целевые C++: **24 теста / 102 проверки PASS**.
- YAML и три платформы матрицы проверены; git diff --check PASS. Это не доказательство компиляции macOS. Нативные результаты нового GitHub run ещё ожидаются; игровые macOS-проверки остаются отдельной задачей.

Сверка Spec Kit: FR-014/015 и восстановление FR-012 покрыты планом и T033–037; новых требований без задач нет, стек/лицензии/внешние данные сохранены. Полная macOS-ready оценка остаётся открытой до нативных проверок.

## Follow-up native results and timing repair — 2026-10-28

Для 35f0346 [PR run 40726729161](https://github.com/Ishafel/Conflict-and-War/actions/runs/40726729161) подтвердил:

- **Windows: SUCCESS**, включая полный C++/Rust-конвейер, тест импорта окружения и целевые RTS/boolean регрессии. Первоначальный vcpkg bootstrap blocker устранён.
- **macOS Intel: configure + C++ build SUCCESS**; прежние ошибки enkiTS/OpenAL устранены. Foundation: 492/495 PASS, три отказа в test_potime.cpp:187/223/275. Измерения 100.204/56.584/86.677 мс превысили фиксированные сроки пробуждения, хотя ОС не гарантирует верхнюю границу задержки планирования. Последующие шаги RTS/Rust были штатно skipped после ошибки; они не считаются пройденными.
- **macOS ARM: infrastructure cancellation до старта**. Аннотация GitHub: `The job was not acquired by Runner of type hosted even after multiple attempts`; дополнительные notices сообщают о capacity constraints macOS arm64. Журнала компиляции нет; это не результат build/test. Задание и требование нативной проверки сохраняются.

Унаследованный **АНТИПАТТЕРН: проверка точности часов через абсолютный срок пробуждения потока** заменён независимым oracle в трёх воспроизведённо падающих функциональных тестах (FR-016, T038). Каждый getSystemTime вызов окружён before/after отсчётами steady_clock; измеренный интервал проверяется между внутренней/внешней границами. Допуск 1 мс относится к квантованию существующего ftime fallback, а не к нагрузке runner. Минимальные интервалы 5/40/1 мс сохранены. Это не увеличение старых 50/100 мс deadline.

Добавлены намеренная задержка сверх запрошенного sleep и отрицательные показания: остановившиеся часы, обратный ход, миллисекунды/наносекунды вместо микросекунд должны отвергаться. PoTime.cpp, CI filters, таймауты и политика повторов не изменены. Другие аппаратно-зависимые precision/performance пороги отмечены отдельной legacy-задачей T041; в этом native прогоне они прошли.

Локальная проверка исправления:

- Windows C++ build PASS: `build/logs/windows-win-x64-clang-rwdi-20261028-203526.log`.
- `PoseidonFoundationTests.exe '[potime]'`: **11 тестов / 49 проверок PASS**, включая обе новые регрессии.
- `./build.cmd -Component Cpp -Stage Test -Jobs 3`: **477/477 PASS**, 71.07 с, без повторов/исключений; `build/logs/windows-win-x64-clang-rwdi-20261028-203702.log`.
- git diff --check PASS. Повторная сверка spec/plan/tasks: FR-016/017 и SC-008 покрыты T038–040; ограничения стека и обязательной ARM-проверки соблюдены. Нативный результат изменённых timing-тестов macOS ожидает следующего GitHub run; macOS gameplay readiness по-прежнему не заявляется.

## Interactive RTS feedback — 2026-10-28

FR-018–022, SC-009, T042–047.

| Требование | Реализация | Доказательство |
|---|---|---|
| FR-018 | Render-only полупрозрачная модель казармы, общий validator, красный/зелёный цвет, очистка на панели/отмене/постройке/выходе. Кандидат не зарегистрирован в симуляции. | feedback: красное место отклоняется при балансе 3000; зелёное не списывает до клика; sidebar/ПКМ убирают preview; принятая казарма стоит 1000. Разница её положения с actual candidate origin <0.1 м. Кадры красного/зелёного preview осмотрены. |
| FR-019 | Экранные границы модели вместо попадания в землю; 6 px дополнительной зоны выбора. | Обычные cursor/button события выбирают точный юнит на высотах камеры 35 и 150 м, в 720p/1080p. |
| FR-020 | Рамка после 5 px перетаскивания, обратный drag, группа/кольца/приказ всем с интервалом 3 м. | Рамка выбирает двух солдат; оба реально проходят >3 м после приказа; sidebar сохраняет цель, reset очищает группу. Кадры рамки/двух колец/движения осмотрены. |
| FR-021 | Круговое раскрытие карточки по deadline, очередь и completion pulse/READY. | Сняты start/middle/ready строительства и start/middle/next-order найма. Доля прогресса растёт и сбрасывается <0.3 для следующего заказа; очередь и баланс 1800 проверены. |
| FR-022 | Неактивный HQ ONLINE удалён; рабочая камера-кнопка CENTER HQ сохранена. | В видимых текстах нет ONLINE; меню и камера-регрессия проходят. |

Проверки Windows:

- Native C++ build **PASS**; финальный лог `build/logs/windows-win-x64-clang-rwdi-20261028-234022.log`. Game и GameDemo собраны. Первое копирование контента было заблокировано открытым старым клиентом; после его закрытия штатная сборка прошла. Ошибки промежуточной компиляции исправлены без подавления диагностик.
- Целевые RTS/generic-assert/build-descriptor: **55 случаев / 232 проверки PASS**; отдельно Cloudlet depth: **2 / 24 PASS**. Фильтр CTest для CI расширен новыми drag/production/whole-object тестами и локально проходит **6/6** без игровых данных.
- Новый feedback.test отдельно: **1/1 PASS**, 35.9 с (`build/rts-feedback-final2-720/feedback/`).
- Весь набор игровых сценариев 1280×720: **9/9 PASS**, 155.8 с (`build/rts-feedback-suite/`).
- Финальная сборка: feedback/interface/camera 1920×1080 **3/3 PASS**, 85.5 с (`build/rts-feedback-1080/`). После 720p добавлены только очистка drag/preview при потере фокуса и сохранение приоритета cockpit/surface перед whole-object alpha; они включены в финальную сборку.
- PoseidonTools lint: parseable, bootable=yes. git diff --check PASS. Снимки настоящего 3D-мира, прозрачного ghost, фаз карточки и рамки осмотрены при обеих резолюциях. Игровые данные и снимки build/ не включаются в Git.

Промежуточные визуальные замечания устранены: непрозрачный tint заменён настоящим alpha blend; land-contact offset учтён общим кодом preview/commit. Экономика и единственный scheduler сохранены; состояние расширено до 18 документированных полей. Новая функциональность проверена на Windows; native macOS build/run этого изменения и внешняя ARM capacity остаются непроверенными.

Повторная сверка Spec Kit: FR-018–022/SC-009 покрыты T042–047, реализацией и проверками; новых пробелов в этой фазе нет. Открытые T016/T026–028/T040–041 относятся к ранее отмеченным платформенным/legacy работам и не выдаются за завершённые. LICENSE/CREDITS/THIRD_PARTY_NOTICES и стек сохранены.

## 2026-10-29 — C&C order and startup corrections (FR-023–026)

Spec Kit: existing spec/plan/tasks extended before changes; prerequisites resolve feature003; requirement checklist5/5 PASS, hooks absent. Analyze maps FR-023→T048/T052, FR-024/025→T049/T052, FR-026→T050/T051/T052, all→T053. Superseded acceptance/data-model order reconciled; no unresolved clarification or constitution conflict. Existing macOS gameplay/EvalBreak follow-ups remain explicit.

Latest prior CI40766209520 (a2a51c6): all3 native C++ builds compiled. macOS Foundation497/497 passed then Rust kill_on_drop failed because Linux-only/proc check reports no process on macOS. Windows Foundation476/477 passed, strict crash minidump creation failed0x800706F8; push40766200111 Windows succeeded. T040 timing fix is verified by these subsequent native timing results; new blockers are T050/051, no matrix bypass.

Native Windows new checks:
- C++ Build PASS, build/logs/windows-win-x64-clang-rwdi-20261029-215110.log; own content restaged successfully in20261029-220201.log.
- Foundation477/477 PASS42.23s, log20261029-215818. Strict crash context test1/1,15assertions PASS separately. An initial broad[crash] invocation also included the intentionally fatal hidden child and exited nonzero; the named parent regression and full CTest are the authoritative results.
- RTS unit6/6,36assertions PASS. Rust workspace5+9+1+13+69+7+98=202 tests PASS, log20261029-215305. Unix-only code is not executed on Windows; native macOS result remains pending. rustfmt is not installed in the pinned local toolchain; formatting was reviewed, not reported as a tool PASS.
- First feedback native run exited before harness due leading// unsupported by raw init.sqf Execute. Removed leading comment from expression-only init; comments remain in session/stub. Next feedback1/1 PASS33.7s, build/rts-order-feedback-fixed; screenshots show hidden observer, timer with no building, ready before preview, cancel/order retention, deployment, recruitment, exact picking, rectangle and movement.
- Initial nine-case suite6PASS/3FAIL165.6s: menu/menu_demo loaded stale staged init.sqs plus commented init.sqf; placement test's old10s wait cannot accommodate the new15s production. Restaged current source; placement assertion budget25s accommodates the required production (no timer change, retry or skip). Subsequent native results recorded below.

The Windows writer-thread change follows supported DbgHelp guidance and passes strict original-context checks locally. The CI-specific ERROR_INVALID_USER_BUFFER fix remains unconfirmed until new CI; do not treat a local PASS as proof of its remote cause. No tests are removed.

Final native results: targeted final720 feedback/menu/menu_demo/placement4/4 PASS57.7s, build/rts-order-final720. Together with unchanged camera/interface/mouse/production/readiness in the initial suite, all9 current scenarios passed; this is not a claim that the initial combined run passed. Feedback1080 1/1 PASS37.0s, build/rts-order-final1080; includes READY label still present after2s and correct debit/cancel/deploy/group behavior. First gameplay frame captured using --test-type screenshot --screenshot-delay1 at720p and1080p; native image inspection shows the commander camera/sidebar, no first-person body. This is a deliberately exiting validation launch, separate from the live client reopened after publication.
Converge: FR-023–025 implemented and Windows checks PASS; FR-026 local Windows PASS but new native macOS and CI-specific dump outcome remain to be inspected. Remaining macOS gameplay and evaluator legacy tasks already exist; no duplicate convergence tasks.

## Camera-border correction after owner screenshot (FR-027/028, SC-012)

The earlier first-frame images proved the elevated camera but visibly contained black margins. They did not prove a correct full play area; that visual defect was missed in review. Owner screenshot exposed it. AspectSettings world rectangle is full; the CinemaBorder overlay was re-enabled by DisplayMission after synchronous init had disabled it. Default now resets in InitVehicles before callbacks; late overwrite removed. Explicit cutscene border calls remain.

Spec Kit requirement quality5/5, Analyze: FR-027→T054/T056, FR-028→T055/T056, no new unmapped requirement or constitution violation. No image generation needed for a lifecycle correction.

Windows native build PASS20261029-221937; final staging PASS build/rts-border-stage-final.log. Initial build caught wrong global/namespace declaration and ambiguous RString enum overload; both corrected before verification.
- RTS unit6/6,36assertions PASS.
- border720 feedback/readiness2PASS, menu2FAIL: forceEnd alone never changes EndMode. Added validated standard endMission via existing EndMode mapping.
- Next menu2FAIL: automation intentionally exits process at mission completion. Normal interactive menu tests use no_autotest with --strict, retaining fatal script/engine errors; all other tests keep automation. That exposed a debriefing screen; sandbox description now sets debriefing=0 to meet direct MENU navigation.
- Final native menu/menu_demo2/2 PASS6.0s, build/rts-border-menu-final, verifies menu→Everon→menu in both executables with border=false. Ordinary authored mission retains border=true (readiness test).
- Attempt to stage while a test still held resource files failed explicitly; staging succeeded after test completion, no copy error suppressed.
- Screenshot build/rts-border720/feedback/000_first_rts_view.png inspected: terrain reaches play-area edges with sidebar unchanged, observer hidden.

Final1080 feedback/camera/interface3/3 PASS73.1s, build/rts-border1080. First gameplay-frame720p/1080p captured with --screenshot-delay1 and inspected: full terrain up to the play-area edges, no cinematic mask. No further economic/input changes after these tests. Converge: FR-027/028 satisfied on native Windows; existing macOS runtime follow-up remains.

## Player-facing presentation pass — 2026-10-29 (FR-029–032, SC-013)

Spec Kit existing feature extended through spec/plan/tasks before behavior; prerequisites resolve003, quality checklist5/5 PASS, extension hooks absent. Analyze maps FR-029→T057/T061, FR-030→T059/T061, FR-031→T058/T061, FR-032→T059/T060/T061 and all→T062. Camera and visual research consolidated in plan/research. Stack, licensing, compatibility names and external game-data policy remain intact.

Presentation: existing licensed title/body/mono font families now have separate roles. Native sidebar is76%/24% with coherent graphite/brass palette, larger portrait, active categories, locked infantry, contextual requirements/selection/status and useful lower panel instead of8 black placeholders. Main menu/startup use original generated island art. Assets menu-v2/barracks-v2/infantry-v2 PNG/PAA and complete built-in imagegen prompts in content/cw/ui/ARTWORK.md; runtime conversion PoseidonTools image convert --format DXT1. No C&C/game assets copied into source or CI.

Visual iteration: initial cwrTitle/cwrMono labels were too condensed/small; reserve display face for large branding and mono for amounts. CStatic multi-line copy used to show focus rectangles: opt-in ST_NO_RECT removes them. Existing CButton ignored local palettes and used shared wrapper colours; explicit flatStyle uses local palette/hover/focus/disabled state, with legacy branch preserved. Native settings/menu round trip verifies old controls remain functional. No global font tuning or theme mutation.

Camera:55m/0.58 FOV,30–150m zoom, height-scaled speed, exponential integrated acceleration and wheel response, normalized diagonal movement and exact axis stop.8 RTS unit cases/52assertions PASS on final build, including30/60/144FPS travel and reset. CI CTest regex includes the two new camera cases.

Native Windows evidence:
- C++ full build PASS20261029-224111; flat-button refinement full build PASS20261029-224808; final camera reset build PASS20261029-225855.
- Initial presentation7201/1 PASS3.3s after correcting test expectation for triGetControlVisible's scalar0 (not a GameBool). Initial menu/feedback2/2 PASS46.7s.
- First ten-case development suite9PASS/1FAIL190.6s: Home expected55 but remaining wheel tail reached54.4922. Pointer-leave reset alone does not cover programmatic/keyboard activation of CENTER HQ. Added explicit state[19] reset epoch and cameraResetToken callback, resetting before input consumption; state has20 fields. No loosened assertion, retry or skip.
- Final stable720 complete suite10/10 PASS182.4s, build/rts-polish-stable720. Runtime source was stable throughout this final run.
- Final1080 menu/presentation/feedback/camera4/4 PASS52.8s, build/rts-polish-final1080. After720 suite only capture framing/wait changed for the in-engine startup-resource preview and developed-base overview; gameplay assertions retained. Native screenshots of empty base, production, READY, green/red ghost, near/far selection, rectangle/groups, locked/available infantry, menu and startup preview inspected.
- Final RTS unit8/8,52assertions PASS; git diff --check PASS.

Prior commit3397a4e Windows push and PR CI both SUCCESS when inspected; macOS jobs still running. These are prior native build results, not proof of the unpushed presentation changes or macOS gameplay. Current macOS gameplay remains T016/T027.
Converge: presentation requirements implemented and verified on Windows; no new unbuilt runtime work found. Existing macOS gameplay/evaluator follow-ups remain explicit.

Final startup-resource preview7201/1 PASS4.2s after waiting for fade-in; native720/1080 images inspected at full opacity. FR-010 wording reconciled with FR-030 presentation pass (portrait plus contextual information replaces placeholder card grid). No runtime changes after stable720/1080 checks.

## Compact sidebar and minimap follow — 2026-10-30 (FR-033–035, SC-014)

Owner correction replaces permanent context/selection column with hover-only descriptions and compact production cards. Spec Kit spec/plan/tasks prepared before runtime changes; prerequisites resolve003 and extension hooks are absent. Analyze: FR-033/034→T063/T065, FR-035→T064/T065; three requirements and SC-014 have implementation and native checks. Existing technology, licensing and external-data policy retained.

Disabled cards are intentionally describable through visible bounds, without enabling their actions. Tick owns popup visibility/copy and clears it on pointer leave/category change; no Base Command controls remain. Opt-in keepAspect fits original portrait aspect in physical pixels; legacy pictures keep their default rendering. Minimap Center/GetCenter uses the actual camera ground target; sync clears pending map animation and runs on camera updates/dialog open/Tick. Mission state remains20 fields.

Windows native evidence:
- C++ full build PASS20261030-065120, final native build PASS20261030-065611, final content staging PASS20261030-070304.
- Complete720p suite10/10 PASS178.9s, build/rts-compact-final720, no retries. Includes camera, physical selection/group movement, placement, production, menus and demo.
- Final1080p camera/feedback/presentation3/3 PASS47.2s, build/rts-compact-final1080. Native hover enter/leave, locked and producing cards covered; disabled clicks retain credit/queue checks.
- Additional final presentation720p1/1 PASS4.6s (build/rts-compact-hover720),1024x7681/1 PASS4.5s (build/rts-compact-final43). These add producing-hover assertions after the complete720p suite; runtime source unchanged.
- RTS units8/8,52assertions PASS, build/rts-compact-unit.log.
- Native screenshots inspected at720p/1080p/4:3: compact_base, barracks_hover, locked_infantry_hover;1080p minimap_after_pan inspected. Images preserve proportions; description fits beside sidebar and disappears off-card. Camera regression compares map center with target within0.1m initially, after pan and Home, and verifies pan changed the map center.
- git diff --check PASS. No new macOS native build/run performed in this Windows session.

Converge: three correction requirements, SC-014 and both implementation decisions satisfied on Windows; no new missing/contradicting/unrequested implementation. Existing macOS and legacy evaluator/performance follow-ups remain T016/T026–028/T041; no duplicate tasks appended. Publication uses the existing feature PR into develop; no merge.
