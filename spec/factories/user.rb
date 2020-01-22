FactoryBot.define do
  factory :user do
    email { 'test@gmail.com' }
    password { 'password' }

    after(:create) do |user|
      1.times do
        create(:calendar, user: user)
      end
    end
  end
end
