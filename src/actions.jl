

function do_action!(mt::MoveTo{String, DateTime}, as::ActionState, ae::ActionEnv)
    pos = get_pos(ae.fleet_stpi_vec_map[mt.pos], mt.time)
    as.longitude, as.latitude = pos.longitude, pos.latitude
    push!(ae.return_vec, SpatTempPos(pos.longitude, pos.latitude, mt.time))
end

function do_action!(mt::MoveTo{SpatPos, DateTime}, as::ActionState, ae::ActionEnv)
    pos = mt.pos
    as.longitude, as.latitude = pos.longitude, pos.latitude
    push!(ae.return_vec, SpatTempPos(pos.longitude, pos.latitude, mt.time))
end

function do_action!(mt::MoveTo{SpatPos, Nothing}, as::ActionState, ae::ActionEnv)
    pos = mt.pos
    as.longitude, as.latitude = pos.longitude, pos.latitude
    push!(ae.return_vec, SpatTempPos(pos.longitude, pos.latitude))
end

function do_action!(ta::TurnAngleTo, as::ActionState, ae::ActionEnv)
    as.angle = ta.angle
end

function do_action!(ta::TurnAngle, as::ActionState, ae::ActionEnv)
    as.angle = as.angle + ta.angle
end

function do_action!(mf::MoveForward{DateTime}, as::ActionState, ae::ActionEnv)
    longitude, latitude, _ = forward_deg(as.longitude, as.latitude, as.angle, mf.distance)
    as.longitude, as.latitude = longitude, latitude
    push!(ae.return_vec, SpatTempPos(longitude, latitude, mf.time))
end

function do_action!(mf::MoveForward{Nothing}, as::ActionState, ae::ActionEnv)
    longitude, latitude, _ = forward_deg(as.longitude, as.latitude, as.angle, mf.distance)
    as.longitude, as.latitude = longitude, latitude
    push!(ae.return_vec, SpatTempPos(longitude, latitude))
end

# Vector{Action} -> Vector{SpatTempPos}

# deprecated?

function action_vec_to_stp_vec(action_vec::AbstractVector{Action}, fleet_stpi_vec_map)
    as = ActionState(0,0,0)
    ae = ActionEnv(fleet_stpi_vec_map, SpatTempPos[])
    for action in action_vec
        do_action!(action, as, ae)
    end
    return ae.return_vec
end

function Vector{SpatTempPos}(action_vec::AbstractVector{Action}, fleet_stpi_vec_map)
    return action_vec_to_stp_vec(action_vec, fleet_stpi_vec_map)
end

Vector{SpatTempPos}(action_vec::AbstractVector{Action}) = Vector{SpatTempPos}(action_vec, Dict())


function Dict{String, Vector{SpatTempPosInt}}(fleet_trajectory_map::Dict{String, Vector{SpatTempPos}})
    return Dict(
        fleet_name=>Vector{SpatTempPosInt}(stp_vec) 
        for (fleet_name, stp_vec) in fleet_trajectory_map
    )
end

function Dict{String, Vector{SpatTempPosInt}}(scouting_action_group_map::Dict{String, Vector{Vector{Action}}}, fleet_stpi_vec_map::Dict{String, Vector{SpatTempPosInt}})
    rd = Dict{String, Vector{SpatTempPos}}(scouting_action_group_map, fleet_stpi_vec_map)
    return Dict{String, Vector{SpatTempPosInt}}(rd)
end

