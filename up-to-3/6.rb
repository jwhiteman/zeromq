# demonstrates ROUTER's incoming fair-queueing
require "ffi-rzmq"
require "pry"

def req(n)
  context = ZMQ::Context.new
  client  = context.socket(ZMQ::REQ)
  client.identity = "CLIENT-#{n}"

  client.connect("tcp://localhost:5555")

  10.times do
    sleep_amount = rand(10)
    client.send_string("sleep-#{sleep_amount}")

    client.recv_string(reply = "")
    # puts "CLIENT #{n} reply received: #{reply}. Now sleeping for #{sleep_amount}"
    sleep sleep_amount
  end

  client.close
  context.terminate
end

def rep
  context = ZMQ::Context.new
  server  = context.socket(ZMQ::ROUTER)
  server.bind("tcp://*:5555")

  loop do
    server.recv_strings(message = [])

    puts "#{message[0]}: #{message[2]}"

    server.send_string(message[0], ZMQ::SNDMORE)
    server.send_string("", ZMQ::SNDMORE)
    server.send_string("OK")
  end
end

clients = 5.times.map { |n| Thread.new { req(n) } }
server  = Thread.new { rep }

server.join(&:join)
