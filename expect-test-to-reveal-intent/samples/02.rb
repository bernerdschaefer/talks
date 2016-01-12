create(:job, :past)
create(:job, :current)

factory :job do
  trait :past do
    starts_on 1.year.ago
    ends_on 2.months.ago
  end

  trait :current do
    starts_on  1.month.ago
    ends_on nil
  end
end
