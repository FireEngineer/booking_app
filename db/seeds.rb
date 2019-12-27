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
Plan.create!(title: "パーソナルプラン(トライアル)", plan_id: "5000T30D1", charge: 5000, description: "30日のトライアルプランです。３0日後に課金されます。", trial_days: 30, billing_day: 1)
Plan.create!(title: "プロプラン(トライアル)", plan_id: "10000T30D1", charge: 10000, description: "30日のトライアルプランです。３0日後に課金されます。", trial_days: 30, billing_day: 1)
Plan.create!(title: "パーソナルプラン", plan_id: "5000D1", charge: 5000, description: "30日のトライアルプランです。３0日後に課金されます。", billing_day: 1)
Plan.create!(title: "プロプラン", plan_id: "10000D1", charge: 10000, description: "30日のトライアルプランです。３0日後に課金されます。", billing_day: 1)
Plan.create!(title: "スペシャルプラン", plan_id: "special", charge: 0, description: "期限なしの無料プラン。")
