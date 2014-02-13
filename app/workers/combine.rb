uploadDir = ARGV.shift
uploadName = ARGV.shift
fileExtension = ARGV.shift

require 'pubnub'

if fileExtension.casecmp("MTS") == 0
  chunk = Dir.glob(File.join(uploadDir, uploadName, "*.MTS"), File::FNM_CASEFOLD).sort
  File.open(File.join(uploadDir, uploadName+"_orig.MTS"), "w") do |f|
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
  mp4BoxCommand+=" #{File.join(uploadDir, uploadName)}_orig.mp4"
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
  :message  => {:status => "combine", :details => defined?(details)==nil ? "no details" : details, :log => "#{uploadName} is now combine. And ready to go to the transcoder."}
){ |envelope|
  puts("
    \nchannel: #{envelope.channel}
    \nmsg: #{envelope.message} 
  ")
}

sleep 2
