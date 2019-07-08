echo "Starting clients"

for ((a=0; a < 5; a++)) do
  ruby jw-req-client.rb &

  sleep 1
done

echo "Starting servers"

for ((a=0; a < 5; a++)) do
  ruby jw-rep-server.rb &

  sleep 1
done

ruby jw-broker.rb
