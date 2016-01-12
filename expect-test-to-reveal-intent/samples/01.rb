create(:user, admin: true)

create(:admin)

factory :user do
  factory :admin do
    admin true
  end
end
