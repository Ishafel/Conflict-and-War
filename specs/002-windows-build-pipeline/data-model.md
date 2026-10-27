# Data Model: состояние сборки

- Toolchain: обнаруженные VS installation, LLVM root и версии tools.
- Dependencies: baseline vcpkg и неизменённый Cargo.lock; пути кешей и downloads.
- BuildRun: preset, component/stage, jobs, журнал и код завершения.

Состояния: discover → prepare → configure → build → test → success.
Любая ошибка переводит запуск в failed с ненулевым кодом; следующий запуск
повторяет необходимые этапы, сохраняя уже готовые загрузки и артефакты.
При изменённом внешнем checkout не выполнять reset/clean.
