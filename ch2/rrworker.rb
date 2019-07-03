require "ffi-rzmq"

context = ZMQ::Context.new

responder = context.socket(ZMQ::REP)
responder.connect("tcp://localhost:5560")

loop do
  responder.recv_string(message = "")

  puts "Received request: #{message}"

  sleep 1

  responder.send_string("WORLD #$$")
end
