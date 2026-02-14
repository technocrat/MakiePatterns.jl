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
             factors=[6, 6, 6, 6, 4, 4, 4, 4, 4],  # Progressively smaller patterns
             strokewidth=0.5)

f
