class ChunkInfo < ApplicationRecord
  # Relations
  belongs_to :file_detail

  # Validations
  validates :chunk_number, presence: true, numericality: { greater_than: 0 }
  validates :file_detail_id, presence: true # , uniqueness: { scope: [:chunk_number] }
  validates :last_line_number, presence: true, numericality: { greater_than: 0 }
end
