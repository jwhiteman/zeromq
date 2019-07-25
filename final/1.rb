require "ffi-rzmq"

# PUSH/PULL uses the 'immigration' pattern: the work is pre-divided up into
# queues; preferable when tasks mostly take the same time.
def spawn_worker(n)
  Thread.new do
    context = ZMQ::Context.new
    puller  = context.socket(ZMQ::PULL)
    puller.connect("tcp://localhost:5555")
    completed = []

    loop do
      puller.recv_string(msg = "")

      if msg == "STOP"
        break
      else
        workload = msg.to_f

        print "worker #{n} work for #{workload}\n"

        sleep workload
        completed << workload
      end
    end

    total_work = completed.reduce(:+) / completed.length

    print "\tworker #{n} exiting. did #{total_work}\n"
  end
end

numworkers = 10

context = ZMQ::Context.new
pusher  = context.socket(ZMQ::PUSH)
pusher.bind("tcp://*:5555")

workers = numworkers.times.map do |n|; spawn_worker(n); end

sleep 1

workloads = Array.new(100) { rand(10) }

workloads.each do |workload|
  pusher.send_string(workload.to_s)
end

numworkers.times do
  pusher.send_string("STOP")
end

workers.each(&:join)
