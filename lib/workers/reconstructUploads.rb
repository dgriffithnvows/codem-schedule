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
  :message  => {:status => "combining", :details => defined?(details)==nil ? "no details" : details, :log => "The file `#{fileName}` has been reconstructed."}
){ |envelope|
  puts("
    \nchannel: #{envelope.channel}
    \nmsg: #{envelope.message} 
  ")
}

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
  File.delete(uploadCountFile)
  pubnub = Pubnub.new( #for some reason I have to recreate the Pubnub object
    :publish_key   => 'pub-c-c66ba4a6-4776-4eea-b401-b4ed65a33421',
    :subscribe_key => 'sub-c-6f382e90-804e-11e2-b64e-12313f022c90',
  )
  pubnub.publish(
    :channel  => "codem_upload_#{uploadName}",
    :message  => {:status => "combine", :details => defined?(details)==nil ? "no details" : details, :log => "The reconstruction of #{uploadName} is now complete. On to combining them."}
  ){ |envelope|
    puts("
      \nchannel: #{envelope.channel}
      \nmsg: #{envelope.message} 
    ")
  }

  pid = spawn("ruby #{File.join(railsRoot,'lib','workers', 'combine.rb')} #{uploadDir} #{uploadName} #{File.extname(fileName)[1..-1]}")
  Process.detach(pid) 

  File.open(File.join(railsRoot, "log", "reconstructWorkersPID.log"), "a") do |f|
    f.write("---->COMBINE WORKER = PID: #{pid.to_s.rjust(5, ' ')} | Number Of Files: #{numberOfFiles.to_s.rjust(2, ' ')} | Upload Name: #{uploadName} \n")
  end

end

sleep 2
