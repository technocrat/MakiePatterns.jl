"""
Build script for MakiePatterns.jl

This script creates an artifact from the pattern assets in assets/patterns/
and binds it in Artifacts.toml so the patterns can be accessed at runtime.

Run with:
    using Pkg
    Pkg.build("MakiePatterns")

After adding or removing pattern files, re-run this script and commit the updated Artifacts.toml.
"""

using Pkg.Artifacts
using SHA

# Locate the repo root and source directory
repo_root = normpath(joinpath(@__DIR__, ".."))
src_dir = joinpath(repo_root, "assets", "patterns")

if !isdir(src_dir)
    error("Missing patterns directory: $src_dir")
end

artifact_toml = joinpath(repo_root, "Artifacts.toml")

@info "Creating artifact from: $src_dir"

# Create an artifact by copying everything from src_dir
hash = create_artifact() do artifact_dir
    mkpath(artifact_dir)
    patterns_dest = joinpath(artifact_dir, "patterns")
    cp(src_dir, patterns_dest; force=true)
    @info "Copied patterns to artifact: $patterns_dest"
end

# Bind it under the stable name "patterns"
bind_artifact!(artifact_toml, "patterns", hash; force=true)

@info "Successfully bound artifact 'patterns' => $hash"
@info "Artifacts.toml updated at: $artifact_toml"
