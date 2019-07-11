# 1. if a DEALER is going to stand as a REQ, it should be prepared to read
# and write the empty frame.
require "pry"
require "base64"
require "ffi-rzmq"

def worker(n)
  context = ZMQ::Context.new
  worker  = context.socket(ZMQ::DEALER)
  # worker.setsockopt(ZMQ::IDENTITY, "WORKER#{n}")
  worker.connect("tcp://localhost:5671")

  tasks = 0
  loop do
    worker.send_string("", ZMQ::SNDMORE) # empty frame to be compatible w/ REQ
    worker.send_string("hi boss")

    worker.recv_string(empty_frame = "") # ditto - manual empty frame
    worker.recv_string(workload = "")

    if workload =~ /fired/i
      print "#{n}: completed #{tasks} tasks.\n"
      break
    else
      sleep rand(5)
      tasks += 1
    end
  end
end

context = ZMQ::Context.new
router  = context.socket(ZMQ::ROUTER)
# router.setsockopt(ZMQ::ROUTER_MANDATORY, 1)
router.bind("tcp://*:5671")

workers =
  10.times.map do |n|
    Thread.new { worker(n) }
  end

t = Time.now + 5 # seconds

workers_fired = 0
loop do
  router.recv_string(ident = "")
  router.recv_string(empty_frame = "")
  router.recv_string(body = "")

  # pretty_ident = Base64.strict_encode64(ident)[-3..-2]
  pretty_ident = ident
  # puts "\tRECEIVED REQ FROM #{pretty_ident}"

  router.send_string(ident, ZMQ::SNDMORE)
  router.send_string("", ZMQ::SNDMORE)

  if Time.now < t
    # puts "\t\tWORK COMMAND: #{pretty_ident}"
    router.send_string("Work harder")
  else
    # puts "\t\tFIRED COMMAND: #{pretty_ident}"
    router.send_string "Fired!"
    workers_fired += 1

    break if workers_fired == 10
  end
end

workers.each(&:join)
