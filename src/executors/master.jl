struct PSMaster
  options::_options_t

  function (::Type{PSMaster})(; linger::Integer = 1000, timeout::Integer = 5000,
    address::String = "localhost", port::Integer = 50000,
    scheduler::String = "localhost",
    scheduler_ports::Tuple{<:Integer,<:Integer} = (40000, 40001))
    new(_psoptions(linger = linger, tm = timeout, scheduler = scheduler,
      master = address, worker_port = port, scheduler_ports = (scheduler_ports..., 0)))
  end
end

function show(io::IO, agent::PSMaster)
  println(io, "Master Agent")
  println(io, "  Linger time  : $(Int(agent.options.linger)) [ms]")
  println(io, "  Timeout      : $(Int(agent.options.mtimeout)) [ms]")
  println(io, "  Connects     : $(String([UInt8(c) for c in agent.options.saddress]))")
  println(io, "  (PUB, M)     : $(map(Int, agent.options.sports)[1:2])")
  print(io, "  Binds        : ",
    "$(String([UInt8(c) for c in agent.options.maddress])):$(Int(agent.options.mworker))")
end

cconvert(::Type{_options_t}, agent::PSMaster) = agent.options

function solve!(logger::Function, agent::PSMaster, boost, step, smooth, prox)
  logger_c = @cfunction(m_log_wrapper, Cvoid,
    (Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))
  init_c = @cfunction(init_wrapper, Cvoid,
    (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))
  boost_c = @cfunction(boost_wrapper, Ptr{Cdouble},
    (Cint, Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))
  step_c = @cfunction(step_wrapper, Cdouble,
    (Cint, Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))
  smooth_c = @cfunction(smooth_wrapper, Ptr{Cdouble},
    (Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))
  prox_c = @cfunction(prox_wrapper, Ptr{Cdouble},
    (Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))
  loss_c = @cfunction(loss_wrapper, Cdouble,
    (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))

  err = ccall(paramserver_m, _error_t,
    (Ptr{Cvoid}, Any, _options_t, Ptr{Cvoid}, Ptr{Cvoid}, Any, Ptr{Cvoid}, Any, Ptr{Cvoid}, Any, Ptr{Cvoid}, Any),
    logger_c, logger, agent, init_c, boost_c, boost, step_c, step, smooth_c, smooth, prox_c, prox)

  if err.id != zero(err.id)
    lastidx = findfirst(x->x<=zero(x), err.what)
    error(String([UInt8(c) for c in err.what[1:lastidx-1]]))
  end

  nothing
end
