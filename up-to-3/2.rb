# req to rep
require "ffi-rzmq"
require "pry"

def req
  context = ZMQ::Context.new
  client  = context.socket(ZMQ::REQ)

  client.connect("tcp://localhost:5555")

  sleep 3

  rc = client.send_string("OK")
  puts "client-rc: #{rc}"

  loop do
    client.recv_string(reply = "")
    puts "client-reply: #{reply}"

    puts "Reply received: #{reply}"

    sleep rand

    client.send_string("MOAR PLZ")
  end
end

def rep
  context = ZMQ::Context.new
  server  = context.socket(ZMQ::ROUTER)
  # this doesn't seem to work when it sends a message sans id:
  # server.setsockopt(ZMQ::ROUTER_MANDATORY
  server.bind("tcp://*:5555")

  sleep 3

  loop do
    rc = server.recv_strings(request = [])
    puts "A: #{rc} #{request.inspect}"

    sleep rand

    server.send_string(request.first, ZMQ::SNDMORE)
    server.send_string("", ZMQ::SNDMORE)
    rc = server.send_string("KOK HERE IS MOAR")

    puts "B: #{rc}"
  end
end

client = Thread.new { req }
server = Thread.new { rep }

server.join(&:join)
