# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/users', type: :request do
  let(:valid_attributes) do
    Hash[first_name: 'first_name', last_name: 'last_name', patronimic: 'patronimic',
         identification_number: 1]
  end

  let(:invalid_attributes) do
    Hash[name: 'first_name', name2: 'last_name', identification_number: '123a1aa']
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      User.create! valid_attributes
      get users_url, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      user = User.create! valid_attributes
      get user_url(user), as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new User' do
        expect do
          post users_url,
               params: { user: valid_attributes }, as: :json
        end.to change(User, :count).by(1)
      end

      it 'renders a JSON response with the new user' do
        post users_url,
             params: { user: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new User' do
        expect do
          post users_url,
               params: { user: invalid_attributes }, as: :json
        end.to change(User, :count).by(0)
      end

      it 'renders a JSON response with errors for the new user' do
        post users_url,
             params: { user: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        Hash[first_name: 'first_name1', last_name: 'last_name1', patronimic: 'patronimic1']
      end

      it 'updates the requested user' do
        user = User.create! valid_attributes
        patch user_url(user),
              params: { user: new_attributes },  as: :json
        user.reload
        expect(user[:first_name]).to match(new_attributes[:first_name])
      end

      it 'renders a JSON response with the user' do
        user = User.create! valid_attributes
        patch user_url(user),
              params: { user: new_attributes },  as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the user' do
        user = User.create! valid_attributes
        patch user_url(user),
              params: { user: Hash[first_name: ''] },  as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested user' do
      user = User.create! valid_attributes
      expect do
        delete user_url(user), as: :json
      end.to change(User, :count).by(-1)
    end
  end
end
