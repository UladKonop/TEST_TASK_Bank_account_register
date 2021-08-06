# frozen_string_literal: true

class ReportsController < ApplicationController
  def index
    report, errors = ReportsManager.new(report_params).call

    if errors.blank?
      render json: report, status: :created
    else 
      render json: errors, status: :unprocessable_entity
    end
  end

  private

  def report_params
    params.require(:account).permit(
      :report_type,
      :date_from,
      :date_to,
      user_ids:[],
      tags:[],
    )
  end
end
