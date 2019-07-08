require "ffi-rzmq"

context = ZMQ::Context.new

backend = context.socket(ZMQ::DEALER)
backend.bind("tcp://*:5555")

frontend = context.socket(ZMQ::ROUTER)
frontend.bind("tcp://*:5556")

publisher = context.socket(ZMQ::PUB)
publisher.bind("tcp://*:5558")

proxy = ZMQ::Proxy.new(frontend, backend)

trap(:INT) do
  print "Shutdown signal received..."

  publisher.send_string("SHUTDOWN")

  sleep 1

  backend.close
  frontend.close
  publisher.close

  context.terminate

  print "Done\n"
  exit
end

