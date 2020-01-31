# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# email = "changemymind6@gmail.com"
# pass = "shotaimai6"
# channel_id = "1603141730"
# channel_secret = "a59f370b529454e32f779071d9b50454"

# admin = Admin.new(email: email, password: pass, encrypted_password: pass)
# admin.build_line_bot(channel_id: channel_id, channel_secret: channel_secret)
# admin.save!


User.create!(name: "テスト管理者", email:"changemymind6@gmail.com", password:"password", password_confirmation:"password")
Calendar.create!(user_id: 1, calendar_name: "ひまわりマッサージ", address:"東京都渋谷区１１１１１", phone:"09057975695")
Staff.create!(calendar_id: 1, name:"スタッフA", email:"changemymind6@gmail.com", password:"password", password_confirmation:"password", description: "元気いっぱいです！")
TaskCourse.create!(calendar_id: 1, title:"60分コース", description:"ノーマルマッサージ+オイルヘッドマッサージ", course_time: 60, charge: "5000")
index = 1
20.times do
  StoreMember.create!(calendar_id: 1, name:"test#{index}", email:"test#{index}@email.com", phone:"0000000000#{index}", is_allow_notice: true)
  index += 1
end

Plan.create!(title: "パーソナルプラン(トライアル)", plan_id: "5000T30D1", charge: 5000, description: "30日のトライアルプランです。３0日後に課金されます。", trial_days: 30, billing_day: 1)
Plan.create!(title: "プロプラン(トライアル)", plan_id: "10000T30D1", charge: 10000, description: "30日のトライアルプランです。３0日後に課金されます。", trial_days: 30, billing_day: 1)
Plan.create!(title: "パーソナルプラン", plan_id: "5000D1", charge: 5000, description: "30日のトライアルプランです。３0日後に課金されます。", billing_day: 1)
Plan.create!(title: "プロプラン", plan_id: "10000D1", charge: 10000, description: "30日のトライアルプランです。３0日後に課金されます。", billing_day: 1)
Plan.create!(title: "スペシャルプラン", plan_id: "special", charge: 0, description: "期限なしの無料プラン。")
