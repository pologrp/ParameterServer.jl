function init_wrapper(xb::Ptr{Cdouble}, xe::Ptr{Cdouble}, data::Ptr{Cvoid})::Cvoid
  obj = unsafe_pointer_to_objref(data)
  ptrdiff = Int(xe - xb)
  N = divrem(ptrdiff, sizeof(Cdouble))[1]
  x = unsafe_wrap(Array, xb, N)
  init!(obj, x)
  nothing
end

function boost_wrapper(widx::Cint, klocal::Cint, kglobal::Cint, xb::Ptr{Cdouble},
  xe::Ptr{Cdouble}, gb::Ptr{Cdouble}, data::Ptr{Cvoid})::Ptr{Cdouble}
  obj = unsafe_pointer_to_objref(data)
  ptrdiff = Int(xe - xb)
  N = divrem(ptrdiff, sizeof(Cdouble))[1]
  x = unsafe_wrap(Array, xb, N)
  g = unsafe_wrap(Array, gb, N)
  boost!(obj, widx, klocal, kglobal, x, g)
  return gb + ptrdiff
end

function step_wrapper(klocal::Cint, kglobal::Cint, fval::Cdouble, xb::Ptr{Cdouble},
  xe::Ptr{Cdouble}, gb::Ptr{Cdouble}, data::Ptr{Cvoid})::Cdouble
  obj = unsafe_pointer_to_objref(data)
  ptrdiff = Int(xe - xb)
  N = divrem(ptrdiff, sizeof(Cdouble))[1]
  x = unsafe_wrap(Array, xb, N)
  g = unsafe_wrap(Array, gb, N)
  return step!(obj, klocal, kglobal, fval, x, g)
end

function smooth_wrapper(klocal::Cint, kglobal::Cint, xb::Ptr{Cdouble},
  xe::Ptr{Cdouble}, gcurr::Ptr{Cdouble}, gnew::Ptr{Cdouble}, data::Ptr{Cvoid})::Ptr{Cdouble}
  obj = unsafe_pointer_to_objref(data)
  ptrdiff = Int(xe - xb)
  N = divrem(ptrdiff, sizeof(Cdouble))[1]
  x = unsafe_wrap(Array, xb, N)
  go = unsafe_wrap(Array, gcurr, N)
  gn = unsafe_wrap(Array, gnew, N)
  smooth!(obj, klocal, kglobal, x, go, gn)
  return gnew + ptrdiff
end

function prox_wrapper(step::Cdouble, xb::Ptr{Cdouble}, xe::Ptr{Cdouble},
  gcurr::Ptr{Cdouble}, xnew::Ptr{Cdouble}, data::Ptr{Cvoid})::Ptr{Cdouble}
  obj = unsafe_pointer_to_objref(data)
  ptrdiff = Int(xe - xb)
  N = divrem(ptrdiff, sizeof(Cdouble))[1]
  xo = unsafe_wrap(Array, xb, N)
  g = unsafe_wrap(Array, gcurr, N)
  xn = unsafe_wrap(Array, xnew, N)
  prox!(obj, step, xo, g, xn)
end

function loss_wrapper(xb::Ptr{Cdouble}, gb::Ptr{Cdouble}, data::Ptr{Cvoid})::Cdouble
  obj = unsafe_pointer_to_objref(data)
  N = nfeatures(obj)
  x = unsafe_wrap(Array, xb, N)
  g = unsafe_wrap(Array, gb, N)
  return loss!(obj, x, g)
end
