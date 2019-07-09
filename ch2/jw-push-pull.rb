require "ffi-rzmq"

context = ZMQ::Context.new(1)

sender  = context.socket(ZMQ::PUSH)
sender.bind("ipc://fubar")

workers =
  4.times.map do
    fork do
      context  = ZMQ::Context.new(1)

      receiver = context.socket(ZMQ::PULL)
      receiver.connect("ipc://fubar")

      loop do
        msg = ""
        receiver.recv_string(msg)

        sleep msg.to_i / 1000.0
        puts "#$$"
      end
    end
  end

sleep 1

total =
  (1..100).reduce(0) do |acc, n|
    workload = rand(100) + 1

    sender.send_string(workload.to_s)

    acc += workload
    acc
  end

puts "Total expected cost: #{total}"

Process.waitall
