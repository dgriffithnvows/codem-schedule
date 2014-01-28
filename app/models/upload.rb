class Upload < ActiveRecord::Base
  attr_accessible :name, :video
  mount_uploader :video, WebinarsUploader

#  before_create :default_name
#
#  def default_name
#    self.name ||= File.basename(video.filename, '.*').titleize if video
#  end
end
