"""
Auto-registration of patterns from the artifact directory.

This module provides functionality to automatically discover and register
all pattern files in the package's artifact directory.
"""

using TOML

# Allowed file extensions for pattern files
const _ALLOWED_EXTS = Set([".png", ".jpg", ".jpeg", ".tif", ".tiff", ".bmp"])

"""
    _pattern_symbol_from_filename(filename::AbstractString)

Convert a filename to a pattern symbol name.

# Rules
- Numeric filenames get prefixed with 'p': "701.png" → :p701
- Whitespace and hyphens are converted to underscores
- "101-C.png" → :p101_C
- Otherwise, the stem is used as-is: "hatch_dense.png" → :hatch_dense

# Examples
```julia
_pattern_symbol_from_filename("701.png")        # :p701
_pattern_symbol_from_filename("101-C.png")      # :p101_C
_pattern_symbol_from_filename("hatch_dense.png")  # :hatch_dense
```
"""
function _pattern_symbol_from_filename(filename::AbstractString)::Symbol
    stem = splitext(basename(filename))[1]
    # Replace whitespace and hyphens with underscores for valid Julia symbols
    stem_norm = replace(stem, r"[\\s-]+" => "_")
    if !isempty(stem_norm) && isdigit(first(stem_norm))
        return Symbol("p" * stem_norm)
    else
        return Symbol(stem_norm)
    end
end

"""
    _patterns_root()

Get the root directory containing pattern assets from the artifact.
"""
_patterns_root() = joinpath(artifact"patterns", "patterns")

"""
    load_pattern_defaults(; filename="patterns.toml")

Load default downsample factors from a TOML file in the patterns artifact.

# TOML Format
```toml
default_factor = 3

["701.png"]
factor = 3

["610.png"]
factor = 4
```

# Returns
A `Dict{String,Int}` mapping filenames to their default factors.
The special key `"__DEFAULT__"` contains the global default factor if specified.

# Examples
```julia
defaults = load_pattern_defaults()
factor = get(defaults, "701.png", 3)
```
"""
function load_pattern_defaults(; filename::AbstractString="patterns.toml")
    root = _patterns_root()
    path = joinpath(root, filename)
    if !isfile(path)
        return Dict{String,Int}()  # no metadata file is fine
    end

    t = TOML.parsefile(path)

    defaults = Dict{String,Int}()
    # optional global default
    global_default = get(t, "default_factor", nothing)

    for (k, v) in t
        if k == "default_factor"
            continue
        end
        if v isa Dict && haskey(v, "factor")
            defaults[String(k)] = Int(v["factor"])
        end
    end

    # stash global default under a special key (used by auto-register)
    if global_default !== nothing
        defaults["__DEFAULT__"] = Int(global_default)
    end

    return defaults
end

"""
    auto_register_patterns!(; defaults=load_pattern_defaults(), overwrite=true)

Scan the patterns artifact directory and register all eligible pattern files.

# Arguments
- `defaults::Dict{String,Int}`: Maps filenames to default downsample factors
- `overwrite::Bool=true`: If true, overwrites existing registrations

# Returns
A sorted list of all registered pattern names.

# Examples
```julia
# Auto-register all patterns with defaults from patterns.toml
auto_register_patterns!()

# Get list of available patterns
patterns = available_patterns()
```
"""
function auto_register_patterns!(;
        defaults::Dict{String,Int}=load_pattern_defaults(),
        overwrite::Bool=true
    )

    root = _patterns_root()
    isdir(root) || error("Patterns artifact directory not found: $root")

    fallback = get(defaults, "__DEFAULT__", 3)

    # deterministic order
    files = sort(readdir(root; join=false))
    for fn in files
        full = joinpath(root, fn)
        isfile(full) || continue
        ext = lowercase(splitext(fn)[2])
        ext in _ALLOWED_EXTS || continue

        name = _pattern_symbol_from_filename(fn)
        factor = get(defaults, fn, fallback)

        if overwrite || !haskey(_REGISTRY, name)
            register_pattern!(name, fn; default_factor=factor)
        end
    end

    return available_patterns()
end
