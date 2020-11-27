module CoralTools

using RecipesBase
using Geodesics
using CoralData
using CoralData: SectorSearchPlan, SpatTempPos, SpatPos, # Elementary types
    Action, MoveTo, TurnAngleTo, TurnAngle, MoveForward, # Actions
    mi, p, pp, # units
    normal_single_line_search, get_deg_vec, flatten_vec_group
using Dates
using Distances
# using Plots

export forward_deg, inverse_deg, get_pos, get_speed, SpatTempPosInt

include("defs.jl")
include("geodesics_utils.jl")
include("interpolate_utils.jl")
include("actions.jl")
include("debug_tools.jl")
# include("collected_data.jl")
include("recipes.jl")


end # module
