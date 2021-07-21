# frozen_string_literal: true

class TransactionsController < ApplicationController
  def deposit
    account = Account.find(params[:account_id])
    account.deposit(params[:amount].to_i)

    if account.save
      render json: account, status: :created, location: account
    else
      render json: account.errors, status: :unprocessable_entity
    end
  end

  private

  def deposit_params
    params.permit(:amount)
  end
end
