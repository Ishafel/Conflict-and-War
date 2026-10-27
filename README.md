# Conflict & War — C&W

**Conflict & War** (сокращённо **C&W**) на текущем этапе разрабатывается как
глубокая модификация Arma: Cold War Assault — Remastered на основе опубликованного кода.
Он не является официальным продуктом Bohemia Interactive.

Разработка ведётся по **SDD с GitHub Spec Kit**:
[памятка по использованию](docs/sdd/README.md), [обязательные правила](AGENTS.md),
[политика стека и антипаттернов](docs/engineering.md).
Стек сохраняется; его замена требует доказанного технического тупика и решения владельца.
Новые антипаттерны запрещены; попытки явно помечаются `АНТИПАТТЕРН: <название>`.

Сборка: [Windows x64 и macOS arm64/x64](docs/building.md).
Имена внутренних целей `Poseidon*` пока сохранены для совместимости.

> **Как пользоваться Spec Kit:** в чате проекта выполните по очереди
> `$speckit-specify <задача>` → `$speckit-plan` → `$speckit-tasks` →
> `$speckit-analyze` → `$speckit-implement` → `$speckit-converge`.
> При неясностях используйте `$speckit-clarify`. Проверяйте результат каждого шага;
> это команды чата, а не терминала. [Короткая памятка](docs/sdd/README.md).

## Upstream source and provenance

This repository holds the engine and game source code (codename *Poseidon*) behind *Arma: Cold War Assault* — the game first released in 2001 as *Operation Flashpoint: Cold War Crisis*. That release launched Bohemia Interactive and began the technology lineage that later grew into Real Virtuality, Arma, and Enfusion. The code has been modernized to C++20, built with CMake and Clang, with existing platform configurations for Windows, Linux and macOS. Native build verification for this fork is tracked separately in specs/001-project-foundation/verification.md.
Bohemia Interactive is releasing it to the community that has kept this game alive for more than two decades — to study it, build on it, fix it, and create from it. Three things are worth keeping separate:

**Source code (this repository)**

The engine and game executables, licensed under GPL-3.0-or-later with additional terms under Section 7. You may use, study, modify, and redistribute it, provided it stays GPL and you follow those terms.

**The name and brand**

"ARMA", "Operation Flashpoint", and the logos are *not* granted. The trademarks stay with their owners ("ARMA" is Bohemia Interactive's). A fork must be renamed and must not present itself as "Arma" or as an official Bohemia Interactive product.

**Game data (separate)**

Models, textures, sounds, missions, and voices. These are not in this repository and are not GPL; they ship separately under the APL-SA license. A free Demo is available on Steam.

In short: the code is free software, the name is not, and the game data comes separately. This license covers the source code only and grants no rights to the trademarks.


## Quick Start

Windows: из обычного PowerShell, при установленном VS 2022 C++ Build Tools и Git:

```powershell
./build.cmd
```

Сценарий подготовит локальные инструменты и зависимости, соберёт C++/Rust и
выполнит базовые тесты. Для повторной сборки используйте ту же команду.
[Параметры, кеши и диагностика](docs/building.md#windows-одна-команда).

On macOS, use `macos-arm64-clang-rwdi` or `macos-x64-clang-rwdi`.
For GNU/Linux, keep using `cmake --preset linux-x64-clang-rwdi`, then
`cmake --build build/linux-x64-clang-rwdi` and CTest against that directory.

## Layout

- [Apps](apps/README.md) - executable targets
- [Engine](engine/README.md) - engine libraries and Rust Trident tooling
- [Master server tools](mserver/README.md) - Rust service and CLI crates
- [Tests](tests/README.md) - C++ and Rust tests; CI runs Foundation and Rust tests
- `cmake/` - presets, toolchains, vcpkg triplets, and overlay ports
- `docker/` - container support for service and runtime environments
- `packages/` - ignored local game data staging area
- `resources/` - application icon resources
- `thirdparty/` - vendored third-party headers and sources

## Project Notes

- [Contributing](CONTRIBUTING.md)
- [Credits](CREDITS.md)
- [Third-party notices](THIRD_PARTY_NOTICES.md)
- [Vendored dependencies](thirdparty/README.md)

## License

The source in this repository is licensed under the **GNU General Public License
v3.0 *or later***, with additional terms under **Section 7** of the GPL. See [`LICENSE`](LICENSE) for the
full text.
This license does not grant you any right to use "ARMA" or any other Bohemia Interactive trademark.

The [`thirdparty/`](thirdparty) directory is **excluded** from the project's GPL
license: it contains vendored third-party code (glad, the RenderDoc API header)
under their own respective licenses — see [`thirdparty/README.md`](thirdparty/README.md).
Dependencies pulled in via vcpkg ([`vcpkg.json`](vcpkg.json)) likewise remain under
their own licenses.

*"ARMA" is a registered trademark of BOHEMIA INTERACTIVE a.s. "OPERATION FLASHPOINT" is a registered trademark of Electronic Arts Inc.
See [`LICENSE`](LICENSE) for information concerning trademarks. This credits file is
informational and does not constitute any grant and/or waiver of rights.*

### Game data / assets — Arma Public License Share Alike (APL-SA)

Game data and assets (models, textures, sounds, missions, etc.) are **not part of
this repository** and are **not** covered by the GPL. They are released separately
by Bohemia Interactive under the **Arma Public License Share Alike (APL-SA)**:

- APL-SA license text: <https://www.bohemia.net/community/licenses/arma-public-license-share-alike>

### Getting game data to run what you build

The compiled binaries need game data to run. You can obtain the **free Demo game
data** on Steam:

- *Arma: Cold War Assault Remastered* Demo on Steam: <https://store.steampowered.com/app/4819000>

The full game data ships with the retail game. Whatever you do with assets is
governed by the APL-SA linked above; whatever you do with this source is governed by
the GPL with additional terms per Section 7 in [`LICENSE`](LICENSE).


## Contributing

This fork uses the SDD contribution workflow in [CONTRIBUTING.md](CONTRIBUTING.md).
The original upstream was a locked source release; that restriction describes
upstream and does not define the workflow of Conflict & War.
