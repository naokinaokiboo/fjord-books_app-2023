# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[edit update destroy]

  def index
    @reports = Report.includes(:user).order(id: :desc).page(params[:page])
  end

  def show
    @report = Report.find(params[:id])
  end

  # GET /reports/new
  def new
    @report = current_user.reports.new
  end

  def edit; end

  def create
    @report = current_user.reports.new(report_params)
    ids_to_other_report = find_ids_to_other_report(@report.content)
    begin
      ActiveRecord::Base.transaction do
        @report.save!

        ids_to_other_report.each do |id|
          next if ReportMention.exists?(mentioning_report_id: @report.id, mentioned_report_id: id)

          ReportMention.create!(mentioning_report_id: @report.id, mentioned_report_id: id)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      loger.error(e.message)
      render :new, status: :unprocessable_entity
      return
    end
    redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human)
  end

  def update
    new_mentioning_ids = find_ids_to_other_report(report_params[:content])
    old_mentioning_ids = @report.mentioning_reports.each.map(&:id)

    begin
      ActiveRecord::Base.transaction do
        @report.update!(report_params)

        old_mentioning_ids.difference(new_mentioning_ids).each do |id_to_be_deleted|
          ReportMention.find_by(mentioning_report_id: @report.id, mentioned_report_id: id_to_be_deleted).destroy!
        end

        new_mentioning_ids.difference(old_mentioning_ids).each do |id_to_be_saved|
          ReportMention.create!(mentioning_report_id: @report.id, mentioned_report_id: id_to_be_saved)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      loger.error(e.message)
      render :edit, status: :unprocessable_entity
      return
    end
    redirect_to @report, notice: t('controllers.common.notice_update', name: Report.model_name.human)
  end

  def destroy
    @report.destroy

    redirect_to reports_url, notice: t('controllers.common.notice_destroy', name: Report.model_name.human)
  end

  private

  def set_report
    @report = current_user.reports.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:title, :content)
  end

  def find_ids_to_other_report(text)
    domain_path = 'http://localhost:3000/reports/'
    ids_to_report = text.scan(/(?<=#{domain_path})[1-9][0-9]*/).uniq.map(&:to_i)
    ids_to_report.delete(@report.id)
    existing_report_ids = Report.ids
    ids_to_report.delete_if { |id| !existing_report_ids.include?(id) }
  end
end
