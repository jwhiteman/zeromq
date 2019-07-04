require "ffi-rzmq"

context = ZMQ::Context.new

frontend = context.socket(ZMQ::ROUTER)
frontend.bind("tcp://*:5559")

backend  = context.socket(ZMQ::DEALER)
backend.bind("tcp://*:5560")

proxy = ZMQ::Proxy.new(frontend, backend)
