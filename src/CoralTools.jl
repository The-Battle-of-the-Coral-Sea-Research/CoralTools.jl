module CoralTools

using RecipesBase
using Geodesics
using Turf
using CoralData
using CoralData: SectorSearchPlan, SpatTempPos, SpatPos, # Elementary types
    Action, MoveTo, TurnAngleTo, TurnAngle, MoveForward, # Actions
    mi, p, pp, # units
    normal_single_line_search, get_deg_vec, flatten_vec_group, RelPos, ContactReport
import CoralData: get_collected_data
using DataFrames
import DataFrames: DataFrame
using Dates
using Distances
using Statistics: mean

# using Plots

export forward_deg, inverse_deg, get_pos, get_speed, SpatTempPosInt

include("defs.jl")
include("impls.jl")
include("geodesics_utils.jl")
include("interpolate_utils.jl")
include("actions.jl")
include("debug_tools.jl")
include("collected_data.jl")
include("mat_utils.jl")
include("recipes.jl")

include("preprocessed_names.jl")

end # module
