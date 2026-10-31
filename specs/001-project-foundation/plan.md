# Implementation Plan: Основа Conflict & War

**Branch**: существующая рабочая ветка | **Date**: 2026-10-27 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-project-foundation/spec.md`.

## Summary

Использовать официальный Spec Kit 1.2.3 с интеграцией codex и Python-скриптами.
Перенести существующие правила в конституцию, а материалы подготовки — в
штатные spec/plan/tasks. Сохранить C++/Rust стек и уже подготовленную матрицу сборки.

## Technical Context

**Language/Version**: C++20/C11, Rust stable; Python >= 3.11 только для Spec Kit.

**Primary Dependencies**: CMake >= 3.25, Ninja, Clang, ccache, vcpkg;
SDL3/OpenGL 3.3/OpenAL/ImGui, Catch2, Trident; Specify CLI 1.2.3.

**Storage**: текстовые артефакты в Git; локальная feature.json игнорируется.

**Testing**: specify integration status, штатный check_prerequisites,
resolve_template, CMake presets, Foundation CTest, cargo build/test --locked.

**Target Platform**: Windows x64 и macOS arm64; Intel presets необязательны.

**Project Type**: существующая игра, движок и сервисы; подготовка инструментария.

**Performance Goals**: runtime и его производительность в этой задаче не меняются.

**Constraints**: без смены стека, новых антипаттернов и публикации binaries;
не отмечать непроверенные нативные сборки успешными.

**Scale/Scope**: единая интеграция Spec Kit, одна существующая функция, две CI jobs.

## Constitution Check

- I: штатные шаблоны/навыки установлены; собственный specs/_template удалён.
- II: стек приложения, vcpkg baseline и Cargo.lock не изменяются.
- III: локальный абсолютный Python-путь устранён штатной перегенерацией;
  ошибки инструментов возвращаются вызывающему процессу.
- IV: Windows x64/macOS arm64 нативно проверены; конфигурационная проверка и игровой запуск отделены. Intel-проверка необязательна по конституции 2.0.0.
- V: имя C&W закреплено; цели и авторские уведомления сохранены.

Проверка перед и после миграции: нарушений конституции в решении нет.
SC-003 подтверждён для Windows x64 и macOS arm64; Intel исключена из приёмки
решением владельца от 2026-10-31 и конституцией 2.0.0.

## Project Structure

### Documentation (this feature)

```text
specs/001-project-foundation/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── tasks.md
└── verification.md
```

### Source Code (repository root)

```text
.specify/                 # official templates, scripts, constitution, manifests
.agents/skills/speckit-*/  # official agent skills
cmake/                    # existing presets and portable format/tidy commands
.github/workflows/        # native Windows/macOS build matrix
apps/, engine/, mserver/  # existing application stack
README.md, AGENTS.md, CONTRIBUTING.md, docs/
```

**Structure Decision**: Стандартный layout Spec Kit поверх существующего проекта.
verification.md сохранён как доказательства прошлых проверок, не как отдельный процесс.
HTTP/API-контракты не добавляются: внешнее поведение сервисов здесь не меняется.

## Complexity Tracking

Нарушений конституции и новых архитектурных слоёв нет.

## Verification

SC-001: integration status, prerequisite check, соответствие spec/plan/tasks,
наличие памятки и отсутствие собственных шаблонов.
SC-002: чтение presets и проверки помощников CMake из verification.md.
SC-003: нативные Windows x64 и macOS arm64 build/test подтверждены в verification.md.
SC-004: ссылки и команды в docs/building.md и docs/sdd/README.md.
SC-005: удалить только Intel entry из .github/workflows/build.yml; сохранить
Windows/ARM jobs и их тесты, Intel presets и toolchains. Согласовать AGENTS.md,
README, docs/building.md и активные spec/plan/tasks. Проверить YAML-матрицу,
наличие Intel presets и отсутствие изменений тестовых шагов; нативную сборку
при изменении только матрицы и документации не повторять.
