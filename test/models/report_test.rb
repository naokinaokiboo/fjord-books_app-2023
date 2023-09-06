# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  setup do
    FactoryBot.rewind_sequences
  end

  test 'editable? should return true' do
    report = build(:report_with_user)
    assert_equal true, report.editable?(report.user)
  end

  test 'editable? should return false' do
    report1 = build(:report_with_user)
    report2 = build(:report_with_user)
    assert_equal false, report2.editable?(report1.user)
  end

  test 'created_on should return Date type' do
    report = build(:report, created_at: Time.zone.parse('2023-09-06'))
    assert_equal Date.new(2023, 9, 6), report.created_on
  end

  test 'save_mentions should link other reports' do
    report1 = create(:report_with_user)
    report2 = create(:report_with_user)
    report3 = create(:report_with_user)
    report4 = create(:report_with_user)
    report = create(:report_with_user)
    report.content = <<~TEXT
      日報:http://localhost:3000/reports/1を参考にする
      日報:http://localhost:3000/reports/2を参考にする
      日報:http://localhost:3000/reports/3を参考にする
      日報:http://localhost:3000/reports/4を参考にする
      日報:http://localhost:3000/reports/5を参考にする
    TEXT

    assert_equal 0, report.mentioning_reports.size
    report.send(:save_mentions)
    assert_equal [report1, report2, report3, report4], report.mentioning_reports
  end

  test 'save_mentions should not link other reports' do
    create(:report_with_user)
    create(:report_with_user)
    create(:report_with_user)
    create(:report_with_user)
    report = create(:report_with_user)
    report.content = <<~TEXT
      参考の日報は:http://localhost:3000/reports/です。
      参考の日報は:http://localhost:3000/reports/です。
      参考の日報は:http://localhost:3000/reports/です。
      参考の日報は:http://localhost:3000/reports/です。
      参考の日報は:http://localhost:3000/reports/です。
    TEXT

    assert_equal 0, report.mentioning_reports.size
    report.send(:save_mentions)
    assert_equal 0, report.mentioning_reports.size
  end
end
