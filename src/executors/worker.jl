struct PSWorker
  options::_options_t

  function (::Type{PSWorker})(; linger::Integer = 1000, timeout::Integer = 5000,
    scheduler::String = "localhost",
    ports::Tuple{<:Integer,<:Integer} = (40000, 40002))
    new(_psoptions(linger = linger, tw = timeout, scheduler = scheduler,
      scheduler_ports = (ports[1], 0, ports[2])))
  end
end

function show(io::IO, agent::PSWorker)
  println(io, "Worker Agent")
  println(io, "  Linger time  : $(Int(agent.options.linger)) [ms]")
  println(io, "  Timeout      : $(Int(agent.options.wtimeout)) [ms]")
  println(io, "  Connects     : $(String([UInt8(c) for c in agent.options.saddress]))")
  print(io, "  (PUB, W)     : $(map(Int, agent.options.sports)[[1,3]])")
end

cconvert(::Type{_options_t}, agent::PSWorker) = agent.options

function solve!(agent::PSWorker, x::AbstractVector, loss)
  loss_c = @cfunction(loss_wrapper, Cdouble,
    (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}))

  x_ = Vector{Cdouble}(x)
  xb = pointer(x_, 1)
  xe = pointer(x_, length(x_) + 1)

  err = ccall(paramserver_w, _error_t,
    (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cvoid}, Any, _options_t),
    xb, xe, loss_c, loss, agent)

  if err.id != zero(err.id)
    lastidx = findfirst(x->x<=zero(x), err.what)
    error(String([UInt8(c) for c in err.what[1:lastidx-1]]))
  end

  nothing
end
