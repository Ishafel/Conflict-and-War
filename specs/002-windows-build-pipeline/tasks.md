# Tasks: Повторяемая Windows-сборка C&W

**Input**: spec.md, plan.md, research.md, data-model.md, quickstart.md.
**Tests**: нативная полная сборка, базовые тесты и повторный запуск обязательны.

## Phase 1: Setup

- [x] T001 Исследовать установленные tools/SDK и сохранить решения в specs/002-windows-build-pipeline/research.md.
- [x] T002 Подготовить штатные Spec Kit spec/plan/checklists в specs/002-windows-build-pipeline/.

## Phase 2: Foundational

- [x] T003 Исправить обнаружение LLVM_ROOT/PATH в cmake/FindLLVMSanitizer.cmake и передачу переменной в cmake/vcpkg-triplets/x64-windows-clang*.cmake (FR-003).
- [x] T004 Добавить обнаружение VS/SDK и импорт окружения в scripts/windows-build.ps1; launcher build.cmd (FR-002, FR-003).

## Phase 3: User Story 1 — Первая сборка (Priority: P1)

**Independent Test**: полный build и базовые тесты на текущем Windows x64 host.

- [x] T005 [US1] Добавить локальную подготовку ccache/Rust и pinned vcpkg в scripts/windows-build.ps1; закрепить Rust в rust-toolchain.toml (FR-004).
- [x] T006 [US1] Добавить configure/build/test, строгие ошибки и журналы в scripts/windows-build.ps1 (FR-001, FR-005, FR-006).
- [x] T007 [US1] Выполнить конвейер и устранить подтверждённые ошибки компиляции, записать результаты в specs/002-windows-build-pipeline/verification.md (SC-001, SC-002).

## Phase 4: User Story 2 — Повторная сборка (Priority: P2)

**Independent Test**: второй запуск использует сохранённые tools/dependencies и проходит.

- [x] T008 [US2] Настроить повторное использование downloads/vcpkg/ccache в scripts/windows-build.ps1 (FR-004).
- [x] T009 [US2] Подключить тот же entrypoint к Windows job в .github/workflows/build.yml, сохранить macOS шаги (FR-007, FR-008).
- [x] T010 [US2] Обновить README.md и docs/building.md: одна команда, параметры, кеши, результаты и диагностика (SC-004).
- [x] T011 [US2] Повторить конвейер и записать результат в specs/002-windows-build-pipeline/verification.md (SC-003).

## Phase 5: Polish & Cross-Cutting Concerns

- [x] T012 Проверить конвейер на отрицательных сценариях, согласованность spec/plan/tasks и выполнить converge (FR-005, SC-001–SC-004).

## Dependencies & Execution Order

T001–T002 → T003–T004 → T005–T006 → T007.
T008 основывается на T005; T009/T010 могут выполняться независимо после T006.
T011 выполняется после T007/T008; T012 завершает проверку.

## Parallel Opportunities

US1: исследование внешних требований может идти отдельно от написания документов.
US2: README/docs и CI затрагивают разные файлы и могут проверяться независимо.
Саму сборку и изменение её окружения выполнять последовательно.

## Implementation Strategy

Сначала рабочий локальный Windows build, затем повторный запуск и тот же путь в CI.
Нативные результаты macOS здесь не подменяются проверкой конфигурации.
