"""
Pattern loading and processing functions.

This module provides functions to load pattern files from the artifact directory
and convert them to downsampled matrices suitable for use with Makie.Pattern.
"""

"""
    _pattern_asset_path(filename::AbstractString)

Resolve a pattern filename to its full path in the artifact directory.

# Arguments
- `filename::AbstractString`: The pattern filename (e.g., "701.png")

# Returns
The full path to the pattern file in the artifact directory.
"""
function _pattern_asset_path(filename::AbstractString)
    joinpath(artifact"patterns", "patterns", filename)
end

"""
    make_pattern(name::Symbol; factor=nothing, cache=true)

Load and downsample a registered pattern by name.

# Arguments
- `name::Symbol`: The pattern name (must be registered)
- `factor::Union{Nothing,Int}=nothing`: Downsample factor (larger = smaller pattern).
  If `nothing`, uses the registered default factor.
- `cache::Bool=true`: Whether to cache the loaded pattern

# Returns
A downsampled matrix suitable for use with `Makie.Pattern`.

# Details
The downsampling takes every `factor`th row and column from the loaded image,
effectively making the pattern appear smaller when tiled. Larger factors produce
smaller patterns.

# Examples
```julia
# Load pattern with default factor
mat = make_pattern(:p701)

# Load pattern with custom factor
mat = make_pattern(:p701; factor=5)

# Load without caching
mat = make_pattern(:p701; cache=false)
```
"""
function make_pattern(name::Symbol; factor::Union{Nothing,Int}=nothing, cache::Bool=true)
    (filename, default_factor) = _lookup(name)
    f = something(factor, default_factor)

    fullpath = _pattern_asset_path(filename)
    key = (fullpath, f)

    if cache
        cached = _cache_get(key)
        cached !== nothing && return cached
    end

    mat = Matrix(FileIO.load(fullpath))
    pat = mat[1:f:end, 1:f:end]

    cache && _cache_set!(key, pat)
    return pat
end

"""
    pattern(name::Symbol; factor=nothing, cache=true)

Create a Makie.Pattern from a registered pattern.

# Arguments
- `name::Symbol`: The pattern name (must be registered)
- `factor::Union{Nothing,Int}=nothing`: Downsample factor (larger = smaller pattern).
  If `nothing`, uses the registered default factor.
- `cache::Bool=true`: Whether to cache the loaded pattern

# Returns
A `Makie.Pattern` object that can be used as a color fill in Makie plots.

# Examples
```julia
# Create a pattern with default settings
pat = pattern(:p701)

# Use the pattern in a plot
poly!(ax, geometries; color=pat, strokewidth=0.5)

# Create a pattern with custom factor
pat_small = pattern(:p701; factor=10)  # smaller pattern
pat_large = pattern(:p701; factor=2)   # larger pattern
```
"""
pattern(name::Symbol; factor::Union{Nothing,Int}=nothing, cache::Bool=true) =
    Makie.Pattern(make_pattern(name; factor=factor, cache=cache))
