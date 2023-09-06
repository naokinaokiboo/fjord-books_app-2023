# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |index|
    "test#{index}@example.com"
  end

  sequence :name do |index|
    "test#{index}"
  end

  factory :user do
    email { generate :email }
    password { 'password' }
    name { generate :name }
  end

  factory :noname_user, class: User do
    email { generate :email }
    password { 'password' }
  end
end
