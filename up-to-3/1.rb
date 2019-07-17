# req to rep
require "ffi-rzmq"
require "pry"

def req
  context = ZMQ::Context.new
  client  = context.socket(ZMQ::REQ)

  client.connect("tcp://localhost:5555")

  client.send_string("OK")

  loop do
    client.recv_string(reply = "")

    puts "Reply received: #{reply}"

    sleep rand

    client.send_string("MOAR PLZ")
  end
end

def rep
  context = ZMQ::Context.new
  server  = context.socket(ZMQ::REP)
  server.bind("tcp://*:5555")

  loop do
    server.recv_string(request = "")

    sleep rand

    server.send_string("HIR IZ MOAR")
  end
end

client = Thread.new { req }
server = Thread.new { rep }

server.join(&:join)
