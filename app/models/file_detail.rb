class FileDetail < ApplicationRecord
  # Relations
  has_many :chunk_infos

  # Validations
  validates :size, allow_blank: true, numericality: { greater_than: 0 }
  validates :lines_number, allow_blank: true, numericality: { greater_than: 0 }
  validates :name, presence: true, uniqueness: true
end
