using BinaryProvider

products = Product[
  LibraryProduct(
    joinpath(expanduser("~"), "usr", "local", "lib"), "libpsapi", :libps
  ),
]

if any(!satisfied(p) for p in products)
  error("POLO PS-API is not installed properly on your system.")
end

write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
