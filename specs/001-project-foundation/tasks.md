# Tasks: Основа Conflict & War

**Input**: `specs/001-project-foundation/spec.md` и `plan.md`.

**Tests**: обязательны проверки конфигурации и нативные build/test по SC-001–SC-005.
**Organization**: задачи сгруппированы по пользовательским историям Spec Kit.

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Сохранить существующие материалы перед миграцией в build/spec-kit-before-init.zip.
- [x] T002 Инициализировать официальный Spec Kit 1.2.3: .specify/ и .agents/skills/.

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T003 Закрепить правила C&W в .specify/memory/constitution.md (FR-001–FR-004).
- [x] T004 Сохранить стек и совместимость в docs/adr/0001-preserve-stack.md и docs/engineering.md.

## Phase 3: User Story 1 - Разработка по GitHub Spec Kit (Priority: P1)

**Independent Test**: specify integration status и check_prerequisites без ошибок (SC-001).

- [x] T005 [US1] Удалить файлы specs/_template/ и перенести spec.md/plan.md/tasks.md в штатный формат.
- [x] T006 [US1] Добавить памятку в README.md и docs/sdd/README.md; согласовать AGENTS.md и CONTRIBUTING.md (FR-003, FR-007).
- [x] T007 [US1] Штатно перегенерировать .agents/skills/ без абсолютного Python-пути.
- [x] T008 [US1] Проверить manifests, штатные scripts/templates, документы и записать результат в verification.md (SC-001).

## Phase 4: User Story 2 - Нативная сборка Windows и macOS (Priority: P1)

**Independent Test**: два нативных build/test по docs/building.md (SC-003).

- [x] T009 [US2] Настроить build/test пары в cmake/presets/windows.json и cmake/presets/macos.json (FR-005, SC-002).
- [x] T010 [US2] Подготовить переносимые cmake/RunClangFormat.cmake и cmake/RunClangTidy.cmake и проверить обработку ошибок (SC-002).
- [x] T011 [US2] Добавить .github/workflows/build.yml и docs/building.md (FR-006, SC-004).
- [x] T012 [US2] Выполнить Windows x64 и macOS arm64 C++/Rust build/test; сохранить результаты в verification.md (SC-003). Windows x64 подтверждена; 2026-10-31 нативная macOS arm64: все C++ targets/Rust workspace, 496 Foundation и 205 Rust tests PASS. Intel исключена из приёмки владельцем 2026-10-31; см. verification.md.

## Phase 5: Owner platform scope correction — 2026-10-31

- [x] T013 [US2] Согласовать конституцию, AGENTS.md, README, docs/building.md и активные spec/plan/tasks: Intel-проверка необязательна и не блокирует приёмку (FR-008, SC-005).
- [x] T014 [US2] Удалить Intel job из .github/workflows/build.yml, проверить YAML-матрицу, сохранность Windows/ARM тестовых шагов и Intel presets; записать результат в verification.md (FR-008, SC-005).

## Dependencies & Execution Order

Setup → Foundational → US1; существующие результаты US2 сохраняются при миграции.
T008 выполняется после T005–T007. T012 требует нативных ОС/SDK и не считается
закрытой после проверки JSON. Непроверенная компиляция не блокирует готовность
интеграции Spec Kit, но блокирует завершение всей подготовки сборки.

## Implementation Strategy

Завершить миграцию US1, проверить штатные инструменты и памятку.
Для US2 использовать подготовленную CI-матрицу и закрывать T012 только по факту.
