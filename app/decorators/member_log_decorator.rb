module MemberLogDecorator
  def display_updated_at
    if created_at == updated_at
      "投稿日時：#{l(updated_at, format: :long)}"
    else
      "更新日時：#{l(updated_at, format: :long)}(編集済み)"
    end
  end
end
