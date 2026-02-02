"""
Pattern registry for managing named patterns.

The registry maps pattern names (Symbols) to tuples of (filename, default_factor).
"""
const _REGISTRY = Dict{Symbol,Tuple{String,Int}}()  # name => (filename, default_factor)

"""
    register_pattern!(name::Symbol, filename::AbstractString; default_factor::Int=3)

Register a pattern with a given name, filename, and default downsample factor.

# Arguments
- `name::Symbol`: The pattern name (e.g., `:p701`)
- `filename::AbstractString`: The pattern filename (e.g., "701.png")
- `default_factor::Int=3`: Default downsample factor (larger = smaller pattern)

# Returns
The pattern name symbol.

# Examples
```julia
register_pattern!(:p701, "701.png"; default_factor=3)
```
"""
function register_pattern!(name::Symbol, filename::AbstractString; default_factor::Int=3)
    _REGISTRY[name] = (String(filename), default_factor)
    return name
end

"""
    available_patterns()

Return a sorted vector of all registered pattern names.

# Examples
```julia
patterns = available_patterns()
# [:p601, :p610, :p643, ...]
```
"""
available_patterns() = sort!(collect(keys(_REGISTRY)))

"""
    _lookup(name::Symbol)

Internal function to lookup a pattern in the registry.
Throws ArgumentError if the pattern is not found.
"""
function _lookup(name::Symbol)
    haskey(_REGISTRY, name) || throw(ArgumentError("Unknown pattern: $name. Available: $(available_patterns())"))
    return _REGISTRY[name]
end
