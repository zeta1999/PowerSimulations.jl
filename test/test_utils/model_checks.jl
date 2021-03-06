const GAEVF = JuMP.GenericAffExpr{Float64, VariableRef}
const GQEVF = JuMP.GenericQuadExpr{Float64, VariableRef}

function moi_tests(
    op_problem::OperationsProblem,
    params::Bool,
    vars::Int,
    interval::Int,
    lessthan::Int,
    greaterthan::Int,
    equalto::Int,
    binary::Bool,
)
    JuMPmodel = op_problem.psi_container.JuMPmodel
    @test (:params in keys(JuMPmodel.ext)) == params
    @test JuMP.num_variables(JuMPmodel) == vars
    @test JuMP.num_constraints(JuMPmodel, GAEVF, MOI.Interval{Float64}) == interval
    @test JuMP.num_constraints(JuMPmodel, GAEVF, MOI.LessThan{Float64}) == lessthan
    @test JuMP.num_constraints(JuMPmodel, GAEVF, MOI.GreaterThan{Float64}) == greaterthan
    @test JuMP.num_constraints(JuMPmodel, GAEVF, MOI.EqualTo{Float64}) == equalto
    @test ((JuMP.VariableRef, MOI.ZeroOne) in JuMP.list_of_constraint_types(JuMPmodel)) ==
          binary

    return
end

function psi_constraint_test(
    op_problem::OperationsProblem,
    constraint_names::Vector{Symbol},
)
    for con in constraint_names
        @test !isnothing(get(op_problem.psi_container.constraints, con, nothing))
    end
    return
end

function psi_checkbinvar_test(
    op_problem::OperationsProblem,
    bin_variable_names::Vector{Symbol},
)
    for variable in bin_variable_names
        for v in PSI.get_variable(op_problem.psi_container, variable)
            @test JuMP.is_binary(v)
        end
    end
    return
end

function psi_checkobjfun_test(op_problem::OperationsProblem, exp_type)
    @test JuMP.objective_function_type(op_problem.psi_container.JuMPmodel) == exp_type
    return
end

function moi_lbvalue_test(op_problem::OperationsProblem, con_name::Symbol, value::Number)
    for con in op_problem.psi_container.constraints[con_name]
        @test JuMP.constraint_object(con).set.lower == value
    end
    return
end

function psi_checksolve_test(op_problem::OperationsProblem, status)
    JuMP.optimize!(op_problem.psi_container.JuMPmodel)
    @test termination_status(op_problem.psi_container.JuMPmodel) in status
end

function psi_checksolve_test(
    op_problem::OperationsProblem,
    status,
    expected_result,
    tol = 0.0,
)
    res = solve!(op_problem)
    @test termination_status(op_problem.psi_container.JuMPmodel) in status
    @test isapprox(get_total_cost(res)[:OBJECTIVE_FUNCTION], expected_result, atol = tol)
end

function psi_ptdf_lmps(op_problem::OperationsProblem, ptdf)
    res = solve!(op_problem)
    λ = convert(Array, res.dual_values[:CopperPlateBalance])
    μ = convert(Array, res.dual_values[:network_flow])
    buses = get_components(Bus, op_problem.sys)
    lmps = OrderedDict()
    for bus in buses
        lmps[get_name(bus)] = μ * ptdf[:, get_number(bus)]
    end
    lmps = DataFrame(lmps)
    lmps = λ .- lmps
    return lmps[!, sort(propertynames(lmps))]
end

function check_variable_unbounded(op_problem::OperationsProblem, var_name)
    psi_cont = PSI.get_psi_container(op_problem)
    variable = PSI.get_variable(psi_cont, var_name)
    for var in variable
        if JuMP.has_lower_bound(var) || JuMP.has_upper_bound(var)
            return false
        end
    end
    return true
end
