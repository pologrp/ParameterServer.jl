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
