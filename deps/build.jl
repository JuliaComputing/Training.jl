using Pkg
using Pluto

dir = joinpath(@__DIR__, "..", "pluto_notebooks")

for file in readdir(dir)
    Pluto.activate_notebook_environment(joinpath(dir, file))
    Pkg.instantiate()
end
