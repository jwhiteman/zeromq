# req to rep
# demonstrate 2 things here:
# 1. that a single REQ socket can connect to many different endpoints
# 2. that outgoing from REQ is round-robin
require "ffi-rzmq"
require "pry"

def req
  context = ZMQ::Context.new
  client  = context.socket(ZMQ::REQ)

  client.connect("tcp://localhost:5551")
  client.connect("tcp://localhost:5552")
  client.connect("tcp://localhost:5553")
  client.connect("tcp://localhost:5554")

  client.send_string("OK")

  loop do
    client.recv_string(reply = "")

    puts "Reply received: #{reply}"

    client.send_string("MOAR PLZ")
  end
end

def rep(n)
  context = ZMQ::Context.new
  server  = context.socket(ZMQ::REP)
  server.bind("tcp://*:555#{n}")

  loop do
    server.recv_string(request = "")

    sleep rand(3)

    server.send_string("#{n}: HIR IZ MOAR")
  end
end

client  = Thread.new { req }
servers = 5.times.map { |n| Thread.new { rep(n) } }

client.join(&:join)
