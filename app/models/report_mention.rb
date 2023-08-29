# frozen_string_literal: true

class ReportMention < ApplicationRecord
  belongs_to :mentioning_report, class_name: :Report
  belongs_to :mentioned_report, class_name: :Report

  validates :mentioning_report_id, presence: true, uniqueness: { scope: :mentioned_report_id }
  validates :mentioned_report_id, presence: true
end
