using SafeTestsets

@safetestset "Aqua Quality Check" begin
    include("aqua.jl")
end

@safetestset "Problem import" begin
    include("import.jl")
end
