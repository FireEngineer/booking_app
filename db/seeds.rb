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


SystemPlan.create!(title: "有料プラン", plan_id: "P001", charge: 5000, description: "有料プランです。")
Plan.create!(title: "基本プラン", plan_id: "pln_999b5d0dda45465e852493c80719", charge: 5000, description: "有料プランです。")
Plan.create!(title: "お試しプラン", plan_id: "free", charge: 0, description: "期限なしの無料お試しプランです。")