

function get_collected_data(fleet_stpi_vec_map::Dict{String, Vector{SpatTempPosInt}})
    get_pos_by_name(name, time) = get_pos(fleet_stpi_vec_map[name], time)

    V(x...) = Vector{Vector{SpatTempPosInt}}(x...)
    V(action_vec_vec::Vector{<:Vector{<:Action}}) = Vector{Vector{SpatTempPosInt}}(action_vec_vec, fleet_stpi_vec_map)

    return get_collected_data(get_pos_by_name, forward_deg, V)
end

