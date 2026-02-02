"""
High-level plotting functions for pattern-filled polygons.

This module provides convenience functions for plotting multiple geometries
with different pattern fills based on classification bins.
"""

"""
    patternpoly!(ax, geoms, bins; patterns, factors=nothing, strokewidth=0.5, cache=true, kwargs...)

Plot geometries with pattern fills based on integer bin codes.

# Arguments
- `ax`: A Makie axis (e.g., `Axis`, `GeoAxis`)
- `geoms`: Vector of geometries (must have same length as `bins`)
- `bins`: Vector of integer bin codes (typically 1:k)
- `patterns::Vector{Symbol}`: Vector of registered pattern names, indexed by bin value
- `factors::Union{Nothing,Vector{Int}}=nothing`: Optional vector of custom downsample factors per pattern
- `strokewidth=0.5`: Stroke width for polygon outlines
- `cache::Bool=true`: Whether to cache loaded patterns
- `kwargs...`: Additional keyword arguments passed to `poly!`

# Returns
The axis object.

# Details
This function simplifies the process of creating choropleth-style maps with pattern fills.
Instead of manually calling `poly!` for each bin, you can specify all patterns at once
and the function handles the grouping and plotting.

# Examples
```julia
using MakiePatterns, GeoMakie, CairoMakie

# Assuming you have a GeoDataFrame `df` with a `geometry` column
# and a `bins` column with values 1:8

f = Figure(size=(3200, 2400))
ga = GeoAxis(f[1, 1]; dest="EPSG:5070")
hidedecorations!(ga)

# Plot with 8 different patterns
patternpoly!(ga, df.geometry, df.bins;
             patterns=[:p701, :p610, :p710, :p643, :p656, :p601, :p707, :p717],
             strokewidth=0.5)

f
```

```julia
# Use custom factors for specific patterns
patternpoly!(ga, df.geometry, df.bins;
             patterns=[:p701, :p610, :p710, :p643],
             factors=[3, 4, 6, 4],
             strokewidth=0.5)
```
"""
function patternpoly!(ax, geoms, bins;
                      patterns::Vector{Symbol},
                      factors::Union{Nothing,Vector{Int}}=nothing,
                      strokewidth=0.5,
                      cache::Bool=true,
                      kwargs...)

    @assert length(geoms) == length(bins) "geoms and bins must have the same length"

    k = length(patterns)

    # Pre-build Pattern objects once per bin (avoids repeated IO)
    pats = Vector{Any}(undef, k)
    for i in 1:k
        fac = factors === nothing ? nothing : factors[i]
        pats[i] = pattern(patterns[i]; factor=fac, cache=cache)
    end

    # Draw by bin
    for i in 1:k
        idx = findall(==(i), bins)
        isempty(idx) && continue
        Makie.poly!(ax, geoms[idx]; color=pats[i], strokewidth=strokewidth, kwargs...)
    end

    return ax
end
