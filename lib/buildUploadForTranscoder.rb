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
    :message  => {:status => "combine", :details => defined?(details)==nil ? "no details" : details, :log => "The reconstruction of #{uploadName} is now complete."}
  ){ |envelope|
    puts("
      \nchannel: #{envelope.channel}
      \nmsg: #{envelope.message} 
    ")
  }
  details="no details"

  fileExtension = File.extname(fileName)[1..-1]

  if fileExtension.casecmp("MTS") == 0
    chunk = Dir.glob(File.join(uploadDir, uploadName, "*.MTS"), File::FNM_CASEFOLD).sort
    File.open(File.join(uploadDir, uploadName+"_orig."+fileExtension), "w") do |f|
      chunk.each do |chunk|
        f.write(File.read(chunk))
        File.delete(chunk)
      end
    end
    Dir.delete(File.join(uploadDir, uploadName)) if (Dir.entries(File.join(uploadDir, uploadName)) - %w{ . .. }).empty?
  elsif fileExtension.casecmp("mp4") == 0
    chunk = Dir.glob(File.join(uploadDir, uploadName, "*.mp4"), File::FNM_CASEFOLD).sort
    mp4BoxCommand = "MP4Box"
    chunk.each do |chunk|
      mp4BoxCommand+=" -cat "+chunk
    end
    mp4BoxCommand+=" #{File.join(uploadDir, uploadName)}_orig."+fileExtension
    `#{mp4BoxCommand}`
    chunk.each do |chunk|
      File.delete(chunk)
    end
    Dir.delete(File.join(uploadDir, uploadName)) if (Dir.entries(File.join(uploadDir, uploadName)) - %w{ . .. }).empty?
  else
    details = "This file type is not yet supported."
  end

  pubnub = Pubnub.new( 
    :publish_key   => 'pub-c-c66ba4a6-4776-4eea-b401-b4ed65a33421',
    :subscribe_key => 'sub-c-6f382e90-804e-11e2-b64e-12313f022c90',
  )
  pubnub.publish(
    :channel  => "codem_upload_#{uploadName}",
    :message  => {:status => "combine", :details => defined?(details)==nil ? "no details" : details, :log => "#{uploadName} is now combine."}
  ){ |envelope|
    puts("
      \nchannel: #{envelope.channel}
      \nmsg: #{envelope.message} 
    ")
  }
  details="no details"

  details = `curl -d 'input=#{File.join(uploadDir, uploadName+"_orig."+fileExtension)}&output=#{File.join(railsRoot, "public", "seminars", uploadName+".mp4")}&preset=h264' http://localhost:3000/api/jobs`

  pubnub.publish(
    :channel  => "codem_upload_#{uploadName}",
    :message  => {:status => "combine", :details => defined?(details)==nil ? "no details" : details, :log => "#{uploadName} is now scheduled."}
  ){ |envelope|
    puts("
      \nchannel: #{envelope.channel}
      \nmsg: #{envelope.message} 
    ")
  }
  details="no details"
end

sleep 2
