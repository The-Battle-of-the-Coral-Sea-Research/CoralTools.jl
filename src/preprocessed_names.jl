
"""
    module Preprocessed

Inject some names into session to simplify interaction.
"""
module PreprocessedNames

using ..CoralTools
using ..CoralTools: fleet_trajectory_map, get_collected_data
using CoralData: scouting_action_group_map

export fleet_stpi_vec_map, land_based_stpi_vec_group_map, land_based_stpi_vec_map,
    carrier_based_stpi_vec_group_map, carrier_based_stpi_vec_map, ijn_name_vec,
    ijn_fleet_stpi_vec_map, ijn_stpi_vec_map

fleet_stp_vec_map = fleet_trajectory_map
fleet_stpi_vec_map = Dict{String, Vector{SpatTempPosInt}}(fleet_trajectory_map)

land_based_stpi_vec_group_map = get_collected_data(fleet_stpi_vec_map)
land_based_stpi_vec_map = Dict{String, Vector{SpatTempPosInt}}(land_based_stpi_vec_group_map)

carrier_based_stpi_vec_group_map = Dict{String, Vector{Vector{SpatTempPosInt}}}(scouting_action_group_map, fleet_stpi_vec_map)  
carrier_based_stpi_vec_map = Dict{String, Vector{SpatTempPosInt}}(carrier_based_stpi_vec_group_map)

ijn_name_vec = ["MO Carrier Striking Force", "Covering Force", "MO Main Force", "MO Invasion Force"]
ijn_fleet_stpi_vec_map = Dict(ijn_name=>fleet_stpi_vec_map[ijn_name] for ijn_name in ijn_name_vec)

ijn_stpi_vec_map = Dict(land_based_stpi_vec_map..., carrier_based_stpi_vec_map..., ijn_fleet_stpi_vec_map...)

end