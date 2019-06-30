require "ffi-rzmq"

context = ZMQ::Context.new

puts "Connecting to the stupid server"

requester = context.socket(ZMQ::REQ)
requester.connect("tcp://localhost:5555")

0.upto(9) do |n|
  puts "Sending request #{n}"

  requester.send_string "Hello"

  reply = ""
  requester.recv_string(reply)

  puts "Received reply: #{n} - #{reply.inspect}"
end
