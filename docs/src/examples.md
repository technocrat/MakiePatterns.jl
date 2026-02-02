# Examples

## Basic Pattern Usage

### Single Pattern

```julia
using MakiePatterns
using CairoMakie

# Load a pattern
pat = pattern(:p101_C)

# Create a simple plot
f = Figure()
ax = Axis(f[1, 1])

# Create some simple geometry
rect = [Point2f(0, 0), Point2f(1, 0), Point2f(1, 1), Point2f(0, 1)]

# Fill with pattern
poly!(ax, rect; color=pat, strokewidth=1)

f
```

### Multiple Patterns

```julia
using MakiePatterns
using CairoMakie

f = Figure(size=(800, 400))
ax = Axis(f[1, 1])

patterns_to_show = [:p101_C, :p102_C, :p103_C, :p104_C]

for (i, pat_name) in enumerate(patterns_to_show)
    pat = pattern(pat_name)
    rect = [Point2f(i-1, 0), Point2f(i, 0), Point2f(i, 1), Point2f(i-1, 1)]
    poly!(ax, rect; color=pat, strokewidth=1, strokecolor=:black)
end

f
```

## Choropleth Maps

### Basic Choropleth with Patterns

```julia
using MakiePatterns, GeoMakie, CairoMakie
using DataFrames, GeoDataFrames

# Load your geospatial data
df = DataFrame(...)  # Must have geometry column and bins column

# Create a GeoAxis
f = Figure(size=(3200, 2400))
ga = GeoAxis(f[1, 1]; dest="EPSG:5070")
hidedecorations!(ga)

# Plot with 8 different patterns for 8 bins
patternpoly!(ga, df.geometry, df.bins;
             patterns=[:p701_K, :p610_M, :p710_C, :p643_DO,
                      :p656_C, :p601_K, :p707_M, :p717_C],
             strokewidth=0.5)

f
```

### Choropleth with Custom Factors

```julia
using MakiePatterns, GeoMakie, CairoMakie

# Create figure
f = Figure(size=(3200, 2400))
ga = GeoAxis(f[1, 1]; dest="EPSG:5070")
hidedecorations!(ga)

# Use different downsample factors for different bins
# Smaller factors = larger patterns, larger factors = smaller patterns
patternpoly!(ga, df.geometry, df.bins;
             patterns=[:p101_C, :p102_C, :p103_C, :p104_C],
             factors=[2, 4, 6, 8],  # Progressively smaller patterns
             strokewidth=0.5)

f
```

## Pattern Customization

### Adjusting Pattern Scale

```julia
using MakiePatterns, CairoMakie

f = Figure(size=(1200, 400))

# Same pattern, different factors
for (i, factor) in enumerate([2, 5, 10])
    ax = Axis(f[1, i]; title="Factor = $factor")
    pat = pattern(:p101_C; factor=factor)
    rect = [Point2f(0, 0), Point2f(1, 0), Point2f(1, 1), Point2f(0, 1)]
    poly!(ax, rect; color=pat, strokewidth=1)
end

f
```

### Pattern Preview Gallery

```julia
using MakiePatterns, CairoMakie

# Get first 20 patterns
patterns_list = available_patterns()[1:20]

# Create a grid
ncols = 5
nrows = ceil(Int, length(patterns_list) / ncols)

f = Figure(size=(1200, 1000))

for (idx, pat_name) in enumerate(patterns_list)
    row = div(idx - 1, ncols) + 1
    col = mod(idx - 1, ncols) + 1

    ax = Axis(f[row, col]; title=string(pat_name))
    hidedecorations!(ax)

    pat = pattern(pat_name)
    rect = [Point2f(0, 0), Point2f(1, 0), Point2f(1, 1), Point2f(0, 1)]
    poly!(ax, rect; color=pat, strokewidth=0.5)
end

f
```

## Working with Cache

### Cache Management

```julia
using MakiePatterns

# Patterns are cached by default
pat1 = pattern(:p101_C; cache=true)

# Load the same pattern (returns cached version)
pat2 = pattern(:p101_C; cache=true)

# Clear the cache
clear_pattern_cache!()

# Force reload without using cache
pat3 = pattern(:p101_C; cache=false)
```

## Advanced Usage

### Custom Pattern Registration

If you have your own pattern files:

```julia
using MakiePatterns

# Register a custom pattern
register_pattern!(:my_custom_pattern, "path/to/pattern.png"; default_factor=4)

# Now use it
pat = pattern(:my_custom_pattern)
```

### Listing Available Patterns

```julia
using MakiePatterns

# Get all pattern names
all_patterns = available_patterns()

println("Total patterns: ", length(all_patterns))
println("First 10: ", all_patterns[1:10])

# Filter patterns by name
c_patterns = filter(p -> occursin("_C", string(p)), all_patterns)
println("Patterns ending in _C: ", length(c_patterns))
```
