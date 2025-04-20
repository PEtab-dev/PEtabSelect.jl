using PEtabSelect, Test, YAML

#=
    # Test that all functions behave as expected
=#

# Test correctly imported values
test_case = "0001"
path_yaml = joinpath(@__DIR__, "petab_select", test_case, "petab_select_problem.yaml")
problem = PEtabSelect.import_problem(path_yaml)
@test string(problem.criterion) == "Criterion.AIC"
@test string(problem.method) == "Method.BRUTE_FORCE"

# Test can generate candidate space
iteration = PEtabSelect.get_iteration_info(problem, nothing, true)
n_models = PEtabSelect.get_n_new_models(iteration)
@test n_models == 1
uncalibrated_models = PEtabSelect.get_uncalibrated_models(iteration)

# Test can read model information
model = uncalibrated_models[0]
subspace_id = PEtabSelect.get_model_subspace_id(model)
model_parameters = PEtabSelect.get_model_parameters(model)
@test subspace_id == "M1_1"
@test model_parameters == Dict(:k1 => 0.2, :k2 => 0.1, :k3 => 0.0)

# Test can set model values
xbest = Dict(:k1 => 0.2, :k2 => 0.1, :k3 => 0.2)
PEtabSelect.set_criterion!(model, problem, -4.087702752023436)
PEtabSelect.set_parameters!(model, xbest)

# Test termination, and correct export of files
iteration_result = PEtabSelect.get_iteration_results(problem, iteration)
iteration = PEtabSelect.get_iteration_info(problem, iteration_result, false)
n_models = PEtabSelect.get_n_new_models(iteration)
@test n_models == 0
iteration_result = PEtabSelect.get_iteration_results(problem, iteration)
best_model = PEtabSelect.get_best_model(problem, iteration_result)
path_results = joinpath(@__DIR__, "results.yaml")
PEtabSelect.write_model_info(best_model, path_results)
results = YAML.load_file(path_results)
@test results["model_subspace_id"] == "M1_1"
@test results["estimated_parameters"] == Dict("k3"=>0.2, "k1"=>0.2, "k2"=>0.1)
@test results["criteria"] == Dict("AIC" => -6.175405504046871, "NLLH" => -4.087702752023436)
rm(path_results)
