class Upload < ActiveRecord::Base
  attr_accessible :name, :video
  mount_uploader :video, WebinarsUploader
end
