# Tasks: Everon RTS

**Input**: spec.md, plan.md, research.md, data-model.md, contracts/ui.md
**Tests**: Требуются FR-008; Trident и игровой визуальный прогон.

## Phase 1: Setup

- [x] T001 Зафиксировать ветки main/develop/feature/release в CONTRIBUTING.md (FR-001).
- [x] T002 Подготовить собственный content/cw и копирование контента в apps/cwr/Game/CMakeLists.txt (FR-002, FR-007).

## Phase 2: Foundational

- [x] T003 Реализовать загрузку своих ресурсов в apps/cwr/Game/GameApplication.cpp с явной диагностикой (FR-002, FR-007).
- [x] T004 Описать и инициализировать единственное состояние в content/cw/Missions/CWEveron.eden/session.sqf (FR-003–006).

## Phase 3: User Story 1 — Everon (P1)

**Independent Test**: запуск миссии, 3D-штаб и панель одновременно, панорамирование и зум.
- [x] T005 [US1] Создать content/cw/Missions/CWEveron.eden/mission.sqm, description.ext, init.sqs и камеру (FR-002, FR-003).
- [x] T006 [US1] Создать миникарту и постоянную правую панель над 3D-миром в content/cw/ui/resources.cpp (FR-003, FR-004).
- [x] T007 [US1] Добавить scripts/run-cw.ps1 с параметром внешних данных и запуска среза (FR-002, SC-004).

## Phase 4: User Story 2 — Construction and infantry (P1)

**Independent Test**: построить казарму, произвести два юнита, проверить 1800 и приказ движения.
- [x] T008 [US2] Добавить проверку размещения, списание/отмену, одиночную казарму в content/cw/Missions/CWEveron.eden/session.sqf (FR-005).
- [x] T009 [US2] Добавить ограниченную очередь, таймеры, возврат при потере казармы и солдат в content/cw/Missions/CWEveron.eden/tick.sqs (FR-004, FR-006).
- [x] T010 [US2] Добавить выбор солдата и приказ движения в content/cw/Missions/CWEveron.eden/session.sqf (FR-006).
- [x] T011 [US2] Проверить команды и граничные случаи через tests/integration/cw/production.test.sqf и .toml (FR-008, SC-002).

## Phase 5: User Story 3 — C&W identity (P2)

**Independent Test**: главное меню, заставка, снимки при 720p/1080p.
- [x] T012 [P] [US3] Сгенерировать и сохранить оригинальный фон и provenance в content/cw/ui/ (FR-007).
- [x] T013 [US3] Добавить CWR_Main/CWR_Startup в content/cw/ui/resources.cpp и startup.sqs, подключить в engine/Poseidon/UI/OptionsUIApp.cpp и apps/cwr/Game/GameApplication.cpp (FR-007).
- [x] T014 [US3] Проверить кнопки и снимки через tests/integration/cw/interface.test.sqf и .toml (FR-004, FR-007, SC-003).

## Phase 6: Validation and polish

- [x] T015 Собрать Windows и прогнать lint/Trident, записать доказательства в specs/003-everon-rts-slice/verification.md (FR-008, SC-001–004).
- [ ] T016 Выполнить нативные macOS arm64 и x86_64 build/test/run и записать результаты в specs/003-everon-rts-slice/verification.md (FR-008).
- [x] T017 Провести converge по spec/plan/tasks и добавить выявленные пробелы в specs/003-everon-rts-slice/tasks.md (FR-008).

## Dependencies & Parallel Opportunities

T001–T004 -> US1 -> US2 -> итоговый прогон. US3 artwork T012 независим после утверждения spec; UI интеграция зависит от T003. US1 проверяется до производства, US2 до смены оформления. Работа в общих session.sqf/resources.cpp последовательна. Параллельный пример: T012 (фон) и T005 (миссия), после T003; проверки macOS независимы от Windows.

## Implementation Strategy

Сначала запускаемый 3D-мир и камера, затем производство и команды, затем оформление. Закрывать задачи только по доказательству; недоступные платформы оставлять открытыми. Первый срез требует US1+US2+US3; основная область всегда 3D согласно уточнению владельца; карта только в миникарте.

## Phase 7: Owner correction — native 3D RTS

- [x] T018 [US1] Add tested camera ray projection in engine/Poseidon/UI/Controls/RTSProjection.hpp and tests/unit/engine/Poseidon/UI/test_rts_projection.cpp (FR-009).
- [x] T019 [US1] Add native transparent engine/Poseidon/UI/Controls/RTSViewport.cpp/.hpp and register type102 in UI/Map/UIContainers.cpp and Core/resincl.hpp (FR-009).
- [x] T020 [US2] Route world clicks, right-click move/cancel, pan and zoom to mission-owned camera in content/cw/Missions/CWEveron.eden/session.sqf (FR-009, SC-005).
- [x] T021 [US3] Replace map mode with persistent 3D sidebar, minimap, tabs and two-column production cards in content/cw/ui/resources.cpp (FR-010).
- [x] T022 [US1] Correct Trident underlying mission readiness for user dialogs without weakening player/world/frame checks in engine/Poseidon/Game/Commands/GameStateExtTest.cpp; verify custom and normal mission paths (FR-008/009).
- [x] T023 [US3] Verify screenshots and real world input at 720p/1080p in tests/integration/cw/interface.test.sqf and specs/003-everon-rts-slice/verification.md (FR-009/010, SC-005).

- [x] T024 Исправить унаследованную потерю GameBool в engine/Poseidon/Game/Commands/GameStateExtTestGeneric.cpp с регрессионным тестом tests/unit/engine/Poseidon/Game/test_tri_generic_asserts.cpp (FR-008). Влияние: triAssert(true) ошибочно FAIL, triAssertEq(true,false) ошибочно OK; проверки среза не должны наследовать эту проблему.


- [x] T025 Запускать чистые RTS/boolean регрессии без игровых данных в .github/workflows/build.yml для каждого native preset и проверить локальный CTest regex (FR-008).

## Legacy follow-up outside first slice

- [ ] T026 Воспроизвести и исправить область EvalBreak у call/exitWith в engine/Evaluator/express.cpp с отдельной спецификацией и регрессионными тестами. Влияние: ранние возвраты внутри callback могут прервать вызывающее выражение. Текущий срез использует обычные условные выражения и не зависит от этого поведения.

## Phase 8: Convergence

Сверка 2026-10-27: 10 FR, 5 SC, 7 acceptance scenarios, 6 решений плана, 5 принципов конституции. Два missing-пробела: HIGH — нативные macOS-доказательства; MEDIUM — отдельное legacy-исправление. Contradicts/unrequested/partial: 0. Windows-реализация и доказательства перечислены в verification.md. Это не заявление о полной готовности всех платформ.

- [ ] T027 HIGH: Выполнить нативные configure/build/test/run на macOS arm64 и x86_64, проверить 3D-ввод и панель, сохранить команды/результаты в specs/003-everon-rts-slice/verification.md и закрыть T016 по доказательствам — FR-008, T016, Constitution IV (missing). Требуются соответствующие macOS-хосты; удалённый CI пока не запускался.
- [ ] T028 MEDIUM: Выполнить отдельный Spec Kit цикл для унаследованной области EvalBreak в engine/Evaluator/express.cpp, добавить минимальное воспроизведение вложенных call/exitWith и регрессию до исправления; связать результат с T026 — T026, Constitution III (missing). За пределами игрового среза; не расширять текущую миссию ради этой ошибки.

## Phase 9: Windows review corrections

- [x] T029 Добавить native objectPlacementClear в GameStateExtUi.cpp/GameStateExt.cpp и использовать геометрию кандидата в session.sqf; проверить пересечение края повёрнутого здания и неизменность баланса — FR-011, SC-006.
- [x] T030 Вынести RTS-регистрацию в общий метод GameApplication и вызвать в GameDemoApplication; проверить menu → Everon в обоих executable — FR-012, SC-006.
- [x] T031 Реализовать контекстный ЛКМ и повторные клики в session.sqf/RTSViewport.hpp, обновить подсказки; проверить выбор, смену выбора, движение и изоляцию панели через курсор/кнопки — FR-013, SC-006.
- [x] T032 Выполнить Windows build, целевые C++ и игровые регрессии, записать результаты и оставшиеся ограничения в verification.md; выполнить повторную сверку Spec Kit — FR-008/011–013, SC-006.

## Phase 10: CI failure repair

- [x] T033 Сохранить caller VCPKG_ROOT при импорте VS в scripts/windows-build.ps1; добавить реальный тест функции в tests/scripts/test_windows_build_environment.ps1 и проверку valid/invalid Prepare — FR-014, SC-007.
- [ ] T034 Добавить cmake/vcpkg-overlay-ports/enkits с минимальным type_traits patch и прежними upstream revision/hash/license; проверить применение и сборку на Windows, затем native CI — FR-015, SC-007.
- [x] T035 Выбрать xcrun Clang/SDK в .github/workflows/build.yml и docs/building.md, сохранить всю матрицу/проверки и загрузку диагностических журналов — FR-015, SC-007.
- [ ] T036 Выполнить локальные проверки, коммит и push в существующий PR develop, проверить новый GitHub run и записать реальные результаты/оставшиеся блокеры в verification.md — FR-008/014/015, SC-007.
- [x] T037 Восстановить отсутствующее в опубликованном GameApplication.cpp определение RegisterRTSModule, пересобрать Game/GameDemo из текущих исходников и повторить menu/menu_demo — FR-012, SC-006/007. Выявлено полной повторной сборкой после исправления CI bootstrap; предыдущий binary-прогон не доказывает собираемость коммита 0867ffc.
