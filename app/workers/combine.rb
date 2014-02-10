uploadDir = ARGV.shift
uploadName = ARGV.shift
extension = ARGV.shift

if(extension.casecmp("MTS") == 0)
  fullFile = File.join(uploadDir, uploadName+"_orig.MTS")
  chunk = Dir.glob(File.join(uploadDir, uploadName, "*.mts"), File::FNM_CASEFOLD).sort
  File.open(fullFile, 'w') do |f|
    chunk.each do |chunk|
      f.write(File.read(chunk))
    end
  end
end

if(extension.casecmp("mp4") == 0)
  fullFile = File.join(uploadDir, uploadName+"_orig.mp4")
  chunk = Dir.glob(File.join(uploadDir, uploadName, "*.mp4"), File::FNM_CASEFOLD).sort
  mp4boxCommand = "MP4Box"
  chunk.each do |ch|
    mp4boxCommand+=" -cat "+ch
  end 
  mp4boxCommand+=" "+fullFile
  `#{mp4boxCommand}`
end
