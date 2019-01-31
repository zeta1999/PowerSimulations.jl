function constructdevice!(ps_m::CanonicalModel, category::Type{L}, category_formulation::Type{D}, system_formulation::Type{S}, sys::PSY.PowerSystem; kwargs...) where {L <: PSY.ElectricLoad, D <: PSI.AbstractControllablePowerLoadForm, S <: PM.AbstractPowerFormulation}

        #Defining this outside in order to enable time slicing later
        time_range = 1:sys.time_periods

        fixed_resources = [fs for fs in sys.loads if isa(fs,PSY.PowerLoad)]
    
        controllable_resources = [fs for fs in sys.loads if !isa(fs,PSY.PowerLoad)]
        
        if !isempty(controllable_resources) 
    
            #Variables
            activepowervariables(ps_m, controllable_resources, time_range);
    
            reactivepowervariables(ps_m, controllable_resources, time_range);
    
            #Constraints
            activepower(ps_m, controllable_resources, category_formulation, system_formulation, time_range)
    
            reactivepower(ps_m, controllable_resources, category_formulation, system_formulation, time_range)
    
            #Cost Function
            cost_function(ps_m, controllable_resources, category_formulation, system_formulation)
        
        else 
            @warn("The Data Doesn't Contain Controllable Loads, Consider Changing the Device Formulation to StaticPowerLoad")
    
        end
        
        #add to expression
    
        !isempty(fixed_resources) ? nodal_expression(ps_m, fixed_resources, system_formulation, time_range) : true
    
end

function constructdevice!(ps_m::CanonicalModel, category::Type{L}, category_formulation::Type{D}, system_formulation::Type{S}, sys::PSY.PowerSystem; kwargs...) where {L <: PSY.ElectricLoad, D <: PSI.AbstractControllablePowerLoadForm, S <: PM.AbstractActivePowerFormulation}

    #Defining this outside in order to enable time slicing later
    time_range = 1:sys.time_periods

    fixed_resources = [fs for fs in sys.loads if isa(fs,PSY.PowerLoad)]

    controllable_resources = [fs for fs in sys.loads if !isa(fs,PSY.PowerLoad)]
    
    if !isempty(controllable_resources) 

        #Variables
        activepowervariables(ps_m, controllable_resources, time_range);

        #Constraints
        activepower(ps_m, controllable_resources, category_formulation, system_formulation, time_range)

        #Cost Function
        cost_function(ps_m, controllable_resources, category_formulation, system_formulation)
    
    else 
        @warn("The Data Doesn't Contain Controllable Loads, Consider Changing the Device Formulation to StaticPowerLoad")

    end
    
    #add to expression

    !isempty(fixed_resources) ? nodal_expression(ps_m, fixed_resources, system_formulation, time_range) : true
     
end

function constructdevice!(ps_m::CanonicalModel, category::Type{L}, category_formulation::Type{PSI.StaticPowerLoad}, system_formulation::Type{S}, sys::PSY.PowerSystem; kwargs...) where {L <: PSY.ElectricLoad, S <: PM.AbstractPowerFormulation}

    #Defining this outside in order to enable time slicing later
    time_range = 1:sys.time_periods
    
    nodal_expression(ps_m, sys.loads, system_formulation, time_range)

end