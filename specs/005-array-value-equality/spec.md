# Feature Specification: Array value equality

**Feature Branch**: `feature/003-everon-rts-slice` (existing PR)
**Created**: 2026-10-31
**Status**: Implemented and verified on native macOS arm64
**Input**: Complete slice T066: reproduce and repair array comparison, preserving existing script semantics.

## User Scenarios & Testing

### User Story 1 — Find and remove array values (Priority: P1)
Mission authors can find a nested array by its contents and remove matching array values.
**Independent Test**: Search independently constructed nested values and subtract matching values.
**Acceptance Scenarios**:
1. **Given** equal independently allocated arrays, **When** compared for membership/search, **Then** they match, including empty arrays.
2. **Given** ordered nested arrays, **When** any corresponding value, type, order or length differs, **Then** they do not match.
3. **Given** repeated matching nested arrays, **When** matching values are subtracted, **Then** all matching entries disappear and unmatched order is preserved.

### User Story 2 — Preserve leaf and mutation semantics (Priority: P2)
Array comparison follows existing element equality and observes later mutations without changing operands.
**Independent Test**: Compare mixed/shared arrays, then mutate one side and compare again.
**Acceptance Scenarios**:
1. **Given** strings with different case or elements of different types, **When** arrays are compared, **Then** they remain unequal under existing value equality.
2. **Given** undefined or NaN elements, **When** even the same array instance is compared, **Then** existing unequal-element behavior is retained.
3. **Given** equal arrays, **When** one changes, **Then** the next comparison reflects the change; comparison itself mutates neither side.

### Edge Cases
Empty arrays, nested empty arrays, shared subarrays, first/last mismatch, boolean versus scalar,
case-sensitive string elements, undefined elements, NaN, and rejected self/indirect cycles.

## Requirements

### Functional Requirements
- **FR-001**: Array value equality MUST compare length, order and corresponding values structurally, including nested and empty arrays; allocation identity MUST NOT determine the result.
- **FR-002**: Element comparison MUST preserve existing type-sensitive scalar, boolean, string, undefined and NaN semantics; no pointer-identity shortcut may override an unequal element.
- **FR-003**: Existing membership, find and subtraction operations MUST use repaired array equality, preserving their result types and unmatched order.
- **FR-004**: Comparison MUST leave operands unchanged and observe subsequent mutation. Existing rejection of self/indirect cyclic arrays MUST remain; cycle construction and new array equality operators are outside scope.
- **FR-005**: Regressions MUST fail on the original comparator and pass after repair; native evaluator checks and existing macOS gameplay checks MUST remain valid. CI MUST run the array regressions on both required platforms. Preserve stack, licenses and external data separation.
- **FR-006**: Trident array equality/inequality assertions MUST use typed value equality
  and report array contents on failure; distinct arrays MUST NOT silently compare as
  empty strings. Retain established non-array assertion behavior.

### Key Entities
Array value: ordered, acyclic sequence of typed values; nested arrays may share storage.
Comparison: boolean result using existing leaf value equality, with no retained state.

## Success Criteria
- **SC-001**: Empty, mixed, nested, shared and mismatched arrays have the specified results; unchanged inputs and changed subsequent results are demonstrated.
- **SC-002**: Membership, find and subtraction succeed for independently constructed equal nested arrays, with a failing-before reproduction.
- **SC-003**: Undefined/NaN/string-case/type behavior and cyclic-assignment rejection remain unchanged; evaluator and gameplay regressions pass on native arm64.
- **SC-004**: A failing-before assertion regression proves mismatched arrays are rejected,
  matching nested arrays accepted, and failure diagnostics contain their values.

## Assumptions
Arrays are acyclic under the existing script mutation contract. Scalar equality is exact;
string leaf value equality is case-sensitive, unlike the separate script string `==` operator.
No new `==`/`!=` overload for arrays is introduced. The existing PR branch is retained.
