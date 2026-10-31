# Data model

GameDataArray owns an ordered GameArrayType of reference-counted GameValue elements.
A nested GameValue can share array storage; content equality ignores that sharing.
Length must match and each corresponding typed leaf must compare equal.
No new storage, cache or lifetime owner is introduced. Script ListSet retains the
existing invariant that an array cannot contain itself directly or indirectly.
