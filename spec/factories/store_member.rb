FactoryBot.define do
    factory :store_member do
        name {"今井翔太"}
        gender {"男"}
        age {24}
        line_user_id {ENV['TEST_LINE_USER_ID']}
        email {"testaa@gmail.com"}
        phone {"09057955438"}
    end
end