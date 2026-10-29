# Feature Specification: Everon RTS — первый срез Conflict & War

**Feature Branch**: `feature/003-everon-rts-slice`
**Created**: 2026-10-27
**Status**: In progress
**Input**: Превратить военный симулятор в RTS с оммажем C&C: Everon, база, казарма, солдаты, боковая панель, главное меню и заставка. Начать выполнение.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Командование на Everon (Priority: P1)

Игрок запускает одиночную песочницу Everon со штабом. Основная область постоянно показывает настоящий 3D-мир; справа находится панель с миникартой и карточками производства. Команды отдаются кликом по 3D-ландшафту.

**Why this priority**: Минимальный запускаемый путь от симулятора к стратегии.
**Independent Test**: Запустить миссию, увидеть 3D-штаб и панель одновременно, переместить и приблизить камеру.
**Acceptance Scenarios**:
1. **Given** доступные локальные данные Everon, **When** миссия загружена, **Then** есть штаб в 3D-мире, стартовые кредиты и командная панель.
2. **Given** панель открыта, **When** игрок двигает камеру и масштабирует вид, **Then** 3D-база видна сверху под углом, а панель остаётся открытой.

### User Story 2 — Постройка и производство (Priority: P1)

Игрок заказывает казарму, выбирает место рядом со штабом и после завершения строительства нанимает солдат.

**Why this priority**: Доказывает основной цикл RTS.
**Independent Test**: На чистом старте построить казарму и произвести двух солдат, проверить стоимость, задержку и повторный заказ.
**Acceptance Scenarios**:
1. **Given** достаточно кредитов, **When** заказана казарма, **Then** списывается 1000 и идёт 15 с производства без здания в мире; READY позволяет выбрать место, после размещения найм доступен сразу.
2. **Given** готовая казарма, **When** заказана пехота, **Then** очередь обрабатывается последовательно и солдат появляется у казармы.
3. **Given** выбран солдат, **When** задана точка движения, **Then** он получает приказ перемещения.

### User Story 3 — Облик C&W (Priority: P2)

Игрок видит оригинальные заставку и главное меню C&W, боковую панель с кредитами, командами и состоянием производства.

**Why this priority**: Срез должен восприниматься как стратегия C&W.
**Independent Test**: Проверить загрузку и интерфейс при 1280×720 и 1920×1080, сохранить снимки.
**Acceptance Scenarios**:
1. **Given** запущен C&W, **When** завершена загрузка, **Then** собственная заставка и меню ведут к первому срезу, настройкам и выходу.
2. **Given** идёт строительство/найм, **When** открыт интерфейс, **Then** видны кредиты, состояние и доступность команд.

### Edge Cases

- Недостаток кредитов, двойной клик, отмена размещения: нет повторных списаний.
- Место вне радиуса базы, вода или занятая площадка: отказ с объяснением.
- Казарма не готова/уничтожена: найм недоступен, очередь возвращает оплаченные кредиты.
- Выход/повторный запуск: состояние и обработчики не переносятся между миссиями.
- Нет Everon или класса модели: явная диагностика, отсутствие данных не выдаётся за рабочий срез.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Документировать `main` (проверенные выпуски), `develop`, `feature/*`, `release/*`; разработку среза вести в feature от develop.
- **FR-002**: Загружать Everon из внешней установки; исходники миссии и собственные ресурсы хранить в репозитории.
- **FR-003**: Создать штаб и стартовый баланс 3000 кредитов; камера командира над настоящим 3D-миром без управления от первого лица; карта только в миникарте.
- **FR-004**: Постоянная правая панель: кредиты, казарма (1000 / 15 с), солдат (100 / 5 с), очередь максимум 5, статус, возврат камеры к штабу, выход.
- **FR-005**: Заказ одной казармы списывает 1000 кредитов и запускает 15 с производства в панели. Готовое здание размещается в пределах 150 м от штаба с проверкой воды и пересечения строений; отмена размещения сохраняет оплаченный готовый заказ.
- **FR-006**: Солдат появляется у готовой казармы, доступен выбор и приказ движения. Отказы не меняют баланс. Уничтожение казармы отменяет очередь с возвратом.
- **FR-007**: Собственное главное меню и заставка C&W, оригинальный сгенерированный фон с сохранённым промптом и происхождением; сохранить обязательные уведомления.
- **FR-008**: Автоматические проверки экономики, очереди, размещения и повторного запуска плюс игровой прогон и снимки; результаты связывать с FR. Нативную готовность macOS не заявлять без прогонов.

### Key Entities

- Сессия: штаб, кредиты, режим команды, казарма и её срок готовности, очередь, произведённые солдаты, выбор, камера.
- Заказ: тип, оплаченная цена, время готовности; один владелец обработки.
- Точка размещения: мировые координаты, доступность, причина отказа.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: На Everon игрок за 2 минуты запускает базу, строит казарму, нанимает двух солдат и отдаёт приказ движения.
- **SC-002**: После казармы и двух солдат остаётся 1800 кредитов; повторные/отвергнутые команды не расходуют кредиты, отмена размещения сохраняет готовое здание без повторной оплаты.
- **SC-003**: Панель читается и не перекрывает основную командную область при 720p и 1080p.
- **SC-004**: Есть воспроизводимый локальный запуск без копирования сторонних игровых данных в Git и честный отчёт проверок.

## Assumptions

- Первый срез — одиночная песочница без врага, сбора ресурсов, мультиплеера и сохранений. Это не завершённая RTS.
- Кредиты конечны; балансовые значения выше — стартовые параметры среза.
- Оммаж относится к циклу строительства и композиции боковой панели; графика и названия C&W оригинальные.
- Основной экран — 3D. Выбор места, выделение солдата и приказ движения работают непосредственно в мире; 2D-карта используется только как миникарта.
- Требуется существующая локальная установка с Everon и базовыми классами CWA.

## Owner correction — 2026-10-27

The owner rejected the command map as the main screen after seeing it in-game. This supersedes the earlier tactical-map assumption and US1 map acceptance: the main play area MUST show the actual 3D Everon world continuously with an elevated oblique RTS camera. Commands place/select/move directly by clicking that world. The right sidebar MUST follow the supplied reference composition: small minimap at top, credits and category tabs, a two-column production area with portrait, contextual requirements and progress (the presentation pass replaces former placeholder slots). Art is original C&W, not copied reference pixels. No map/overview mode switching is required. Camera pan and zoom must stay available while the sidebar is open.

- **FR-009**: Native 3D command viewport projects clicks through the current camera onto Everon terrain; sidebar/minimap clicks never issue world orders. Left click selects/places; right click moves/cancels. Arrow/WASD pan, wheel zoom, home returns HQ.
- **FR-010**: Sidebar includes minimap, credits, build/infantry tabs, a two-column production area (portrait and contextual requirements), build/training progress, selection feedback; remains visible over the world at 720p and 1080p.
- **SC-005**: Runtime screenshot shows 3D terrain/base and the sidebar simultaneously; actual world clicks build barracks/select a soldier/order movement and sidebar clicks do not debit or move unless intended.

## Corrections from Windows review — 2026-10-27

- **FR-011**: Placement must check the candidate barracks geometry against existing world geometry, including rotated buildings with centres outside 12 m. Rejected placement must leave credits and barracks state unchanged; unavailable geometry must fail explicitly.
- **FR-012**: The Everon button must start the slice in both Windows Game and GameDemo using one shared registration implementation; other demo modules remain unchanged.
- **FR-013**: Left-click an owned soldier to select it, then left-click empty terrain to move the selection. Clicking another soldier changes selection. Right-click move/cancel remains supported. Both ordinary and rapid repeated clicks must reach the command viewport through normal UI dispatch. Sidebar clicks never issue orders.
- **SC-006**: Native Windows regressions reproduce a large rotated building overlap, GameDemo menu entry, and selection plus actual movement using cursor/button input through the UI event path, without directly invoking the viewport handler.

## CI failures — 2026-10-28

- **FR-014**: Windows developer-environment import must preserve the caller's VCPKG_ROOT (including its absence, so the repository default is chosen), while importing required VS/SDK variables. Existing non-checkout directories and modified/wrong-baseline checkouts must still be rejected.
- **FR-015**: macOS CI must use Clang paired with the active Xcode SDK for both project and vcpkg dependency compilation. The pinned enkiTS source must include its directly used type_traits header through a reproducible overlay patch. Keep vcpkg baseline, dependency versions, strict errors, native three-platform matrix and all tests.
- **SC-007**: A regression demonstrates that a VS-provided VCPKG_ROOT cannot override the caller; Windows prepare succeeds against the pinned checkout and invalid paths fail. GitHub's next Windows/macOS runs must be inspected for native configure/build/test outcomes, recording any subsequent blockers separately from gameplay readiness.

## Native timing test correction — 2026-10-28

- **FR-016**: Functional interval/sleep tests must validate getSystemTime microsecond units against independently sampled std::chrono::steady_clock brackets, monotonic progress and the existing minimum wait expectations. Scheduler oversleep must not fail an otherwise correct timer. Do not skip tests, add retries or merely widen fixed wake-up deadlines.
- **FR-017**: Keep the native ARM job required. If GitHub cannot allocate an ARM runner, record the infrastructure cancellation separately; do not replace it with an Intel run or claim ARM readiness.
- **SC-008**: The corrected tests pass on Windows, including a deliberately delayed workload; a native Intel rerun must determine the macOS result. The bracket oracle must still reject stopped clocks and incorrect microsecond scaling. Remaining ARM capacity failures remain explicit.

## Interactive RTS feedback — 2026-10-28

- **FR-018**: Barracks placement shows the actual model as a translucent green/red ghost following the pointer over 3D terrain. Green uses the same site validation as commit; red cannot be placed. Hide on sidebar/miss/cancel/commit/exit; preview has no simulation/collision/economic side effects.
- **FR-019**: Clicking an owned soldier's visible screen bounds selects it regardless of camera height or uneven terrain. Show persistent selection feedback; sidebar clicks stay isolated. Retain contextual left/right movement.
- **FR-020**: Holding LMB and dragging more than 5 screen pixels draws a clipped selection rectangle; releasing selects the live owned units within it, including reversed drags. Group orders move all selected units with spacing. A small click still selects/moves normally; reset/exit clears selection.
- **FR-021**: Production cards animate an original clockwise reveal of their image, show queued count and completion feedback. Progress follows authoritative build/training deadlines; queued next orders restart the sweep and invalid commands do not start one. No copied Red Alert assets.
- **FR-022**: Remove the inactive HQ ONLINE placeholder from the production grid. Keep clearly labelled camera return to HQ; no decorative element should imply an unavailable action.
- **SC-009**: Native input and screenshots at 720p/1080p prove green/red preview without debit, rejection of red placement, exact model clicks at more than one zoom, drag selection of two units, actual group movement and sidebar isolation. Screenshots at different production times show the clockwise reveal progressing and restarting for the next order.

## Owner corrections — 2026-10-29

- **FR-023**: Barracks follows idle → paid production (15 s) → READY → placement preview → deployed. Production creates no world building. Click READY to choose a site; early/repeated clicks do not restart or debit. Invalid sites and right-click cancellation retain READY. Deployment is immediate, charges nothing further, and enables infantry.
- **FR-024**: The required engine player is invisible during the RTS session, with no visible body or shadow; produced infantry remain visible/selectable. Restart and mission exit restore ordinary player visibility.
- **FR-025**: Mission startup establishes the commander camera before the first playable frame, without a first-person flash or arbitrary delay. Both direct launch and main-menu launch use this path; startup failure reports the error.
- **FR-026**: Repair observed CI failures without removing tests: Unix process lifecycle checks work on macOS and Linux, and Windows crash dumps retain the original exception context. Record native outcomes separately per platform.
- **SC-010**: Native pointer regression proves full price/timer/READY/preview/cancel/deploy flow, no building before deployment, immediate recruitment after deployment, hidden observer and direct/menu startup; inspect initial frames at 720p and 1080p.
- **SC-011**: Native Windows crash regression and Rust workspace pass; subsequent native macOS CI determines Unix lifecycle results. Do not claim macOS gameplay verified from CI compilation.

FR-023 supersedes the earlier place-then-build order throughout US2/edge cases and the interactive feedback acceptance. Cancellation means canceling the placement cursor, not refunding or destroying an order.

## Camera border regression — 2026-10-29

- **FR-027**: The RTS world fills the available play area without cinematic black borders from startup onward; menu launch, direct launch, restart, pan/zoom and viewport picking remain consistent at720p/1080p. Ordinary cutscenes retain their cinematic borders.
- **FR-028**: MENU ends the slice through an available game command and returns to the main menu, with no script error or process abort.
- **SC-012**: Native screenshots show terrain reaching the left/top/bottom of the play area, and automatic tests verify disabled cinematic border and menu→slice→menu.

## Presentation polish — 2026-10-29

Owner requests a coherent player-facing presentation rather than prototype UI.
- **FR-029**: RTS camera starts close enough to read HQ/infantry, uses a deliberate elevated oblique angle, smoothly pans/zooms without key-release drift, preserves terrain picking, group selection, preview alignment and borderless startup. Home restores the designed view.
- **FR-030**: Sidebar, main menu and startup share one restrained military visual language, consistent spacing, clear title/body/numeric font hierarchy and original art. Replace large placeholder grid blocks and debug-like command/status lines with useful contextual information; retain minimap, credits, categories, production progress, costs, selection information and working navigation.
- **FR-031**: New original background/card raster assets are generated through imagegen, saved with reproducible prompt/provenance and runtime conversions; actual text remains native and sharp. Respect third-party notices and existing font licenses/mappings.
- **FR-032**: UI distinguishes idle, producing, READY, placement, deployed, locked infantry and selection with readable text/contrast, active-category state and contextual help. No fake features or decorative controls presented as usable. Normal/hover/disabled states are coherent.
- **SC-013**: Native Windows screenshots of menu, startup, empty base, production, READY, placement and selected infantry at720p/1080p show no clipped labels, overlapping controls, giant placeholder cells or cinematic borders. Camera and native input regression pass at both sizes. This is visual polish of the first slice, not a claim of finished combat/economy or modernized terrain assets.
