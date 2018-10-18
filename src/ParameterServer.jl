module ParameterServer

using Libdl

import Base: show, cconvert

function init!() end
function boost!() end
function step!() end
function smooth!() end
function prox!() end
function loss!() end
function nfeatures() end

export
  PSMaster,
  PSScheduler,
  PSWorker,
  solve!

# Load in `deps.jl`, complaining if it does not exist
const depsjl_path = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if !isfile(depsjl_path)
  error("ParameterServer not installed properly, run Pkg.build(\"ParameterServer\"), restart Julia and try again")
end
include(depsjl_path)

function __init__()
  check_deps()

  ps_lib = Libdl.dlopen(libps)

  global paramserver_m = Libdl.dlsym(ps_lib, :paramserver_m)
  global paramserver_s = Libdl.dlsym(ps_lib, :paramserver_s)
  global paramserver_w = Libdl.dlsym(ps_lib, :paramserver_w)
end

include(joinpath("aux", "c_wrappers.jl"))
include(joinpath("aux", "types.jl"))

include(joinpath("executors", "master.jl"))
include(joinpath("executors", "scheduler.jl"))
include(joinpath("executors", "worker.jl"))

end # module
