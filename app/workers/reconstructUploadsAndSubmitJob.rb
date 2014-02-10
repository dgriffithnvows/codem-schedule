railsRoot = ARGV.shift
fileName = ARGV.shift
uploadName = ARGV.shift
numberOfFiles = Integer(ARGV.shift)

uploadDir = File.join(railsRoot, "public", "uploads")

`gem install pubnub` if `gem list`.lines.grep(/^pubnub \(.*\)/).empty?
require 'pubnub'

newDir = File.join(uploadDir, uploadName)
unless File.exist?(newDir)
  Dir.mkdir(newDir) 
end

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
  :channel  => "codem_upload_#{uploadName}",
  :message  => "reconstruct of #{fileName} complete",
){ |envelope|
  puts("
    \nchannel: #{envelope.channel}
    \nmsg: #{envelope.message} 
  ")
}

#if the number of files in the newDir is the same as numberOfFiles we are done and should pubnub publish to client and begin concating
uploadCountFile = File.join(newDir, ".codemUploadCount")
fileCount = 0
if File.exist?(uploadCountFile)
  File.open(uploadCountFile, "r") do |f|
    fileCount = Integer(f.gets)
  end
end
fileCount+=1
File.open(uploadCountFile, "w") do |f|
  f.write(fileCount)
end

if(fileCount == numberOfFiles)
  pubnub = Pubnub.new( #for some reason I have to recreate the Pubnub object
    :publish_key   => 'pub-c-c66ba4a6-4776-4eea-b401-b4ed65a33421',
    :subscribe_key => 'sub-c-6f382e90-804e-11e2-b64e-12313f022c90',
  )
  pubnub.publish(
    :channel  => "codem_upload_#{uploadName}",
    :message  => "The reconstruction of #{uploadName} is now complete. On to combining them."
  ){ |envelope|
    puts("
      \nchannel: #{envelope.channel}
      \nmsg: #{envelope.message} 
    ")
  }

  pid = spawn("ruby #{File.join(railsRoot,'app','workers', 'combine.rb')} #{uploadDir} #{uploadName} #{File.extname(fileName)[1..-1]}")
  Process.detach(pid) 

end

sleep 2
