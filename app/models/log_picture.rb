class LogPicture < ApplicationRecord
  mount_uploader :picture, PictureUploader

  belongs_to :member_log
end
