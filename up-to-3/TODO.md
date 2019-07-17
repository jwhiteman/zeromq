(R)EQ => (R)EP | (R)OUTER
  (R)ound-robin

experiments:
  req to router
    after first back and forth, can rep initiate?
  
  single req to multiple routers
  
  multiple reqs to a single rep
  
  multiple reqs to a single router
  
  multiple reqs to multiple reps
  
  multiple reqs to multiple routers
  
  is req outgoing round-robin?
  is rep incoming fair-queued?

```
require "ffi-rzmq"
require "pry"

context = ZMQ::Context.new
client = context.socket(ZMQ::REQ)
client.connect("tcp://localhost:5555")

require "ffi-rzmq"
require "pry"

context = ZMQ::Context.new
server = context.socket(ZMQ::REP)
server.bind("tcp://*:5555")
```
