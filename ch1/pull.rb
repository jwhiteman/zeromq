require "ffi-rzmq"

context = ZMQ::Context.new(1)
puller  = context.socket(ZMQ::PULL)

puller.bind("tcp://*:3000")

s = ""
puller.recv_string(s)

puts "Done: #{s}"
