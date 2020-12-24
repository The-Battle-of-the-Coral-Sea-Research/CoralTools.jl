
take_time_recv(x::DateTime) = x
take_time_recv(x::ContactReportInt) = x.time_recv

function _make_observations(time_begin::DateTime, time_end::DateTime, step::ST,
        stpi_vec_map::Dict{String, Vector{SpatTempPosInt}},
        cri_vec_vec::Vector{Vector{ContactReportInt}}) where ST <: Period
    t_vec_ref = time_begin:step:time_end
    cancelled_map = Dict{String, DateTime}()
    added_map = Dict{String, Vector{SpatTempPosInt}}()
    for cri_vec in cri_vec_vec
        # @show cri_vec time_end
        # cri_vec[1] |> dump
        cri_idx = searchsortedlast(cri_vec, time_end, by=take_time_recv)
        if cri_idx == 0
            continue
        end
        cri = cri_vec[cri_idx]
        # cri |> dump
        if length(cri.added_plan) == 0
            continue
        end
        #=
        if cri.time_begin == cri.time_end # Cancel, ex: the MO Striking Force scouting at morning of 7 May 
            continue
        end
        =#
        cancelled_map[cri.cancelled_plan_key] = cri.time_begin
        added_map[cri.cancelled_plan_key] = cri.added_plan
    end
    neg_map = Dict{String, StepRange{DateTime, ST}}()
    for (stpi_vec_key, stpi_vec) in stpi_vec_map
        time_cut = get(cancelled_map, stpi_vec_key, nothing)
        if isnothing(time_cut)
            time_cut = time_end
        end
        idx_begin = searchsortedfirst(t_vec_ref, max(time_begin, stpi_vec[1].time)) # t_vec_ref will not be "collected" from this line.
        idx_end = searchsortedlast(t_vec_ref, min(time_cut, stpi_vec[end].time))
        if (idx_end == 0) | (idx_begin > length(t_vec_ref))
            continue
        end
        neg_map[stpi_vec_key] = t_vec_ref[idx_begin]:step:t_vec_ref[idx_end]
    end
    pos_map = Dict{String, StepRange{DateTime, ST}}()
    for (stpi_vec_key, stpi_vec) in added_map
        idx_begin = searchsortedfirst(t_vec_ref, max(time_begin, stpi_vec[1].time)) # t_vec_ref will not be "collected" from this line.
        idx_end = searchsortedlast(t_vec_ref, min(time_end, stpi_vec[end].time))
        if (idx_end == 0) | (idx_begin > length(t_vec_ref))
            continue
        end
        # @show (idx_begin, step, idx_end, length(t_vec_ref))
        pos_map[stpi_vec_key] = t_vec_ref[idx_begin]:step:t_vec_ref[idx_end]
    end
    return neg_map, pos_map, cancelled_map, added_map
end

function get_pos_with_time(tv_map, stpi_vec_map)
    spt_vec_map = Dict{String, Vector{SpatTempPos}}()
    for (stpi_vec_key, tv) in tv_map
        # @show stpi_vec_key stpi_vec_map[stpi_vec_key] tv
        sp_vec = get_pos(stpi_vec_map[stpi_vec_key], tv)
        spt_vec = [SpatTempPos(sp.longitude, sp.latitude, t) for (sp, t) in zip(sp_vec, tv)]
        spt_vec_map[stpi_vec_key] = spt_vec
    end
    return spt_vec_map
end

function make_observations(time_range::StepRange{DateTime, T}, stpi_vec_map, cri_vec_vec) where T <: Period
    time_begin = time_range.start
    time_end = time_range.stop
    step = time_range.step
    neg_map, pos_map, cancelled_map, added_map = _make_observations(time_begin, time_end, step, stpi_vec_map, cri_vec_vec)
    
    neg_spt_vec_map = get_pos_with_time(neg_map, stpi_vec_map)
    pos_spt_vec_map = get_pos_with_time(pos_map, added_map)
    
    return neg_spt_vec_map, pos_spt_vec_map
end

function DataFrame(spt_vec_map::Dict{String, Vector{SpatTempPos}})
    df = DataFrame(Iterators.flatten(values(spt_vec_map)))
    df.key = Iterators.flatten(repeat([key], length(value)) for (key, value) in spt_vec_map) |> collect |> categorical
    return df
    # df_neg[!, :obs] .= -1.
end

function DataFrame(spt_vec_map, obs)
    df = DataFrame(spt_vec_map)
    df[!, :obs] .= obs
    return df
end

function DataFrame(time_range::StepRange{DateTime, <:Period}, stpi_vec_map::Dict{String, Vector{SpatTempPosInt}}, 
                   cri_vec_vec::Vector{Vector{ContactReportInt}})
    neg_spt_vec_map, pos_spt_vec_map = make_observations(time_range, stpi_vec_map, cri_vec_vec)
    df = [DataFrame(neg_spt_vec_map, -1.); DataFrame(pos_spt_vec_map, 1.)]
    return df
end

function DataFrame(time_range::StepRange{DateTime, <:Period}, stpi_vec_map::Dict{String, Vector{SpatTempPosInt}})
    return DataFrame(time_range, stpi_vec_map, Vector{ContactReportInt}[])
end



#=

# Given neg_spt_vec_map, pos_spt_vec_map

using DataFrames

df_neg = DataFrame(Iterators.flatten(values(neg_spt_vec_map)))
df_neg.key = Iterators.flatten(repeat([key], length(value)) for (key, value) in neg_spt_vec_map) |> collect |> categorical

=#

