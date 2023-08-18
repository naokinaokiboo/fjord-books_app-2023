# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one_attached :image
  validate :check_image_file_type

  private

  def check_image_file_type
    errors.add(:image, :file_type_error) unless image.content_type.in?(['image/jpg', 'image/png', 'image/gif'])
  end
end
