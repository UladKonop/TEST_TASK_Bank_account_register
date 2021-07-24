# frozen_string_literal: true

# This will guess the User class
FactoryBot.define do
  factory :user do
    sequence(:identification_number) { |n| "some_number_#{n}" }
    first_name { 'first_name' }
    last_name { 'last_name' }
    patronimic { 'patronimic' }
  end
end
