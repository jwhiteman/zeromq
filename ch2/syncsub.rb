require "ffi-rzmq"

context = ZMQ::Context.new

subscriber = context.socket(ZMQ::SUB)
subscriber.connect("tcp://localhost:5561")
subscriber.setsockopt(ZMQ::SUBSCRIBE, "")

# NOTE:
sleep 1

syncclient = context.socket(ZMQ::REQ)
syncclient.connect("tcp://localhost:5562")

syncclient.send_string("")
syncclient.recv_string("")

updates = 0
loop do
  subscriber.recv_string(msg = "")
  if msg == "END"
    break
  else
    updates += 1
  end
end

puts "Received #{updates} updates"

subscriber.close
syncclient.close
context.terminate
