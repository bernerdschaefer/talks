factory :user do
  factory :admin do
    admin true
  end
end

create(:admin)
