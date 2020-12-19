
"""
    module Preprocessed

Inject some names into session to simplify interaction.
"""
module PreprocessedNames

using ..CoralTools
using ..CoralTools: fleet_trajectory_map, get_collected_data, ContactReportInt, make_observations
using CoralData: scouting_action_group_map, contact_report_vec_vec, CT
using Dates: Minute
using DataFrames

export fleet_stpi_vec_map, land_based_stpi_vec_group_map, land_based_stpi_vec_map,
    carrier_based_stpi_vec_group_map, carrier_based_stpi_vec_map, ijn_name_vec,
    ijn_fleet_stpi_vec_map, ijn_stpi_vec_map, cr_vec_vec, cri_vec_vec,
    neg_spt_vec_map, pos_spt_vec_map, df

fleet_stp_vec_map = fleet_trajectory_map
fleet_stpi_vec_map = Dict{String, Vector{SpatTempPosInt}}(fleet_trajectory_map)

land_based_stpi_vec_group_map = get_collected_data(fleet_stpi_vec_map)
land_based_stpi_vec_map = Dict{String, Vector{SpatTempPosInt}}(land_based_stpi_vec_group_map)

carrier_based_stpi_vec_group_map = Dict{String, Vector{Vector{SpatTempPosInt}}}(scouting_action_group_map, fleet_stpi_vec_map)  
carrier_based_stpi_vec_map = Dict{String, Vector{SpatTempPosInt}}(carrier_based_stpi_vec_group_map)

ijn_name_vec = ["MO Carrier Striking Force", "Covering Force", "MO Main Force", "MO Invasion Force"]
ijn_fleet_stpi_vec_map = Dict(ijn_name=>fleet_stpi_vec_map[ijn_name] for ijn_name in ijn_name_vec)

ijn_stpi_vec_map = Dict(land_based_stpi_vec_map..., carrier_based_stpi_vec_map..., ijn_fleet_stpi_vec_map...)

cr_vec_vec = contact_report_vec_vec
cri_vec_vec = [[ContactReportInt(cr, ijn_stpi_vec_map) for cr in cr_vec] for cr_vec in cr_vec_vec]
neg_spt_vec_map, pos_spt_vec_map = make_observations(CT(3, 0, 0):Minute(10):CT(9, 0, 0), ijn_stpi_vec_map, cri_vec_vec)

#=
df_neg = DataFrame(Iterators.flatten(values(neg_spt_vec_map)))
df_neg.key = Iterators.flatten(repeat([key], length(value)) for (key, value) in neg_spt_vec_map) |> collect |> categorical
df_neg[!, :obs] .= -1.
=#

df_neg = DataFrame(neg_spt_vec_map, -1.)

#=
df_pos = DataFrame(Iterators.flatten(values(pos_spt_vec_map)))
df_pos.key = Iterators.flatten(repeat([key], length(value)) for (key, value) in pos_spt_vec_map) |> collect |> categorical
df_pos[!, :obs] .= 1.
=#

df_pos = DataFrame(pos_spt_vec_map, 1.)


df = [df_neg; df_pos]

end