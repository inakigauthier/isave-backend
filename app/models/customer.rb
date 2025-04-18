# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :portfolios, dependent: :destroy
  validates :name, presence: true
end
