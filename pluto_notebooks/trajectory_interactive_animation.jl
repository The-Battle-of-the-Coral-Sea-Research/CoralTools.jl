### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 197bebe6-287e-11eb-2933-cb9828acea28
using Revise

# ╔═╡ 4d4303ec-287e-11eb-13b7-b363677a79f8
using PhysicalVectorsData

# ╔═╡ 501139a4-287e-11eb-351c-ef37927f3e92
using CoralData

# ╔═╡ 5217bd20-287e-11eb-1f8c-5bd26ffa5dc9
using CoralTools

# ╔═╡ 54313a66-287e-11eb-0671-49cfd4d74aca
using Plots

# ╔═╡ 743b8f5a-287e-11eb-2001-654f5f93719d
using Dates

# ╔═╡ 4395e4e6-2896-11eb-187e-4db9dbc90a2b
using PlutoUI

# ╔═╡ 5ffd8b40-287e-11eb-2db6-49eabf586be0
left, bottom, right, top = 145, -25, 170, 0

# ╔═╡ 62104d2a-287e-11eb-3299-fda3b191c6ef
sp50 = load_shapefile()

# ╔═╡ 66d18c78-287e-11eb-3e09-750baacd9fa7
sp_coral = filter_shape(sp50, left, bottom, right, top)

# ╔═╡ 5664eb16-287e-11eb-0a8a-9bb00a8b6bab
let
	plot(sp_coral, xlims=(left, right), ylim=(bottom, top))
	plot!(fleet_trajectory_map)
end

# ╔═╡ 8ae11266-287e-11eb-0a25-6932ca705259
fleet_stpi_vec_map = Dict(fleet_name=>interpolate_stp_vec(stp_vec) for (fleet_name, stp_vec) in fleet_trajectory_map)

# ╔═╡ 9d447b78-287e-11eb-1c89-a198002d9865
let
	plot(sp_coral, xlims=(left, right), ylim=(bottom, top))
	plot!(fleet_stpi_vec_map, DateTime(1942,5,7,12))
end

# ╔═╡ a1bba154-287e-11eb-2cff-9d4fe149bb94
DateTime(1942, 5,9, 0,0) - DateTime(1942, 5,4, 0,0)

# ╔═╡ 17db08fa-287f-11eb-0f79-f1503869c2f1
start_date = DateTime(1942, 5,4, 0,0)

# ╔═╡ 3e27a4de-287f-11eb-0148-7fb83b833bc2
end_date = DateTime(1942, 5,9, 0,0)

# ╔═╡ 49912db8-287f-11eb-0e5b-59016f2fba2c
duration = end_date - start_date

# ╔═╡ 5cb0a31c-2896-11eb-2959-41964763a4d0
@bind t_ani Slider(1:60000:duration.value)

# ╔═╡ f109bde0-2897-11eb-0148-c1669b00dabf
date_selected = start_date + Millisecond(t_ani)

# ╔═╡ c3ea6e54-2897-11eb-34d7-f7f4670e1348
let
	plot(sp_coral, xlims=(left, right), ylim=(bottom, top))
	plot!(fleet_stpi_vec_map, date_selected)
	title!(string(date_selected))
end

# ╔═╡ Cell order:
# ╠═197bebe6-287e-11eb-2933-cb9828acea28
# ╠═4d4303ec-287e-11eb-13b7-b363677a79f8
# ╠═501139a4-287e-11eb-351c-ef37927f3e92
# ╠═5217bd20-287e-11eb-1f8c-5bd26ffa5dc9
# ╠═54313a66-287e-11eb-0671-49cfd4d74aca
# ╠═5ffd8b40-287e-11eb-2db6-49eabf586be0
# ╠═62104d2a-287e-11eb-3299-fda3b191c6ef
# ╠═66d18c78-287e-11eb-3e09-750baacd9fa7
# ╠═5664eb16-287e-11eb-0a8a-9bb00a8b6bab
# ╠═743b8f5a-287e-11eb-2001-654f5f93719d
# ╠═8ae11266-287e-11eb-0a25-6932ca705259
# ╠═9d447b78-287e-11eb-1c89-a198002d9865
# ╠═a1bba154-287e-11eb-2cff-9d4fe149bb94
# ╠═17db08fa-287f-11eb-0f79-f1503869c2f1
# ╠═3e27a4de-287f-11eb-0148-7fb83b833bc2
# ╠═49912db8-287f-11eb-0e5b-59016f2fba2c
# ╠═4395e4e6-2896-11eb-187e-4db9dbc90a2b
# ╠═f109bde0-2897-11eb-0148-c1669b00dabf
# ╠═5cb0a31c-2896-11eb-2959-41964763a4d0
# ╠═c3ea6e54-2897-11eb-34d7-f7f4670e1348
