"""
    MakiePatterns

A Julia package for using raster pattern fills with Makie plotting.

# Features
- Auto-registration of pattern files from package assets
- Efficient caching of loaded patterns
- Convenient `patternpoly!` function for choropleth-style maps
- Support for custom downsample factors to control pattern scale

# Quick Start
```julia
using MakiePatterns, GeoMakie, CairoMakie

# See available patterns
patterns = available_patterns()

# Create a pattern
pat = pattern(:p701)

# Use in a plot
poly!(ax, geometry; color=pat, strokewidth=0.5)

# Or use the convenience function for multiple bins
patternpoly!(ax, geometries, bins;
             patterns=[:p701, :p610, :p710, :p643])
```

# Exports
- `register_pattern!`: Manually register a pattern
- `available_patterns`: List all registered patterns
- `load_pattern_defaults`: Load pattern metadata from TOML
- `auto_register_patterns!`: Auto-register all patterns from artifact
- `make_pattern`: Load and downsample a pattern
- `pattern`: Create a Makie.Pattern from a registered pattern
- `patternpoly!`: Plot geometries with pattern fills by bin
- `clear_pattern_cache!`: Clear the pattern cache
"""
module MakiePatterns

using Artifacts
using FileIO
using Makie

export register_pattern!, available_patterns,
       load_pattern_defaults, auto_register_patterns!,
       make_pattern, pattern,
       patternpoly!,
       clear_pattern_cache!

include("registry.jl")
include("cache.jl")
include("autoregister.jl")
include("loaders.jl")
include("plotting.jl")

"""
    __init__()

Module initialization function.
Automatically registers all patterns found in the artifact directory.
"""
function __init__()
    try
        auto_register_patterns!()
    catch err
        @warn "MakiePatterns auto-registration skipped during initialization" exception=(err, catch_backtrace())
    end
end

end # module MakiePatterns
