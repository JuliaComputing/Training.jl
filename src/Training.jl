module Training

export run_jupyter, run_pluto

using IJulia: IJulia
using Pluto: Pluto

run_jupyter() = IJulia.notebook(dir = joinpath(@__DIR__, "..", "jupyter_notebooks"))

run_pluto() = cd(joinpath(@__DIR__, "..", "pluto_notebooks")) do
    Pluto.run(n)
end

end
