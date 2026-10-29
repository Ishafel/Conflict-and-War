# User interface contract

CWR_Command IDD7300: transparent world viewport 7301 left 76%, minimap7304 upper right, credits7302, status7303, tabs7320/7321, production cards7310/7311 in two columns, queue/progress7305, home7315 and exit7316. Left click in world places/selects, or moves a selected soldier on empty terrain; right click moves/cancels. Camera scroll zoom, WASD/arrows pan, Home recenters. 3D always visible behind UI. Main menu continues to start Everon with7390.

Native callbacks: selectableUnits returns owned live objects; selectionPositions returns their selected world positions. onWorldClick receives _unit (screen hit), _pos and _button. onBoxSelect receives _units chosen within the drag rectangle. placementActive enables render-only placementClass; placementValid receives _pos, _sea, _candidate and returns the common validator result. CWR_RTS[17] records [position,valid] for feedback. Production overlays 7350/7351 are disabled controls over images; productionState returns [fraction,queueCount,ready]. No debit occurs in any native drawing callback. HQ ONLINE removed; 7315 is labelled CENTER HQ.

The compatible native property name remains selectionPosition; its expression now returns an array of positions for the selected group. onPreviewHidden clears [17]. The ghost's alpha is 0.28 and red/green color is driven by the validator. Native transparency preserves per-object alpha through both hardware and software material-section setup; shared model resources are unchanged.

## Production-before-placement correction (FR-023–025)
7310 idle starts paid timer; producing rejects repeat; READY activates ghost; cancel preserves READY; deployment consumes it and enables 7311 immediately. Progress[2] means awaiting placement for building card. Session length19, ready at18. Observer isObjectHidden=true throughout RTS and false after Clear. Unscheduled mission init establishes camera before rendered gameplay.
