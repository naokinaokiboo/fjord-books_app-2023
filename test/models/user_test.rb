# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    FactoryBot.rewind_sequences
  end

  test 'name_or_email should return name' do
    user = build(:user)
    assert_equal user.name, user.name_or_email
  end

  test 'name_or_email should return email' do
    user = build(:noname_user)
    assert_equal user.email, user.name_or_email
  end
end
