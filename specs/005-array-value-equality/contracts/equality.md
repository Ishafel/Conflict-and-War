# Array value equality contract

- [] equals []; [1,true,"A"] equals an independent [1,true,"A"].
- [[1],[]] equals a value-equivalent independent nested array, including shared subarrays.
- Length/order/type/value mismatch is false; ["A"] differs from ["a"].
- Undefined/NOTHING and NaN retain false leaf equality, even through self-comparison.
- Comparison never mutates either operand; a later mutation changes the next result.
- [1,2] in [[1,2],[3]] is true; [[1,2],[3]] find [1,2] is 0.
- [[1,2],[3],[1,2]] - [[1,2]] yields [[3]].
- Cyclic set assignments remain EvalDim. No new array ==/!= overload is registered.
