class Image < ApplicationRecord
  has_many :character_image_qualities, dependent: :destroy

  after_create :queue_image_analysis_job
  def queue_image_analysis_job
    FacePlusPlusAnalysisJob.perform_later(self)
    # todo other analysis APIs
  end
end
