module PEtabSelect
using PythonCall: pynew, pycopy!, pyimport, pyconvert, pydict

# To avoid pre-compilation problems
const petab_select = pynew()
function __init__()
    pycopy!(petab_select, pyimport("petab_select"))
end

function import_problem(path)
    return petab_select.Problem.from_yaml(path)
end

function get_iteration_info(select_problem, iteration_results, first_iteration::Bool)
    if first_iteration
        return petab_select.ui.start_iteration(problem = select_problem)
    else
        candidate_space = iteration_results[petab_select.constants.CANDIDATE_SPACE]
        return petab_select.ui.start_iteration(
            problem = select_problem, candidate_space = candidate_space)
    end
end

function get_iteration_results(select_problem, iteration)
    return petab_select.ui.end_iteration(problem = select_problem,
        candidate_space = iteration[petab_select.constants.CANDIDATE_SPACE],
        calibrated_models = iteration[petab_select.constants.UNCALIBRATED_MODELS])
end

function get_best_model(select_problem, iteration_results)
    return petab_select.ui.get_best(problem = select_problem,
        models = iteration_results[petab_select.constants.CANDIDATE_SPACE].calibrated_models)
end

function get_n_new_models(iteration)
    return length(iteration[petab_select.constants.UNCALIBRATED_MODELS])
end

function get_uncalibrated_models(iteration)
    return iteration[petab_select.constants.UNCALIBRATED_MODELS]
end

function set_criterion!(model, select_problem, nllh)::Nothing
    model.set_criterion(petab_select.Criterion.NLLH, nllh)
    _ = model.get_criterion(select_problem.criterion, compute = true)
    return nothing
end

function set_parameters!(model, x::Dict{Symbol, Float64})::Nothing
    isempty(x) && return nothing
    # x must be a PyDict
    _x = Dict(string.(collect(keys(x))) .=> values(x)) |>
         pydict
    model.estimated_parameters = _x
    return nothing
end

function get_model_subspace_id(model)::String
    return pyconvert(String, model.model_subspace_id)
end

function get_model_parameters(model)::Dict{Symbol, Union{Float64, String}}
    if isempty(model.parameters)
        return Dict{Symbol, Float64}()
    else
        return pyconvert(Dict{Symbol, Union{Float64, String}}, model.parameters)
    end
end

function write_model_info(model, path_save)
    model.to_yaml(path_save)
    return nothing
end

end
