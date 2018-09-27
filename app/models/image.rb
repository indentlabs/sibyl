class Image < ApplicationRecord
  has_many :character_image_qualities, dependent: :destroy

  after_create :queue_image_analysis_jobs
  def queue_image_analysis_jobs
    FacePlusPlusAnalysisJob.perform_later(self)
    AzureFaceAnalysisJob.perform_later(self)
  end

  def merged_character_image_qualities
    base_attributes = {}
    character_image_qualities.each do |ciq|
      base_attributes.merge!(ciq.attributes.reject { |k, v| v.nil? })
    end

    base_attributes
  end
end
