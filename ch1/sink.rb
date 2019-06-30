require "ffi-rzmq"

context = ZMQ::Context.new(1)

puts "A"
receiver = context.socket(ZMQ::PULL)
receiver.bind("tcp://*:5558")
puts "B"

# wait until we get the start message from the ventilator
s = ""
receiver.recv_string(s)

puts "C"

t = Time.now

(1..100).each do |n|
  puts "B"
  receiver.recv_string("")

  if n % 10 == 0
    print ":"
  else
    print "."
  end
end

puts "Total elapsed time: #{(Time.now - t).to_i} seconds"
