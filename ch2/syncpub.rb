require "ffi-rzmq"

NUM_CLIENTS = 10

context = ZMQ::Context.new

publisher = context.socket(ZMQ::PUB)
# NOTE: this needs to be set before bind, it seems
publisher.setsockopt(ZMQ::SNDHWM, 0)
publisher.bind("tcp://*:5561")

syncservice = context.socket(ZMQ::REP)
syncservice.bind("tcp://*:5562")

puts "1"
NUM_CLIENTS.times do
  syncservice.recv_string("")

  syncservice.send_string("")
end
puts "2"

1_000_000.times do
  publisher.send_string("Rhubarb")
end
puts "3"

publisher.send_string("END")
puts "4"

publisher.close
syncservice.close
context.terminate
