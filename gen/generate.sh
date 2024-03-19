#!/bin/bash
dir=$(dirname "$0")
julia --project="$dir" "$dir/generator.jl"
