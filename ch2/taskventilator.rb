require "ffi-rzmq"

context = ZMQ::Context.new(1)

sender  = context.socket(ZMQ::PUSH)
sender.bind("tcp://*:5557")

sink    = context.socket(ZMQ::PUSH)
sink.connect("tcp://localhost:5558")

print "Press Enter when the workers are ready: "
gets

puts "Sending tasks to workers..."

sink.send_string "0"

total =
  (1..100).reduce(0) do |acc, n|
    workload = rand(100) + 1

    sender.send_string(workload.to_s)

    acc += workload
    acc
  end

puts "Total expected cost: #{total}"
