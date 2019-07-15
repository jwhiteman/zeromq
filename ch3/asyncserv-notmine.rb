require 'ffi-rzmq'

def client
  context = ZMQ::Context.new
  client = context.socket ZMQ::DEALER
  client.identity = "%04X-%04X" % [rand(0x10000), rand(0x10000)]
  client.connect "tcp://localhost:5555"

  poller = ZMQ::Poller.new
  poller.register_readable(client)

  request_number = 0

  puts "C1"
  loop do
    100.times do |tick|
      # puts "C2"
      if poller.poll(10) == 1
        puts "C3"
        client.recv_strings message = []
        puts "#{client.identity}: #{message.last}"
      end
    end

    puts "C4"
    client.send_string "Req ##{request_number += 1}"
    puts "C5"
  end
end

def worker(context)
  worker = context.socket ZMQ::DEALER
  worker.connect "tcp://localhost:5556"
  puts "W1"

  loop do
    puts "W2"
    worker.recv_strings message = []
    puts "W3"

    rand(0..4).times do
      sleep rand
      puts "W4"
      worker.send_strings message
    end
  end
end

clients = 3.times.map { Thread.new { client } }

context = ZMQ::Context.new
frontend = context.socket ZMQ::ROUTER
backend = context.socket ZMQ::DEALER

frontend.bind "tcp://*:5555"
backend.bind "tcp://*:5556"

poller = ZMQ::Poller.new
poller.register_readable frontend
poller.register_readable backend

ws = 5.times.map { Thread.new { worker(context) } }

ZMQ::Device.create ZMQ::QUEUE, frontend, backend

require "pry"
binding.pry
