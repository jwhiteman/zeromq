require "pry"
require "ffi-rzmq"

context = ZMQ::Context.new(1)

receiver = context.socket(ZMQ::PULL)
receiver.bind("tcp://*:5558")

controller = context.socket(ZMQ::PUB)
controller.bind("tcp://*:5559")

# wait until we get the start message from the ventilator
s = ""
receiver.recv_string(s)

t = Time.now
(1..100).each do |n|
  receiver.recv_string("")

  if n % 10 == 0
    print ":"
  else
    print "."
  end
end

puts "Total elapsed time: #{(Time.now - t).to_i} seconds"

controller.send_string("KILL")

puts "Done."
