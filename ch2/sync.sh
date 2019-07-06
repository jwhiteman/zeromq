echo "Starting subscribers..."

for ((a=0; a<10; a++)); do
  echo starting client $a
  ruby syncsub.rb &
done

echo "Starting publisher..."
ruby syncpub.rb
