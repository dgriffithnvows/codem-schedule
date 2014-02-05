uploadDir = ARGV.shift
fileName = ARGV.shift
uploadName = ARGV.shift

`gem install pubnub` if `gem list`.lines.grep(/^pubnub \(.*\)/).empty?
require 'pubnub'

newDir = File.join(uploadDir, uploadName)
Dir.mkdir(newDir) unless File.exist?(newDir)
chunk = Dir[File.join(uploadDir, "chunks_of_#{fileName}", "chunk_*")].sort

File.open(File.join(newDir, fileName), "w") do |f|
  chunk.each do |chunk| 
    f.write(File.read(chunk))
    File.delete(chunk)
  end
end

Dir.delete(File.join(uploadDir, "chunks_of_#{fileName}")) if (Dir.entries(File.join(uploadDir, "chunks_of_#{fileName}")) - %w{ . .. }).empty?

pubnub = Pubnub.new(
  :publish_key   => 'pub-c-c66ba4a6-4776-4eea-b401-b4ed65a33421',
  :subscribe_key => 'sub-c-6f382e90-804e-11e2-b64e-12313f022c90',
)
pubnub.publish(
  :channel  => "codem_reconstruct_#{fileName}_of_#{uploadName}",
  :message  => "reconstruction complete",
){ |envelope|
  puts("
    \nchannel: #{envelope.channel}
    \nmsg: #{envelope.message} 
  ")
}
sleep 2
