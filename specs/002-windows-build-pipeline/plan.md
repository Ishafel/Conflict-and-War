# Implementation Plan: Повторяемая Windows-сборка

**Branch**: текущая рабочая ветка | **Date**: 2026-10-27 | **Spec**: [spec.md](spec.md)
**Input**: specs/002-windows-build-pipeline/spec.md.

## Summary

Добавить scripts/windows-build.ps1 для подготовки, configure/build/test C++/Rust.
Повторно использовать VS Build Tools через vswhere и импорт VsDevCmd, включая
поставляемые LLVM/CMake/Ninja. Недостающие ccache и Rust устанавливать локально.
Зависимости vcpkg привязать к baseline, сохранять downloads и binary cache.

## Technical Context

**Language/Version**: существующие C++20/C11, Rust; PowerShell >= 5.1.
**Primary Dependencies**: VS 2022 C++ Build Tools/SDK, LLVM clang-cl, CMake >=3.25,
Ninja, ccache, Git/LFS, vcpkg baseline из manifest, Rust/Cargo.
**Storage**: игнорируемые build/windows-tools, build/downloads, build/vcpkg-cache,
build/<preset>, target; журналы build/logs.
**Testing**: весь C++ build; Foundation CTest; cargo build/test --workspace --locked;
два запуска конвейера и отрицательные проверки аргументов/обнаружения LLVM.
**Target Platform**: Windows x64; общие CMake helpers сохраняют macOS/Linux.
**Project Type**: инструментарий сборки существующего native приложения.
**Performance Goals**: неизменённые tools/dependencies не скачиваются повторно.
**Constraints**: без смены стека и удаления кешей/чужих checkout; ошибки фатальны.
**Scale/Scope**: локальная Windows машина и тот же entrypoint для Windows CI.

## Constitution Check

I: spec/plan/tasks создаются штатными средствами Spec Kit.
II: стек, baseline и Cargo.lock сохранены.
III: убрать hardcoded LLVM path; строгие коды завершения; не подавлять ошибки тестов.
IV: Windows проверяется нативно; macOS здесь остаётся непроверенной.
V: внутренние цели и лицензии сохраняются.
До и после проектирования нарушений не найдено.

## Project Structure

### Documentation (this feature)

```text
specs/002-windows-build-pipeline/
  spec.md, plan.md, tasks.md, research.md, data-model.md, quickstart.md
  checklists/requirements.md
  verification.md
```

### Source Code (repository root)

```text
build.cmd                         # shell launcher, per-process RemoteSigned
scripts/windows-build.ps1          # pipeline
cmake/FindLLVMSanitizer.cmake       # portable LLVM discovery
cmake/vcpkg-triplets/              # tracked LLVM_ROOT propagation into vcpkg
rust-toolchain.toml                # pinned Rust toolchain
.github/workflows/build.yml        # Windows entrypoint; retain macOS jobs
README.md, docs/building.md         # one-command instructions
build/                            # ignored tools, caches, build outputs/logs
```

**Structure Decision**: один entrypoint поверх существующих presets;
без нового package manager или собственной системы компиляции.

## Complexity Tracking

Новых архитектурных слоёв нет. Системные VS/SDK используются повторно,
недостающие tools устанавливаются только в build/. Внешний VCPKG_ROOT не сбрасывается.

## Verification

SC-001: полный C++/Rust build; SC-002: Foundation и Rust tests.
SC-003: повторить тот же конвейер; SC-004: проверить документацию и Windows CI.
Ошибки портирования, обнаруженные реальной сборкой, исправлять узко в том же
объёме с фиксацией причины. Проект остаётся In progress до успешных проверок.
