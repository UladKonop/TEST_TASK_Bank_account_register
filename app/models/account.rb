# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user

  validates :currency, uniqueness: true
  validates :amount, numericality: { greater_than: 0 }
end
