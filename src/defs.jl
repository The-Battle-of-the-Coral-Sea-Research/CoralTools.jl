
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

struct ContactReportInt
    cancelled_plan::Tuple{String, Int}
    cancelled_plan_key::String
    time_recv::DateTime
    time_begin::DateTime
    added_plan::Vector{SpatTempPosInt}
end

function ContactReportInt(cr::ContactReport{SpatPos})
    cancelled_plan_key =  encode_group(cr.cancelled_plan)

    elapsed_hours = (cr.time_end - cr.time_begin).value / 3_600_000
    dist = elapsed_hours * cr.speed
    # @show cr.pos cr.angle dist cr.time_begin cr.time_end
    if dist > 0
        action_vec = normal_single_line_search(cr.pos, cr.angle, dist, cr.time_begin, cr.time_end)
        added_plan = Vector{SpatTempPosInt}(action_vec)
    else
        added_plan = Vector{SpatTempPosInt}([
            SpatTempPos(cr.pos.longitude, cr.pos.latitude, cr.time_begin),
            SpatTempPos(cr.pos.longitude, cr.pos.latitude, cr.time_end)
        ])
    end
    return ContactReportInt(cr.cancelled_plan, cancelled_plan_key, cr.time_recv, cr.time_begin, added_plan)
end

function ContactReportInt(cr::ContactReport{RelPos})
    ContactReport(cancel_plan, time_recv, time_begin, time_end, SpatPos(cr.pos), angle, speed) |> ContactReportInt
end

ContactReportInt(cr, stpi_vec_map) = ContactReportInt(cr)

encode_group(s::String, idx::Int) = "$(s)[$(idx)]"
encode_group(s_idx::Tuple{String, Int}) = encode_group(s_idx[1], s_idx[2])

function ContactReportInt(cr::ContactReport{Missing}, stpi_vec_map::Dict{String, Vector{SpatTempPosInt}}) 
    cancelled_plan_key = encode_group(cr.cancelled_plan)
    # added_plan = stpi_vec_map[cancelled_plan_key]
    cancelled_plan = stpi_vec_map[cancelled_plan_key]
    pos = get_pos(cancelled_plan, cr.time_begin)
    cr_new = ContactReport(cr.cancelled_plan, cr.time_recv, cr.time_begin, cr.time_end,
        pos, 
        cr.angle, cr.speed)
    return ContactReportInt(cr_new)
    # return ContactReportInt(cr.cancelled_plan, cancelled_plan_key, cr.time_recv, cr.time_begin, added_plan)
end
