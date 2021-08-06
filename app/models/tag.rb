# frozen_string_literal: true

class Tag < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :name, uniqueness: true
end
