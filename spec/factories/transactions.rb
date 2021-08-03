# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    amount { '9.99' }
    account { nil }
    deposit { false }
  end
end
