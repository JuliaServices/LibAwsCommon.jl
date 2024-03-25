#!/bin/bash
dir=$(dirname "$0")
julia --project="$dir" 'using Pkg; Pkg.instantiate()'
julia --project="$dir" "$dir/generator.jl"
