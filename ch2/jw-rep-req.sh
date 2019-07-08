echo "Starting clients"

for ((a=0; a < 5; a++)) do
  ruby jw-req-client.rb &

  sleep 1
done
