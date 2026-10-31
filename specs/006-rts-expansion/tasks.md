# Tasks: развитие RTS

**Input**: spec.md, plan.md, research.md, data-model.md, contracts/ui.md.
**Tests**: требуются FR-012; задачи не выполнены. Сначала добавить значимые сценарии, затем реализацию и прогон.
**Organization**: пользовательские истории, каждая завершается самостоятельной приёмкой.

## Phase 1: Setup

- [ ] T001 Проверить доступные внешние классы West/East, склада, завода, обороны и машины; зафиксировать таблицу совместимости и стартовые цены без экономического тупика в specs/006-rts-expansion/research.md (FR-006/008/010; проверка загрузкой классов в игре).

## Phase 2: Foundational

- [x] T002 Зафиксировать дополнительные индексы состояния, владельца и очистку, схему каталога и заказов в specs/006-rts-expansion/data-model.md; сохранить текущие потребители CWR_RTS и определить миграцию их чтения (FR-009/011; ревью ссылок и сценарий рестарта).

## Phase 3: US1 — командование (P1)

Независимая приёмка: текущая база и пехота; SC-001/002. Реализация и нативная Windows-проверка выполнены; macOS arm64 отдельно в T024. Часть T002 о состоянии US1 выполнена (индексы 20/21); каталог T002 остаётся будущей работой.

- [x] T003 [US1] Добавить сценарии десяти групп, пустого назначения, смерти, повтора клавиши и фокуса в tests/integration/cw/control_groups.test.sqf и control_groups.test.toml (FR-002).
- [x] T004 [US1] Реализовать назначение/выбор в content/cw/Missions/CWEveron.eden/groups.sqf, синхронную загрузку в init.sqf, передачу Ctrl/цифр и сброс ввода в engine/Poseidon/UI/Controls/RTSViewport.cpp и RTSViewport.hpp (FR-002/011; T003).
- [x] T005 [US1] Реализовать данные принятого приказа в content/cw/Missions/CWEveron.eden/session.sqf и маркер/полосы здоровья в engine/Poseidon/UI/Controls/RTSViewport.cpp и RTSViewport.hpp; отсечь UI, скрытых и находящихся за камерой юнитов (FR-001/003; расширить tests/integration/cw/feedback.test.sqf для 0.8 с и здоровья 100/50/10%).
- [x] T006 [US1] Удалить CENTER HQ и его tooltip/tab-stop, сузить панель до 20%, связать геометрию viewport в content/cw/ui/resources.cpp; обновить tests/integration/cw/layout.test.sqf и presentation.test.sqf (FR-004; замеры физической ширины и снимки двух разрешений).
- [x] T007 [US1] Настроить единый focus, наклон и дистанцию в content/cw/Missions/CWEveron.eden/session.sqf; обновить tests/integration/cw/camera.test.sqf для размера юнита >=1.5, рельефа, точности клика, Home и focus-loss (FR-005; SC-002).
- [x] T008 [US1] Выполнить US1 на текущей стороне и сохранить снимки/результаты в specs/006-rts-expansion/verification.md (FR-001–005; SC-001/002).

## Phase 4: US2 — экономика (P2)

Независимая приёмка: склад, стартовая машина и узел; SC-003. Часть T001 по US2 (Truck5t/Camp/ReammoBoxWest) проверена нативно; East/завод/оборона остаются будущей частью T001.

- [x] T009 [US2] Добавить tests/integration/cw/economy.test.sqf и economy.test.toml, economy_edges.test.sqf, economy_lifecycle.test.sqf, economy_pause.test.sqf и economy_visual.test.sqf с TOML-парами: три доставки, два сборщика/остаток узла, потеря груза/склада, пауза, остановка, отсутствие пути и рестарт (FR-006/007/011; SC-003).
- [x] T010 [US2] Зафиксировать вместимость, скорость, таймаут пути и стоимость ресурса в content/cw/Missions/CWEveron.eden/economy.sqf; реализовать узлы и переходы data-model.md, ограничения cargo/remaining/credits, ровно одно начисление за доставку и очистку через session.sqf/init.sqf (FR-006/007/011; T009).
- [x] T011 [US2] Создать content/cw/Missions/CWEveron.eden/catalog.sqf для текущей казармы и склада, заменить специализированные проверки/оплату в session.sqf общим путём; сохранить READY и ошибки моделей, добавить стартовую машину для приёмки US2 (FR-006/009; текущие production.test.sqf и placement.test.sqf).
- [x] T012 [US2] Добавить ресурсную команду, отображение узлов, credits, груза/вместимости и состояний в content/cw/ui/resources.cpp и content/cw/Missions/CWEveron.eden/session.sqf (FR-007; T009 и ручной цикл).
- [x] T013 [US2] Пройти цикл без новых завода/обороны, результаты и фактический баланс записать в specs/006-rts-expansion/verification.md (FR-006/007/011; SC-003).

## Phase 5: US3 — здания (P3)

Независимая приёмка: одна сторона со стартовыми средствами; SC-004.

- [ ] T014 [US3] Добавить tests/integration/cw/catalog.test.sqf и catalog.test.toml: роли, зависимости, двойной клик, READY, ошибка модели, потеря производителя с однократным возвратом и сохранением READY (FR-008/009).
- [ ] T015 [US3] Расширить content/cw/Missions/CWEveron.eden/catalog.sqf заводом и обороной, производством экстрактора; session.sqf — списком зданий и заказов с общим site validation и обработкой уничтожения; разрешить повторную постройку после потери (FR-008/009; T014).
- [ ] T016 [US3] Добавить карточки и состояния зависимостей в content/cw/ui/resources.cpp, проверить реальные функции склада/завода/обороны и записать результат в specs/006-rts-expansion/verification.md (FR-008/009; SC-004).

## Phase 6: US4 — вторая сторона (P4)

Независимая приёмка: выбрать каждую сторону в новой сессии; SC-004/005.

- [ ] T017 [US4] Добавить tests/integration/cw/factions.test.sqf и factions.test.toml: принадлежность, каталог, полный цикл обеих сторон и отсутствие объектов/групп прежней сессии (FR-010/011).
- [ ] T018 [US4] Добавить определения второй стороны в content/cw/Missions/CWEveron.eden/catalog.sqf, выбор в content/cw/ui/resources.cpp и передачу выбора в session.sqf; использовать общие команды для обеих сторон (FR-010/011; T017).
- [ ] T019 [US4] Проверить доступность пяти типов базы и всех ролей для обеих сторон, сохранить результаты в specs/006-rts-expansion/verification.md (FR-010; SC-004).

## Final Phase: Polish & Cross-Cutting Concerns

- [x] T020 Выполнить анализ согласованности Spec Kit перед реализацией и устранить найденные пробелы в specs/006-rts-expansion/spec.md, plan.md и tasks.md (FR-012; покрытие всех FR задачами).
- [ ] T021 Провести регрессии существующих tests/integration/cw/*.test.sqf, замер frame-time по plan.md и нативные configure/build/test/запуск Windows x64; записать команды, версии, снимки и ограничения в specs/006-rts-expansion/verification.md (FR-001–012; SC-001–005).
- [ ] T022 Провести отдельные нативные configure/build/test/запуск macOS arm64, два точных drawable-разрешения и Retina resize; результаты в specs/006-rts-expansion/verification.md; при отсутствии хоста оставить задачу открытой с причиной (FR-012; SC-005).
- [ ] T023 Проверить converge против specs/006-rts-expansion/spec.md, дописать остаток в tasks.md; проверить LICENSE, CREDITS.md, THIRD_PARTY_NOTICES.md и отсутствие внешних игровых данных в diff (FR-012).

## Dependencies & Execution Order

Для первого этапа: уточнение состояния US1 в T002 → T020 (обязательный gate до изменения поведения) → US1. T001 и каталог/заказы T002 нужны перед US2–US4, не блокируют US1. Далее US1 → US2 → US3 → US4 → T021/T022 → T023. Внутри истории порядок задач последовательный; тесты создаются перед связанными изменениями. T021 и T022 могут идти на разных хостах после интеграции.

## Parallel opportunities

US1: сценарии групп T003 можно готовить одновременно с анализом снимков камеры для T007; изменения общего RTSViewport объединять последовательно.
US2: сценарии T009 и подготовка UI-макета T012 независимы до интеграции.
US3: тестовые сценарии T014 и подготовка подписей карточек T016 независимы.
US4: сценарии T017 и проверка классов East из T001 независимы от UI-реализации.
Эти возможности не требуют запуска дополнительных агентов. Общий session.sqf не редактировать конкурентно.

## Implementation Strategy

MVP — US1. Далее поставлять US2, US3, US4 с отдельной игровой приёмкой. Владелец 2026-10-31 разрешил реализацию US1 и затем US2; US3–US4 остаются за пределами текущей работы. Всего 23 задачи: setup/foundation 2, US1 6, US2 5, US3 3, US4 3, общие 4.


## Phase 7: Convergence

Сверка US1 от 2026-10-31: runtime завершён, Windows-приёмка выполнена. Ниже остаётся внешняя нативная приёмка и расследование единичного невоспроизведённого сбоя теста; US2–US4 сохраняют прежние задачи.

- [ ] T024 [US1] Выполнить нативные configure/build/test/игровые сценарии первого этапа на macOS arm64 при 1280×720 и 1920×1080 drawable, проверить Retina resize, группы, здоровье, маркер и камеру; записать доказательства в specs/006-rts-expansion/verification.md per FR-012, SC-002, Constitution IV (partial; в текущей Windows-сессии хоста нет).
- [ ] T025 [US1] Исследовать единичный сбой producing-hover в tests/integration/cw/presentation.test.sqf: использовать новый assert triCursorPos и producing_hover_before_assert, сопоставить ctrlIsHovered в engine/Poseidon/Game/Commands/GameStateExtWorldDialog.cpp с движением курсора в engine/Poseidon/Input/InputProcessingSdl.cpp; зафиксировать воспроизведение/причину и адресную регрессию в specs/006-rts-expansion/verification.md, сохраняя строгую проверку подсказки per FR-004, SC-002 (partial; последующие диагностический и полный прогоны прошли, причина не доказана).


## Phase 8: Convergence

Сверка US2 от 2026-10-31: runtime и Windows-приёмка завершены. macOS не проверена; найденная общая legacy-особенность удаления экипажа вынесена за рамки расширения экономики.

- [ ] T026 [US2] Выполнить нативные configure/build/test/игровой запуск US2 на macOS arm64, включая economy/economy_edges/economy_lifecycle/economy_pause/economy_visual при двух drawable-разрешениях; подтвердить модели, вождение, три доставки, restart и Retina resize в specs/006-rts-expansion/verification.md per FR-012, SC-003/005, Constitution IV (partial; нативного Mac-хоста в текущей сессии нет).
- [ ] T027 Исследовать общий контракт удаления сидящего person в engine/Poseidon/Game/Commands/GameStateExtWorld.cpp (DeleteVehicle): удаление водителя перед транспортом оставляло person после удаления машины; зафиксировать минимальное воспроизведение, добавить native-регрессию и адресное исправление, сохранив player/network guards; результаты в specs/006-rts-expansion/verification.md per Constitution III, FR-011 (legacy partial; текущая миссия проверенно удаляет транспорт перед экипажем и не оставляет объектов).


## Phase 9: Mouse command correction

- [x] T028 [US1] Разделить ЛКМ-выделение и ПКМ-приказы в content/cw/Missions/CWEveron.eden/session.sqf, обновить подсказки session.sqf/economy.sqf и contracts/ui.md per FR-013; пустой ЛКМ не должен отменять текущую добычу/движение.
- [x] T029 [US1] Добавить tests/integration/cw/commands.test.sqf и commands.test.toml с реальными отрицательными проверками ЛКМ/двойного ЛКМ на земле и ресурсе, положительными ПКМ-командами и сохранением текущего приказа per FR-013.
- [x] T030 [US2] Обновить native ввод в tests/integration/cw/mouse.test.sqf, feedback.test.sqf и economy.test.sqf на ПКМ для приказов; сохранить ЛКМ placement/selection, выполнить commands/mouse/feedback/economy и записать результаты в specs/006-rts-expansion/verification.md per FR-013, FR-006/009.


## Phase 10: Infantry health visibility

- [x] T031 [US1] Постоянно включать живых видимых своих солдат в CWR_HealthUnits в content/cw/Missions/CWEveron.eden/session.sqf; сохранить фильтры скрытых/мёртвых, текущую политику техники и renderer per FR-003, SC-002.
- [x] T032 [US1] Добавить tests/integration/cw/health.test.sqf и health.test.toml: невыделенные солдаты 100/50/10%, смена/очистка выделения, скрытие, смерть, удаление, посторонний солдат; проверить native снимки 720p/1080p и записать результаты в specs/006-rts-expansion/verification.md per FR-003, SC-002.
