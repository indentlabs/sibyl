class Image < ApplicationRecord
  has_many :character_image_qualities, dependent: :destroy

  after_create :queue_image_analysis_jobs
  def queue_image_analysis_jobs
    FacePlusPlusAnalysisJob.perform_later(self)
    AzureFaceAnalysisJob.perform_late(self)
  end

  def merged_character_image_qualities
    # todo
    character_image_qualities.first || CharacterImageQuality.new
  end
end
