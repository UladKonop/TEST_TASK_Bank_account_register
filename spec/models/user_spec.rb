# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:tags_attributes){[{name: 'foo'}]}
  let(:user) do
    described_class.new(
      first_name: 'first_name', 
      last_name: 'last_name', 
      patronimic: 'patronimic',
      identification_number: 1, 
      tags_attributes: tags_attributes
    )
  end

  describe 'Validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is not valid without a firstname' do
      user.first_name = nil
      expect(user).not_to be_valid
    end

    it 'is not valid without a last name' do
      user.last_name = nil
      expect(user).not_to be_valid
    end

    it 'is not valid without a patronimic' do
      user.patronimic = nil
      expect(user).not_to be_valid
    end

    it 'is not valid without an identification number' do
      user.identification_number = nil
      expect(user).not_to be_valid
    end
  end
end
