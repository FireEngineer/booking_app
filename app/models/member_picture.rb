class MemberPicture < ApplicationRecord
  mount_uploader :picture, PictureUploader

  belongs_to :store_member

end
