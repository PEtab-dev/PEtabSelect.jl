using Aqua, PEtabSelect

@testset "Aqua" begin
    Aqua.test_ambiguities(PEtabSelect, recursive = false)
    Aqua.test_undefined_exports(PEtabSelect)
    Aqua.test_unbound_args(PEtabSelect)
    Aqua.test_stale_deps(PEtabSelect)
    Aqua.test_deps_compat(PEtabSelect)
    Aqua.find_persistent_tasks_deps(PEtabSelect)
    Aqua.test_piracies(PEtabSelect)
    Aqua.test_project_extras(PEtabSelect)
end
