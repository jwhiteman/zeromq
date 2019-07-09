require "ffi-rzmq"

context = ZMQ::Context.new

requester = context.socket(ZMQ::REQ)
requester.connect("tcp://localhost:5555")

5.times do
  n = rand(10) + 1

  requester.send_string(n.to_s)
  requester.recv_string(m = "")

  puts "AWESOME! 2 ** #{n} == #{m}!"
end
