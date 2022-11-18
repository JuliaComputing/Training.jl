# Training.jl

## Requirements

- Julia 1.8.2

## Installation Instructions

- From the Julia REPL:

```julia
using Pkg

Pkg.develop(url="https://github.com/JuliaComputing/Training.jl")
```

- From the command line:

```shell
julia -e 'using Pkg; Pkg.develop(url="https://github.com/JuliaComputing/Training.jl")'
```

## Running the notebooks

```julia
using Training

run_pluto()

run_jupyter()
```


## Agenda

1. **Pluto.jl and Julia Basics** (`pluto_notebooks/JuliaTutorial.jl`).
2. **Images as Arrays** (`pluto_notebooks/HyperbolicCorgi.jl`).
3. **Intro to Abstractions** (`pluto_notebooks/Abstraction.jl`).
4. **Julia is Fast** (`jupyter_notebooks/JuliaIsFast.ipynb`).
5. **Automatic Differentiation and Multiple Dispatch** (`jupyter_notebooks/AutoDiff.ipynb`).
6. **Random Walks: Speed and Array Comprehensions** (`pluto_notebooks/RandomWalks.jl`).
7. **Analyzing COVID Data: DataFrames and Geospatial Analysis** (`pluto_notebooks/Analyzing_COVID_Data.jl`)
