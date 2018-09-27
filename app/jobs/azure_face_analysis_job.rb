class AzureFaceAnalysisJob < ApplicationJob
  queue_as :image_feature_analysis

  AF_ENDPOINT = 'https://westcentralus.api.cognitive.microsoft.com/face/v1.0'
  AF_ANALYSIS_SOURCE_KEY = 'azure_face'

  def perform(*images)
    require 'net/https'
    require 'open-uri'

    images.each do |image|
      require 'net/http'

      # You must use the same location in your REST call as you used to get your
      # subscription keys. For example, if you got your subscription keys from  westus,
      # replace "westcentralus" in the URL below with "westus".
      uri = URI('https://westcentralus.api.cognitive.microsoft.com/face/v1.0/detect')
      uri.query = URI.encode_www_form({
          # Request parameters
          'returnFaceId'         => 'false',
          'returnFaceLandmarks'  => 'false',
          'returnFaceAttributes' => 'age,gender,glasses,hair,facialHair'
      })

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Ocp-Apim-Subscription-Key'] = ENV['AZURE_FACE_KEY_1']
      request['Content-Type'] = 'application/json'
      request.body = "{\"url\": \"" + (image.medium_source_url || image.raw_source_url) + "\"}"
      response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') { |http| http.request(request) }
      response_json = JSON.parse(response.body)

      image.character_image_qualities.where(analysis_source: AF_ANALYSIS_SOURCE_KEY).destroy_all

      if response_json.is_a?(Array)
        response_json.each do |face_data|
          face_attributes = face_data.fetch('faceAttributes', {})
          next if face_attributes == {}

          hair_length, hair_color = hair_hash_to_key(face_attributes.fetch('hair', {}))
          image.character_image_qualities.create!(
            analysis_source: AF_ANALYSIS_SOURCE_KEY,
            gender:          face_attributes.fetch('gender',    {}).try(:downcase),
            age:             face_attributes.fetch('age',       {}).try(:to_i),
            glasses:         glasses_to_key(face_attributes.fetch('glasses', nil)),
            hair_length:     hair_length,
            hair_color:      hair_color
          )
        end
      end
    end

    puts "There are now #{CharacterImageQuality.count} CIQs."
  end

  private

  def glasses_to_key(value)
    case value
    when 'NoGlasses'
      'no glasses'
    else
      value
    end
  end

  def hair_hash_to_key(hair_hash)
    if hair_hash.fetch('bald', 0) > 75 # accuracy
      ['bald', 'bald']
    else
      hair_length = nil # todo
      hair_color  = hair_hash.fetch('hairColor', []).sort_by { |c| c['confidence'] }.last.fetch('color', nil)

      return [hair_length, hair_color]
    end
  end
end
