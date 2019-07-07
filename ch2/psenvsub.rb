require "pry"
require "ffi-rzmq"

context = ZMQ::Context.new

subscriber = context.socket(ZMQ::SUB)
subscriber.setsockopt(ZMQ::SUBSCRIBE, "B")
subscriber.connect("tcp://localhost:5563")

trap(:INT) do
  subscriber.close
  context.terminate

  exit
end

loop do
  subscriber.recv_string(address = "")
  subscriber.recv_string(msg = "")

  puts "#{address}: #{msg}"
end

subscriber.close
context.terminate
