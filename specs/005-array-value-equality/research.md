# Research

- Decision: compare size and each corresponding GameValue::IsEqualTo result.
  Rationale: express.cpp:2079 is a stub returning false after the size check;
  ListIsIn/ListFind/ListSub already consume the existing value dispatcher.
  Alternative: new array == overloads would change the dialect and are out of scope.
- Decision: retain existing leaf dispatch and reject identity shortcuts.
  Rationale: scalar/bool equality is exact; GameDataString uses case-sensitive
  RString equality; nil/NOTHING and NaN compare unequal, including shared instances.
  Alternative: stringification loses types; script string == uses different case rules.
- Decision: use the existing acyclic mutation invariant.
  Rationale: ListSet/CheckArrayInValue reject direct and indirect cycles with EvalDim;
  shared DAG subarrays are allowed. Do not add global comparison state or graph machinery.
- Planning research was independently inspected by the Spec Kit research agent;
  findings checked against local evaluator sources and RString.hpp.

- Decision: repair Trident array assertion consumers too (FR-006).
  Rationale: diagnostic triAssertEq initially accepted unequal arrays because
  TriValStr used GetString for arrays. Red tests prove false success; use the
  repaired typed value dispatcher and GetText only for diagnostics. Preserve
  non-array legacy assertion behavior. Alternative: stringifying comparisons
  would still lose types and mask invalid equality, so it is rejected.
