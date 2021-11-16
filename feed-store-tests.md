✅ Retrieve
    ✅ Empty cache return empty cache
    ✅ Empty cache returns empty cache twic
    ✅ Non-empty cache returns data
    ✅ Non-empty cache twice returns same data (no side-effects)
    ✅ Error (if applicable, e.g. invalid data)
    ✅ Error return same error twice (no side-effects)

✅ Insert
    ✅ To empty cache stores data
    ✅ To non-empty cache overrides previous data with empty data
    ✅ Error (if applicable, e.g. no write permission, no disk space etc)

✅ Delete
    ✅ Empty cache does nothing (cache stays empty and doesn't fail)
    ✅ Non-empty cache leaves empty
    ✅ Error (if applicable, e.g. no delete permission)

- Side-effects must run serially to avoid race-conditions