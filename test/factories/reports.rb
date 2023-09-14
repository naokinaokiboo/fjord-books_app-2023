# frozen_string_literal: true

FactoryBot.define do
  sequence :title do |index|
    "Report #{index}"
  end

  sequence :content do |index|
    "Content #{index}"
  end

  factory :report, class: Report do
    title { generate :title }
    content { generate :content }
    factory :report_with_user, class: Report do
      association :user
    end
  end
end
