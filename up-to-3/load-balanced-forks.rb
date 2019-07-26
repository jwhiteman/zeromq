# Possibly a load-balanced way that i could have done my fork'd workers
# in the IM rake tasks...
require "ffi-rzmq"
require "pry"

def req(n)
  context = ZMQ::Context.new
  client  = context.socket(ZMQ::REQ)
  client.identity = "CLIENT-#{n}"

  client.connect("tcp://localhost:5555")

  loop do
    client.send_string("MOAR")

    client.recv_string(workload = "")

    if workload == "STOP"
      break
    else
      print "WORKER #{n} will sleep for #{workload}\n"

      sleep workload.to_i
    end
  end

  print "WORKER #{n} exiting\n"
  client.close
  context.terminate
end

nworkers  = 5
workloads = [2, 3, 6, 1, 3, 1, 7, 2, 0, 4, 1, 8, 5, 7, 9, 2, 4, 0, 9, 2, 0, 7,
             2, 1, 9, 0, 0, 5, 0, 3, 9, 0, 3, 0, 0, 0, 5, 1, 8, 4, 0, 5, 3, 2,
             3, 2, 4, 4, 0, 7, 9, 7, 7, 4, 6, 2, 3, 5, 7, 3, 0, 1, 0, 5, 4, 0,
             8, 0, 5, 7, 1, 9, 6, 7, 3, 2, 4, 4, 9, 7, 3, 1, 5, 0, 0, 3, 6, 5,
             2, 6, 6, 9, 2, 2, 9, 9, 2, 2, 4, 4]

workerpids =
  nworkers.
  times.
  map do |n|
    fork do
      req(n)
    end
  end

sleep 1

context = ZMQ::Context.new
server  = context.socket(ZMQ::ROUTER)
server.bind("tcp://*:5555")

trap(:INT) do
  workerpids.each do |pid|
    print "Killing #{pid}\n"
    Process.kill(:KILL, pid)
  end

  print "Shutting down...\n"
  exit
end

workloads.each do |workload|
  server.recv_strings(message = [])

  server.send_string(message[0], ZMQ::SNDMORE)
  server.send_string("", ZMQ::SNDMORE)
  server.send_string(workload.to_s)
end

nworkers.times do
  server.recv_strings(message = [])

  server.send_string(message[0], ZMQ::SNDMORE)
  server.send_string("", ZMQ::SNDMORE)
  server.send_string("STOP")
end

Process.waitall

server.close
context.terminate
