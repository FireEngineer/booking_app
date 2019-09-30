class AddIsAllowNoticeToStoreMember < ActiveRecord::Migration[5.2]
  def change
    add_column :store_members, :is_allow_notice, :boolean
  end
end
