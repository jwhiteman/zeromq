require "ffi-rzmq"

context  = ZMQ::Context.new(1)

receiver = context.socket(ZMQ::PULL)
receiver.connect("tcp://localhost:5557")

sender   = context.socket(ZMQ::PUSH)
sender.connect("tcp://localhost:5558")

loop do
  msg = ""
  receiver.recv_string(msg)

  puts msg
  sleep msg.to_i
  sender.send_string("")
end
