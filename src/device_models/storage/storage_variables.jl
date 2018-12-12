function activepowervariables(ps_m::canonical_model, devices::Array{T,1}, time_range::UnitRange{Int64}) where {T <: PowerSystems.Storage}

    add_variable(ps_m, devices, time_range, "Psin", expression = "var_active", sign = -1)
    add_variable(ps_m, devices, time_range, "Psout",  expression = "var_active")

end

function reactivepowervariables(ps_m::canonical_model, devices::Array{T,1}, time_range::UnitRange{Int64}) where {T <: PowerSystems.Storage}

    add_variable(ps_m, devices, time_range, "Qst",  expression = "var_reactive")

end

function energystoragevariables(ps_m::canonical_model, devices::Array{T,1}, time_range::UnitRange{Int64}) where T <: PowerSystems.Storage

    add_variable(ps_m, devices, time_range, "Est",)

end