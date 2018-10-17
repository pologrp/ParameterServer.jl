struct PSScheduler
  options::_options_t

  function PSScheduler(; linger::Integer, timeout::Integer, M::Integer,
    address::String, ports::Tuple{<:Integer,<:Integer,<:Integer})
    new(_psoptions(linger = linger, ts = timeout, M = M, scheduler = address,
      scheduler_ports = ports))
  end
end

function show(io::IO, agent::PSScheduler)
  println(io, "Scheduler Agent")
  println(io, "  Expects      : $(agent.options.num_masters) masters")
  println(io, "  Linger time  : $(Int(agent.options.linger)) [ms]")
  println(io, "  Timeout      : $(Int(agent.options.stimeout)) [ms]")
  print(io, "  Binds        : ", String([UInt8(c) for c in agent.options.saddress]),
    " on ", map(Int, agent.options.sports))
end
