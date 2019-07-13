require "pry"
require "ffi-rzmq"

def client(n)
  context  = ZMQ::Context.new
  frontend = context.socket(ZMQ::REQ)
  frontend.setsockopt(ZMQ::IDENTITY, "CLIENT-#{n}")
  frontend.connect("ipc://frontend.ipc")

  frontend.send_string("HELLO")

  frontend.recv_string(reply = "")

  puts "CLIENT-#{n}: #{reply}"

  frontend.close
  context.terminate
end

def worker(n)
  context = ZMQ::Context.new
  backend = context.socket(ZMQ::REQ)
  backend.setsockopt(ZMQ::IDENTITY, "WORKER-#{n}")
  backend.connect("ipc://backend.ipc")

  backend.send_string("READY")

  loop do
    backend.recv_string(client_id = "")
    backend.recv_string(empty_frame = "")
    backend.recv_string(request = "")

    sleep rand(3) + 1

    puts "\tWORKER-#{n}: #{request}"

    backend.send_string(client_id, ZMQ::SNDMORE)
    backend.send_string("", ZMQ::SNDMORE)
    backend.send_string("OK")
  end
end

context  = ZMQ::Context.new

frontend = context.socket(ZMQ::ROUTER)
frontend.bind("ipc://frontend.ipc")

backend  = context.socket(ZMQ::ROUTER)
backend.bind("ipc://backend.ipc")

10.times do |n|
  Thread.new { client(n) }
end

5.times do |n|
  Thread.new { worker(n) }
end

poller = ZMQ::Poller.new
poller.register(backend)
poller.register(frontend)

queue = Queue.new

loop do
  poller.poll

  poller.readables.each do |socket|
    if socket == backend
      backend.recv_string(worker_id = "")
      backend.recv_string(empty_frame = "")
      backend.recv_string(client_id = "")

      queue.enq(worker_id)

      if client_id != "READY"
        backend.recv_string(empty_frame)
        backend.recv_string(payload = "")

        frontend.send_string(client_id, ZMQ::SNDMORE)
        frontend.send_string("", ZMQ::SNDMORE)
        frontend.send_string(payload)
      end
    elsif socket == frontend && queue.size > 0
      frontend.recv_string(client_id = "")
      frontend.recv_string(empty_frame = "")
      frontend.recv_string(request = "")

      worker_id = queue.deq

      backend.send_string(worker_id, ZMQ::SNDMORE)
      backend.send_string("", ZMQ::SNDMORE)
      backend.send_string(client_id, ZMQ::SNDMORE)
      backend.send_string("", ZMQ::SNDMORE)
      backend.send_string(request)
    else
      # no-op
    end
  end
end
