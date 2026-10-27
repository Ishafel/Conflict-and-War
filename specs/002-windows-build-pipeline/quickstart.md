# Quickstart: Windows build pipeline

Из обычного PowerShell в корне проекта:

```powershell
./build.cmd
```

Требуется установленный VS 2022 C++ Build Tools с Windows SDK и Git.
Команда обнаруживает tools, подготавливает зависимости, собирает C++/Rust
и выполняет базовые тесты. Повторить ту же команду для инкрементальной разработки.
Выходные C++ binaries: dist/x64-win-rwdi; Rust: target/debug.
Журналы: build/logs. Детали: [docs/building.md](../../docs/building.md).

Валидация: оба последовательных запуска заканчиваются кодом 0;
неизменённые зависимости при втором запуске повторно не собираются.
