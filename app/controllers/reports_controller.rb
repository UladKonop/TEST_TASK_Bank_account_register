# frozen_string_literal: true

class ReportsController < ApplicationController
  def index
    report, errors = ReportsManager.new(report_params).call

    if report.present?
      render json: report, status: :created
    else
      render json: errors, status: :unprocessable_entity
    end
  end

  private

  def report_params
    params.require(:account).permit(
      :user_ids,
      :date_from,
      :date_to,
      :report_type
    )
  end
end
