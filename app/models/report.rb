# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :mentioning_relationships, class_name: :ReportMention, foreign_key: :mentioning_report_id, dependent: :destroy, inverse_of: :mentioning_report
  has_many :mentioning_reports, through: :mentioning_relationships, source: :mentioned_report, dependent: :destroy
  has_many :mentioned_relationships, class_name: :ReportMention, foreign_key: :mentioned_report_id, dependent: :destroy, inverse_of: :mentioned_report
  has_many :mentioned_reports, through: :mentioned_relationships, source: :mentioning_report, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  def create_with_report_mentions
    ids_to_other_report = find_ids_to_other_report(content)

    result_of_create = true
    ActiveRecord::Base.transaction do
      result_of_create = save

      ids_to_other_report.each do |id_to_other_report|
        next if ReportMention.exists?(mentioning_report_id: id, mentioned_report_id: id_to_other_report)

        result_of_create &= ReportMention.create(mentioning_report_id: id, mentioned_report_id: id_to_other_report)
      end

      raise ActiveRecord::Rollback unless result_of_create
    end

    result_of_create
  end

  def update_with_report_mentions(report_params)
    new_mentioning_ids = find_ids_to_other_report(report_params[:content])
    old_mentioning_ids = mentioning_reports.each.map(&:id)

    result_of_update = true
    ActiveRecord::Base.transaction do
      result_of_update = update(report_params)

      old_mentioning_ids.difference(new_mentioning_ids).each do |id_to_be_deleted|
        result_of_update &= ReportMention.find_by(mentioning_report_id: id, mentioned_report_id: id_to_be_deleted)&.destroy
      end

      new_mentioning_ids.difference(old_mentioning_ids).each do |id_to_be_saved|
        result_of_update &= ReportMention.create(mentioning_report_id: id, mentioned_report_id: id_to_be_saved)
      end

      raise ActiveRecord::Rollback unless result_of_update
    end

    result_of_update
  end

  private

  def find_ids_to_other_report(text)
    domain_path = 'http://localhost:3000/reports/'
    ids_to_report = text.scan(/(?<=#{domain_path})[1-9][0-9]*/).uniq.map(&:to_i)
    ids_to_report.delete(id)
    Report.where(id: ids_to_report).pluck(:id)
  end
end
