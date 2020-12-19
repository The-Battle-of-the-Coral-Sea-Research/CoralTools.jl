
function make_sector_search_lines_geo(base_long, base_lat, deg_start, deg_end, radius, num;
                                      search_lines)
    deg_vec = get_deg_vec(deg_start, deg_end, num; search_lines)
    long_lat_vec = forward_deg.(base_long, base_lat, deg_vec, radius)
    long_vec = map(long_lat->long_lat[1], long_lat_vec)
    lat_vec = map(long_lat->long_lat[2], long_lat_vec)
    return long_vec, lat_vec
end

function make_sector_search_lines_geo(ssp::SectorSearchPlan; search_lines, num=nothing)
    if num === nothing
        num = ssp.num
    end
    return make_sector_search_lines_geo(ssp.base.longitude, ssp.base.latitude,
        ssp.bearing[1], ssp.bearing[2], ssp.distance, num; search_lines)
end


@recipe function plot_plan(plan::Dict{String, SectorSearchPlan}; color=:yellow, particles=100, alpha=0.25, 
                           include_search_lines=false, search_lines_alpha=0.25, search_lines_color=:blue, 
                           include_sector_name=false, sector_name_outer_percent=0.1)
    for (name, ssp) in plan
        base_long = ssp.base.longitude
        base_lat = ssp.base.latitude

        #=
        long_vec, lat_vec = make_sector_search_lines_geo(base_long, base_lat, 
            ssp.bearing[1], ssp.bearing[2], ssp.distance, particles, search_lines=false) # num=2, search_lines=false will select min, max directions
        =#
        long_vec, lat_vec = make_sector_search_lines_geo(ssp; search_lines=false, num=particles)
        @series begin
            seriestype  --> :shape
            seriesalpha --> alpha
            seriescolor --> color
            [base_long; long_vec], [base_lat; lat_vec]
        end
        if include_search_lines
            #=
            long_s_vec, lat_s_vec = make_sector_search_lines_geo(base_long, base_lat, 
                ssp.bearing[1], ssp.bearing[2], ssp.distance, ssp.num, search_lines=true)
            =#
            long_s_vec, lat_s_vec = make_sector_search_lines_geo(ssp; search_lines=true)
            for (long_end, lat_end) in zip(long_s_vec, lat_s_vec)
                @series begin
                    seriesalpha --> search_lines_alpha
                    seriescolor --> search_lines_color
                    [base_long, long_end], [base_lat, lat_end]
                end
            end
        end
        if include_sector_name
            @series begin
                p = sector_name_outer_percent
                long_text = base_long * (1-p) + p * mean(long_vec)
                lat_text = base_lat * (1-p) + p * mean(lat_vec)
                markersize --> 0
                Dict(name => SpatPos(long_text, lat_text))
            end
        end
    end
end

@recipe function plot_fleet_stpi_vec_map(fleet_stpi_vec_map::Dict{String, Vector{SpatTempPosInt}}, t::DateTime;
                    font=nothing, show_label=true)#, markersize=2) 
    # font ex: Plots.font("Sans", 4),
    # while it's better that Recipes provides an attribute to manipuate the annotation font size.
    longitude_vec = Float64[]
    latitude_vec = Float64[]
    fleet_name_vec = String[]
    for (fleet_name, stpi_vec) in fleet_stpi_vec_map
        if !contains(stpi_vec, t)
            continue
        end
        pos = get_pos(stpi_vec, t)
        push!(longitude_vec, pos.longitude)
        push!(latitude_vec, pos.latitude)
        push!(fleet_name_vec, fleet_name)
    end
    if show_label
        @series begin
            seriestype --> :scatter
            label --> false
            series_annotations := (fleet_name_vec, font)
            longitude_vec, latitude_vec
        end
    end
end

@recipe function plot_fleet_stpi_vec_map(fleet_stpi_vec_map::Dict{String, Vector{SpatTempPosInt}}, t1::DateTime, t2::DateTime;
                   font=nothing, step=Minute(10), full_only=false, show_label=true)
    t_vec_ref = t1:step:t2
    for (fleet_name, stpi_vec) in fleet_stpi_vec_map
        if full_only # consider only the path which covered the specified interval fully.
            if !contains(stpi_vec, t1, t2)
                continue
            end
            t_vec = t_vec_ref
        else
            if (t_vec_ref[end] < stpi_vec[1].time) | (stpi_vec[end].time < t_vec_ref[1])
                continue
            end
            t_vec = filter(t -> (t >= stpi_vec[1].time) & (t <= stpi_vec[end].time), t_vec_ref)
            if length(t_vec) == 0 # interval is too small
                continue
            end
        end
        # pos_vec = [get_pos(stpi_vec, t) for t in t1:step:t2]
        pos_vec = get_pos(stpi_vec, t_vec)
        longitude_vec = map(x->x.longitude, pos_vec)
        latitude_vec = map(x->x.latitude, pos_vec)
        @series begin
            label --> false
            longitude_vec, latitude_vec
        end
        @series begin
            seriestype --> :scatter
            label --> false
            # @show fleet_name longitude_vec latitude_vec
            longitude_vec, latitude_vec
        end
        if show_label
            @series begin
                seriestype --> :scatter
                seriesalpha --> 0
                series_annotations := ([fleet_name], font)
                [longitude_vec[end]], [latitude_vec[end]]
            end
        end
    end
end


# User Recipes implementation, which is flexible but Type Recipes match our purpose better. 

# `font=nothing, step=Minute(10), full_only=false` is not needed? Since downstream recipe will give the value ever?

@recipe function plot_fleet_stpi_vec_map(fleet_stpi_vec_vec::Vector{Vector{SpatTempPosInt}}, t1::DateTime, t2::DateTime
    )
    #;font=nothing, step=Minute(10), full_only=false)
    temp_dict = Dict("$(idx)"=>v for (idx, v) in enumerate(fleet_stpi_vec_vec))

    #=
    font --> font
    step --> step
    full_only --> full_only
    =#
    show_label --> false
    
    return temp_dict, t1, t2 #; font, step, full_only, show_label=false
end


#=
# The Type Recipes implementation

# Why does it not work? I guess that Type Recipes should be a (x,y,z) -> (x,f(y), z) mapping?

@recipe function fleet_stpi_vec_vec_to_fleet_stpi_vec_map(
        ::Type{Vector{Vector{SpatTempPosInt}}}, fleet_stpi_vec_vec::Vector{Vector{SpatTempPosInt}}
    )
    temp_dict = Dict("$(idx)"=>v for (idx, v) in enumerate(fleet_stpi_vec_vec))
    return temp_dict
end
=#

@recipe function plot_fleet_stpi_vec_map(fleet_stpi_vec_vec::Vector{Vector{SpatTempPosInt}}, t::DateTime)
    #;font=nothing, step=Minute(10), full_only=false)
    temp_dict = Dict("$(idx)"=>v for (idx, v) in enumerate(fleet_stpi_vec_vec))

    show_label --> false
    
    return temp_dict, t #; font, step, full_only, show_label=false
end
