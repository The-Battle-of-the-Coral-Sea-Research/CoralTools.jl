
const EARTH_RADIUS = 6372.8

#=
# Reference, defined in CoralData

struct SpatTempPos
    longitude::Float64 # longitude
    latitude::Float64 # latitude
    time::DateTime # time stamp
    has_time::Bool
end
=#

struct SpatTempPosInt # Interpolated SpatTempPos
    longitude::Float64 # longitude
    latitude::Float64 # latitude
    time::DateTime # time stamp
    d::Float64
end

# Action inner state 

mutable struct ActionState
    longitude::Float64
    latitude::Float64
    angle::Float64
end

struct ActionEnv{DT}
    fleet_stpi_vec_map::DT
    return_vec::Vector{SpatTempPos}
end
