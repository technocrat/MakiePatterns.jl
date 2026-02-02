"""
Simple cache for loaded pattern matrices.

Caching avoids repeated file I/O and downsampling operations for frequently used patterns.
Cache keys are (filepath, factor) tuples.
"""
const _PATTERN_CACHE = Dict{Tuple{String,Int},Any}()

"""
    _cache_get(key)

Retrieve a cached pattern matrix, or return `nothing` if not cached.
"""
_cache_get(key) = get(_PATTERN_CACHE, key, nothing)

"""
    _cache_set!(key, val)

Store a pattern matrix in the cache.
"""
_cache_set!(key, val) = (_PATTERN_CACHE[key] = val)

"""
    clear_pattern_cache!()

Clear all cached pattern matrices.

# Examples
```julia
clear_pattern_cache!()
```
"""
function clear_pattern_cache!()
    empty!(_PATTERN_CACHE)
    return nothing
end
