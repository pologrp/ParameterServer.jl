struct _error_t
  id::Cint
  what::NTuple{256,Cchar}
end

struct _options_t
  linger::Cint
  mtimeout::Clong
  wtimeout::Clong
  stimeout::Clong
  num_masters::Int32
  saddress::NTuple{256,Cchar}
  maddress::NTuple{256,Cchar}
  sports::NTuple{3,UInt16}
  mworker::UInt16
end

function show(io::IO, options::_options_t)
  println(io, "Parameter Server Options with $(Int(options.num_masters)) total master(s)")
  println(io, "  - linger: $(Int(options.linger)) [ms]")
  println(io, "  - master timeout: $(Int(options.mtimeout)) [ms]")
  println(io, "  - scheduler timeout: $(Int(options.stimeout)) [ms]")
  println(io, "  - worker timeout: $(Int(options.wtimeout)) [ms]")
  println(io, "  - scheduler listens on ", String([UInt8(c) for c in options.saddress]),
          " to ports ", map(Int, options.sports))
  print(io, "  - master listens on ", String([UInt8(c) for c in options.maddress]),
          " to port ", Int(options.mworker))
end

function _psoptions(; linger::Integer = 1000, tm::Integer = 5000,
  tw::Integer = 5000, ts::Integer = 5000, M::Integer = 1,
  scheduler::String = "localhost", master::String = "localhost",
  scheduler_ports::Tuple{<:Integer,<:Integer,<:Integer} = (40000, 40001, 40002),
  worker_port::Integer = 50000)

  return _options_t(
    Cint(linger), Clong(tm), Clong(tw), Clong(ts), Int32(M),
    ntuple(i->(i <= length(scheduler) ? Cchar(scheduler[i]) : Cchar('\0')), 256),
    ntuple(i->(i <= length(master) ? Cchar(master[i]) : Cchar('\0')), 256),
    ntuple(i->UInt16(scheduler_ports[i]), 3), UInt16(worker_port)
  )
end
