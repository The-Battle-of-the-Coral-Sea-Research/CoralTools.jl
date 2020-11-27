
"""
    redirect(action_vec::Vector{<:Vector{<:Action}}, loc)

last MoveTo(old_loc, time) -> MoveTo(new_loc, time)
"""
function redirect(action_vec::Vector{<:Action}, loc)
    return [action_vec[1:end-1]; MoveTo(loc, action_vec[end].time)]
end

# Compatible purpose
redirect(action_vec_vec::Vector{<:Vector{<:Action}}, loc) = redirect.(action_vec_vec, loc)

function append_end(action_vec_vec::Vector{<:Vector{<:Action}}, loc)
    map(append_end, action_vec_vec) do action_vec
        [action_vec[1:end-1]; 
         MoveTo(action_vec[end].pos);
         MoveTo(loc, action_vec[end].time)]
    end
end

"""
    append_end(action_vec::Vector{<:Action}, loc)

last MoveTo(old_loc, time) -> [MoveTo(old_loc), MoveTo(loc, time)]
"""
function append_end(action_vec::Vector{<:Action}, loc)
    return [
        action_vec[1:end-1]; 
        MoveTo(action_vec[end].pos);
        MoveTo(loc, action_vec[end].time)
    ]
end

# Compatible purpose
append_end(action_vec_vec::Vector{<:Vector{<:Action}}, loc) = append_end.(action_vec_vec, loc)

"""
    reset_speed(stpi_vec::Vector{SpatTempPosInt}, speed::Real)

Ignore old timestamp and assign some new timestamps according to assumed uniform speed.
Speed: km/h
"""
function reset_speed(stpi_vec::Vector{SpatTempPosInt}, speed::Real)
    distance_vec = [stpi.d for stpi in stpi_vec]
    distance_sum = sum(distance_vec)
    p_vec = cumsum(distance_vec ./ distance_sum)
    elapsed_ms_value = distance_sum / speed * 3600_000
    elapsed_time_vec = Millisecond.(round.(elapsed_ms_value .* p_vec)) # What a pain, Julia
    time_begin = stpi_vec[1].time
    return [SpatTempPosInt(stpi.longitude, stpi.latitude, time_begin + dt, stpi.d)
            for (stpi, dt) in zip(stpi_vec, elapsed_time_vec)]
end
