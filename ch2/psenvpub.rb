require "pry"
require "ffi-rzmq"

context = ZMQ::Context.new

publisher = context.socket(ZMQ::PUB)
publisher.bind("tcp://*:5563")

trap(:INT) do
  publisher.close
  context.terminate

  exit
end

loop do
  publisher.send_string "A", ZMQ::SNDMORE
  publisher.send_string "NOPE."

  publisher.send_string "B", ZMQ::SNDMORE
  publisher.send_string "YEP."

  sleep 1
end

publisher.close
context.terminate
