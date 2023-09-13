# frozen_string_literal: true

require 'application_system_test_case'

class ReportsTest < ApplicationSystemTestCase
  setup do
    FactoryBot.rewind_sequences
    @report = create(:report_with_user)
    visit root_url
    fill_in 'Eメール', with: 'test1@example.com'
    fill_in 'パスワード', with: 'password'
    click_on 'ログイン'

    # ログイン処理の完了を待つためにスリープを入れている
    # （ログイン処理が完了する前に、各テストを実行してしまい、エラーになる）
    sleep(1)
  end

  test 'visiting the index' do
    visit reports_url

    assert_selector 'h1', text: '日報の一覧'
  end

  test 'should create report' do
    visit reports_url
    click_on '日報の新規作成'

    fill_in 'タイトル', with: 'Railsでテストを書く'
    fill_in '内容', with: 'テストデータの作成にfixturesを使用した後、FactoryBotも試してみた'
    click_on '登録する'

    assert_text '日報が作成されました。'
    assert_text 'タイトル: Railsでテストを書く'
    assert_text '内容: テストデータの作成にfixturesを使用した後、FactoryBotも試してみた'
    assert_text '作成者: test1'
  end

  test 'should not create report' do
    visit reports_url
    click_on '日報の新規作成'

    fill_in 'タイトル', with: ''
    fill_in '内容', with: ''
    click_on '登録する'

    assert_text '2件のエラーがあるため、この日報は保存できませんでした'
    assert_text 'タイトルを入力してください'
    assert_text '内容を入力してください'
  end

  test 'should update Report' do
    visit report_url(@report)
    click_on 'この日報を編集'

    assert_no_text 'タイトル: Railsでテストを書く'
    assert_no_text '内容: テストデータの作成にfixturesを使用した後、FactoryBotも試してみた'
    assert_no_text '作成者: test1'

    fill_in 'タイトル', with: 'Railsでテストを書く'
    fill_in '内容', with: 'テストデータの作成にfixturesを使用した後、FactoryBotも試してみた'
    click_on '更新する'

    assert_text '日報が更新されました。'
    assert_text 'タイトル: Railsでテストを書く'
    assert_text '内容: テストデータの作成にfixturesを使用した後、FactoryBotも試してみた'
    assert_text '作成者: test1'
  end

  test 'should not update Report' do
    visit report_url(@report)
    click_on 'この日報を編集'

    fill_in 'タイトル', with: ''
    fill_in '内容', with: ''
    click_on '更新する'

    assert_text '2件のエラーがあるため、この日報は保存できませんでした'
    assert_text 'タイトルを入力してください'
    assert_text '内容を入力してください'
  end

  test 'should destroy Report' do
    visit report_url(@report)
    assert_text 'Report 1'
    assert_text 'Content 1'
    click_on 'この日報を削除'

    assert_text '日報が削除されました。'
    assert_no_text 'Report 1'
    assert_no_text 'Content 1'
  end
end
