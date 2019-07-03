require "ffi-rzmq"

context = ZMQ::Context.new

requestor = context.socket(ZMQ::REQ)
requestor.connect("tcp://localhost:5559")

10.times do |n|
  requestor.send_string("HELLO #{n} FROM #$$")

  requestor.recv_string(message = "")

  puts "Received reply #{n}: #{message}"
end
