# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :set_account, only: %i[show destroy]

  def show
    render json: @account
  end

  def create
    user = User.find_by(identification_number: params[:identification_number])
    
    account = user.accounts.new(account_params)

    if account.save
      render json: account, status: :created, location: account
    else
      render json: account.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @account.destroy
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:currency)
  end
end
