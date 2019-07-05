require "pry"
require "ffi-rzmq"

context  = ZMQ::Context.new(1)

receiver = context.socket(ZMQ::PULL)
receiver.connect("tcp://localhost:5557")

sender   = context.socket(ZMQ::PUSH)
sender.connect("tcp://localhost:5558")

controller = context.socket(ZMQ::SUB)
controller.connect("tcp://localhost:5559")
controller.setsockopt(ZMQ::SUBSCRIBE, "")

poller = ZMQ::Poller.new
poller.register(receiver, ZMQ::POLLIN)
poller.register(controller, ZMQ::POLLIN)

trap("INT") do
  puts "Shutting down."

  [receiver, sender, controller].each(&:close)

  context.terminate

  exit
end

loop do
  # poller.poll(:blocking)
  poller.poll

  poller.readables.each do |readable|
    if readable == receiver
      msg = ""
      receiver.recv_string(msg)

      sleep msg.to_i / 1000.0
      print(".")

      sender.send_string("")
    elsif readable == controller
      puts "received the kill signal. shutting down..."

      exit 0
    else
      puts "some other readable was ready"
    end
  end
end
