# frozen_string_literal: true

class StaffMember < ApplicationRecord
  include StringNormalizer

  has_many :events, class_name: 'StaffEvent', dependent: :destroy

  before_validation do
    self.email = normalize_as_email(email)
    self.family_name = normalize_as_name(family_name)
    self.given_name = normalize_as_name(given_name)
    self.family_name_kana = normalize_as_furigana(family_name_kana)
    self.given_name_kana = normalize_as_furigana(given_name_kana)
  end

  KATAKANA_REGEXP = /\A[\p{katakana}\u{30fc}]+\z/
  validates :email, presence: true, 'valid_email_2/email': true, uniqueness: {case_sensitive: false}
  validates :family_name, :given_name, presence: true
  validates :family_name_kana, :given_name_kana, presence: true, format: {with: KATAKANA_REGEXP, allow_blank: true}
  validates :start_date, presence: true, date: {
    after_or_equal_to: Time.new(2020, 1, 1),
    before: -> (obj) {1.year.from_now.to_date},
    allow_blank: true
  }
  validates :end_date, date: {
    after: :start_date,
    before: -> (obj) {1.year.from_now.to_date},
    allow_blank: true
  }

  def password=(raw_password)
    if raw_password.is_a?(String)
      self.hashed_password = BCrypt::Password.create(raw_password)
    elsif raw_password.nil?
      self.hashed_password = nil
    end
  end

  def active?
    !suspended? && start_date <= Time.zone.today && (end_date.nil? || end_date > Time.zone.today)
  end
end
