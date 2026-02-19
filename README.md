# MakiePatterns.jl

A Julia package for using raster pattern fills with Makie plotting, particularly useful for creating choropleth maps with pattern-based classifications instead of color gradients. The native Pattern type supports only `/`, `\`, `-`, `|`, `x`, and `+`.

## Features

- **471 Built-in Patterns**: Ships with a comprehensive collection of geologic/cartographic patterns used by the U.S. Geological Service
- **User patterns can be added from PNG files**
- **Auto-registration**: Patterns are automatically discovered and registered at module load time
- **Efficient Caching**: Loaded patterns are cached to avoid repeated file I/O
- **Flexible Scaling**: Control pattern size via downsample factors
- **Convenient API**: Simple functions for single or multi-pattern plots
- **Choropleth Support**: `patternpoly!` function for easy bin-based pattern mapping

## Installation

```julia
using Pkg
Pkg.add("MakiePatterns")
```

## Quick Start

```julia
using MakiePatterns
using GeoMakie, CairoMakie

# See all available patterns
patterns = available_patterns()
# [:p101_C, :p101_DO, :p101_K, :p101_M, :p102_C, ...]

# Create a single pattern
pat = pattern(:p101_C)

# Use in a plot
f = Figure()
ax = Axis(f[1, 1])
poly!(ax, some_geometry; color=pat, strokewidth=0.5)
```

## Demo

Example of pattern-filled choropleth map using MakiePatterns:

```julia
using CairoMakie
using DataFrames
using Downloads
using GeoDataFrames
using GeoMakie
using MakiePatterns

url = "https://juliamapping.com/addn/geojson_example.json"
tmp = Downloads.download(url)
gdf = GeoDataFrames.read(tmp)  # auto-detects GeoJSON
gdf.bins = [2, 1, 1, 1, 3, 1, 6, 4, 8, 4, 3, 3, 1, 3, 3, 1, 1, 2, 2, 1, 5, 6, 3, 1, 1, 2, 1, 1, 1, 2, 7, 1, 4, 3, 1, 3, 1, 1, 3, 7, 2, 2, 2, 2, 1, 1, 3, 2, 2, 2, 1, 0]
gdf = subset(gdf, :name => ByRow(x -> x ∉ ["Alaska", "Hawaii", "Puerto Rico"]))

# Create figure
f = Figure(size=(3200, 2400))
ga = GeoAxis(f[1, 1]; dest="EPSG:5070")
hidedecorations!(ga)

# Use different downsample factors for different bins
# Smaller factors = larger patterns, larger factors = smaller patterns
patternpoly!(ga, gdf.geometry, gdf.bins;
             patterns=[:p313_K, :p315_K, :p317_K, :p319_K, :p601, :p605, :p632, :p634, :p636],
             factors=[6, 6, 6, 6, 4, 4, 4, 4, 4],
             strokewidth=0.5)

f
```

![Demo Map](demo.svg)

## Choropleth Maps with Patterns

The `patternpoly!` function makes it easy to create pattern-based choropleth maps:

```julia
using MakiePatterns, GeoMakie, CairoMakie
using DataFrames, GeoDataFrames

# Load your geospatial data
df = DataFrame(...)  # Must have a geometry column and bins column

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

## Pattern Naming Convention

Patterns are automatically named based on their filename:
- Files starting with digits get a `p` prefix: `701.png` → `:p701`
- Files with descriptive names keep them: `hatch_dense.png` → `:hatch_dense`
- Hyphens and whitespace are converted to underscores: `101-C.png` → `:p101_C`

## Controlling Pattern Scale

The downsample factor controls how large patterns appear:
- **Larger factors** → **smaller patterns** (more repetitions)
- **Smaller factors** → **larger patterns** (fewer repetitions)

```julia
# Small pattern (more tiles)
pat_small = pattern(:p101_C; factor=10)

# Large pattern (fewer tiles)
pat_large = pattern(:p101_C; factor=2)

# Use default factor from patterns.toml
pat_default = pattern(:p101_C)
```

You can also specify different factors for each bin:

```julia
patternpoly!(ga, df.geometry, df.bins;
             patterns=[:p101_C, :p102_C, :p103_C, :p104_C],
             factors=[3, 4, 6, 4])
```

## API Reference

### Pattern Management

- `available_patterns()`: List all registered pattern names
- `register_pattern!(name, filename; default_factor=3)`: Manually register a pattern
- `auto_register_patterns!()`: Auto-register all patterns from artifact (called at module init)

### Pattern Loading

- `make_pattern(name; factor=nothing, cache=true)`: Load and downsample a pattern, returns a matrix
- `pattern(name; factor=nothing, cache=true)`: Create a `Makie.Pattern` object

### Plotting

- `patternpoly!(ax, geoms, bins; patterns, factors=nothing, strokewidth=0.5, cache=true, kwargs...)`:
  Plot geometries with pattern fills based on bin codes

### Cache Management

- `clear_pattern_cache!()`: Clear all cached patterns

## Customizing Default Factors

Edit `assets/patterns/patterns.toml` to set default factors:

```toml
# Global default
default_factor = 3

# Override for specific patterns
["101-C.png"]
factor = 5

["102-C.png"]
factor = 4
```

After modifying, rebuild the artifact:

```julia
using Pkg
Pkg.build("MakiePatterns")
```

## Package Structure

```
MakiePatterns.jl/
├── Project.toml           # Package dependencies
├── Artifacts.toml         # Artifact bindings (auto-generated)
├── README.md
├── src/
│   ├── MakiePatterns.jl   # Main module
│   ├── registry.jl        # Pattern registry
│   ├── cache.jl           # Caching system
│   ├── autoregister.jl    # Auto-discovery
│   ├── loaders.jl         # Pattern loading
│   └── plotting.jl        # Plotting functions
├── assets/patterns/       # Pattern source files (471 PNGs)
│   └── patterns.toml      # Default factor configuration
├── deps/build.jl          # Artifact build script
└── test/runtests.jl       # Test suite
```

## Documentation

Full documentation is available in the `docs/` directory. To build the documentation locally:

```julia
cd("docs/")
using Pkg
Pkg.activate(".")
Pkg.instantiate()
include("make.jl")
```

The built documentation will be available at `docs/build/index.html`.

## Development

### Running Tests

```julia
using Pkg
Pkg.test("MakiePatterns")
```

### Building Documentation

```bash
cd docs
julia --project=. make.jl
```

### Adding New Patterns

1. Add PNG files to `assets/patterns/`
2. Optionally update `assets/patterns/patterns.toml` with custom factors
3. Rebuild the artifact: `Pkg.build("MakiePatterns")`
4. Restart Julia and reload the package

## License

MIT License

## Credits

Pattern assets are derived from the [Federal Geographic Data Committee Digital Cartographic Standard for Geologic Map Symbolization](https://ngmdb.usgs.gov/fgdc_gds/geolsymstd/download.php) by way of Daven Quinn's [github repo](https://github.com/davenquinn/geologic-patterns?tab=License-1-ov-file#readme) under a Creative Commons CC0 License. A pattern chart can be found [here](https://ngmdb.usgs.gov/fgdc_gds/geolsymstd/fgdc-geolsym-patternchart.pdf)
