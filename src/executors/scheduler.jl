struct PSScheduler
  options::_options_t

  function (::Type{PSScheduler})(; linger::Integer = 1000, timeout::Integer = 5000,
    M::Integer = 1, address::String = "*",
    ports::Tuple{<:Integer,<:Integer,<:Integer} = (40000, 40001, 40002))
    new(_psoptions(linger = linger, ts = timeout, M = M, scheduler = address,
      scheduler_ports = ports))
  end
end

function show(io::IO, agent::PSScheduler)
  println(io, "Scheduler Agent")
  println(io, "  Expects      : $(agent.options.num_masters) masters")
  println(io, "  Linger time  : $(Int(agent.options.linger)) [ms]")
  println(io, "  Timeout      : $(Int(agent.options.stimeout)) [ms]")
  println(io, "  Binds        : $(String([UInt8(c) for c in agent.options.saddress]))")
  print(io, "  (PUB, M, W)  : $(map(Int, agent.options.sports))")
end

cconvert(::Type{_options_t}, agent::PSScheduler) = agent.options

function solve!(logger::Function, agent::PSScheduler, x::AbstractVector, K::Integer)
  logger_c = @cfunction(s_log_wrapper, Cvoid,
    (Cint, Ptr{Cvoid}))

  x_ = Vector{Cdouble}(x)
  xb = pointer(x_, 1)
  xe = pointer(x_, length(x_) + 1)

  err = ccall(paramserver_s, _error_t,
    (Ptr{Cdouble}, Ptr{Cdouble}, Cint, Ptr{Cvoid}, Any, _options_t),
    xb, xe, K, logger_c, logger, agent)

  if err.id != zero(err.id)
    lastidx = findfirst(x->x<=zero(x), err.what)
    error(String([UInt8(c) for c in err.what[1:lastidx-1]]))
  end

  nothing
end
