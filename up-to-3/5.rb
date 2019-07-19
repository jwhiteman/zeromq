# rep incoming is fair queued
require "ffi-rzmq"
require "pry"

def req(n)
  context = ZMQ::Context.new
  client  = context.socket(ZMQ::REQ)

  client.connect("tcp://localhost:5555")

  client.send_string("OK #{n}")

  10.times do
    client.recv_string(reply = "")

    sleep_amount = rand(5)
    puts "CLIENT #{n} reply received: #{reply}. Now sleeping for #{sleep_amount}"

    client.send_string("MOAR PLZ")

    sleep sleep_amount
  end

  client.close
  context.terminate
end

def rep
  context = ZMQ::Context.new
  server  = context.socket(ZMQ::REP)
  server.bind("tcp://*:5555")

  loop do
    server.recv_string(request = "")

    server.send_string("HIR IZ MOAR")
  end
end

clients = 5.times.map { |n| Thread.new { req(n) } }
server  = Thread.new { rep }

server.join(&:join)
