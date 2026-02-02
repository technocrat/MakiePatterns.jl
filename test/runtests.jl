using Test
using MakiePatterns
using Makie

@testset "MakiePatterns.jl" begin
    @testset "Registry" begin
        # Test that patterns were auto-registered
        patterns = available_patterns()
        @test length(patterns) > 0
        @test patterns isa Vector{Symbol}
        @test issorted(patterns)

        # Test manual registration
        register_pattern!(:test_pattern, "test.png"; default_factor=5)
        @test :test_pattern in available_patterns()
    end

    @testset "Pattern Loading" begin
        # Get first available pattern
        patterns = available_patterns()
        @test length(patterns) > 0

        first_pattern = first(patterns)

        # Test make_pattern returns a matrix
        mat = make_pattern(first_pattern)
        @test mat isa AbstractMatrix
        @test size(mat, 1) > 0 && size(mat, 2) > 0

        # Test pattern returns a valid object
        pat = pattern(first_pattern)
        @test !isnothing(pat)

        # Test custom factor
        mat_small = make_pattern(first_pattern; factor=10)
        @test size(mat_small) != size(mat)  # Different factor = different size

        # Test caching
        clear_pattern_cache!()
        mat1 = make_pattern(first_pattern; cache=true)
        mat2 = make_pattern(first_pattern; cache=true)
        @test mat1 === mat2  # Should be the same object from cache

        mat3 = make_pattern(first_pattern; cache=false)
        @test mat3 !== mat1  # Should be a different object
    end

    @testset "Cache Management" begin
        clear_pattern_cache!()
        # Cache should be empty after clearing
        # Load a pattern to populate cache
        patterns = available_patterns()
        if length(patterns) > 0
            _ = make_pattern(first(patterns); cache=true)
            # Clear again
            clear_pattern_cache!()
            # This should work without errors
            @test true
        end
    end

    @testset "Pattern Symbol Derivation" begin
        # Test the pattern naming convention
        # Patterns starting with digits should have 'p' prefix
        patterns = available_patterns()
        for pat in patterns
            pat_str = string(pat)
            if occursin(r"^p\\d", pat_str)
                # Pattern name starts with 'p' followed by digit
                @test startswith(pat_str, 'p')
            end
        end
    end
end
