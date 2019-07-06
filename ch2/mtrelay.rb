require "pry"
require "ffi-rzmq"

def step3(context)
  xmitter = context.socket(ZMQ::PAIR)
  xmitter.connect("inproc://step3")

  sleep 1

  xmitter.send_string("FROM STEP 3: OK")
  xmitter.close
end

def step1(context)
  receiver = context.socket(ZMQ::PAIR)
  receiver.bind("inproc://step3")

  Thread.new { step3(context) }

  receiver.recv_string(m = "")

  xmitter = context.socket(ZMQ::PAIR)
  xmitter.connect("inproc://step2")

  xmitter.send_string("FROM STEP 2: #{m}")

  receiver.close
  xmitter.close
end

context = ZMQ::Context.new

receiver = context.socket(ZMQ::PAIR)
receiver.bind("inproc://step2")

Thread.new { step1(context) }

receiver.recv_string(message = "")

puts "Received a message: #{message}"

receiver.close
context.terminate
