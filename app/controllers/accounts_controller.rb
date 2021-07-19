# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :set_account, only: %i[show update destroy]

  def show
    render json: @account
  end

  def create
    user = User.find_by(identification_number: params[:identification_number])

    user.accounts.create(account_params)
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
