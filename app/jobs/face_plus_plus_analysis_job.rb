class FacePlusPlusAnalysisJob < ApplicationJob
  queue_as :image_feature_analysis

  FPP_ANALYSIS_SOURCE_KEY = 'faceplusplus'
  FPP_DETECT_ENDPOINT  = 'https://api-us.faceplusplus.com/facepp/v3/detect'

  def perform(*images)
    require 'net/https'
    require 'open-uri'

    images.each do |image|
      # todo ensure image.raw_source_url size is betwen 48x48 and 4096x4096

      url = URI.parse(FPP_DETECT_ENDPOINT)
      request = Net::HTTP::Post.new(url.path)

      request.form_data = {
        'api_key'           => ENV['FPP_API_KEY'],
        'api_secret'        => ENV['FPP_API_SECRET'],
        'image_url'         => image_format_to_use(image),
        'return_landmark'   => 0,
        'return_attributes' => [
          'gender',
          'age',
          'eyestatus',
          'ethnicity'
          #'emotion'
        ].join(','),
      }
      con = Net::HTTP.new(url.host, url.port)
      con.use_ssl = true
      res = con.start {|http| http.request(request)}

      image_data = JSON.parse(res.body)
      if image_data.key?('error_message')
        puts "Error for image #{image.id}: #{image_data['error_message']}"
        next
      end

      image.character_image_qualities.where(analysis_source: FPP_ANALYSIS_SOURCE_KEY).destroy_all
      image_data.fetch('faces', []).each do |face|
        face_attributes = face.fetch('attributes', {})
        next if face_attributes == {}

        image.character_image_qualities.create!(
          analysis_source: FPP_ANALYSIS_SOURCE_KEY,
          gender:          face_attributes.fetch('gender',    {}).fetch('value', nil).try(:downcase),
          skin_tone:       face_attributes.fetch('ethnicity', {}).fetch('value', nil).try(:downcase),
          age:             face_attributes.fetch('age',       {}).fetch('value', nil),
          glasses:         eyestatus_hash_to_key(face_attributes.fetch('eyestatus', {}))
        )
      end
    end

    puts "There are now #{CharacterImageQuality.count} CIQs."
  end

  private

  def eyestatus_hash_to_key(eyestatus_hash)
    # "eyestatus"=>
    #  {"left_eye_status"=>
    #    {"normal_glass_eye_open"=>0.494,
    #     "no_glass_eye_close"=>0.164,
    #     "occlusion"=>0.038,
    #     "no_glass_eye_open"=>98.008,
    #     "normal_glass_eye_close"=>0.0,
    #     "dark_glasses"=>1.296},
    #   "right_eye_status"=>
    #    {"normal_glass_eye_open"=>29.198,
    #     "no_glass_eye_close"=>0.534,
    #     "occlusion"=>0.045,
    #     "no_glass_eye_open"=>63.919,
    #     "normal_glass_eye_close"=>6.27,
    #     "dark_glasses"=>0.034}},

    # Assume no one is wearing any eyepatches or whatever, so lets just read from
    # left_eye_status for now.
    left_eye = eyestatus_hash.fetch('left_eye_status', {})
    dominant_pattern = left_eye.sort_by { |_key, value| value }.last.first

    case dominant_pattern
    when 'normal_glass_eye_open', 'normal_glass_eye_close'
      'glasses'
    when 'no_glass_eye_close', 'no_glass_eye_open'
      'no glasses'
    when 'dark_glasses'
      'sunglasses'
    else
      nil
    end
  end

  def image_format_to_use(image)
    return image.thumb_source_url if image.raw_source_height.nil? || image.raw_source_width.nil?

    height = image.raw_source_height.to_i
    width  = image.raw_source_width.to_i

    # If we can use the full-size original image, we should.
    if height >= 48 && height <= 2000
      if width >= 48 && width <= 2000
        return image.raw_source_url
      end
    end

    # Otherwise, fall back on a thumbnail.
    image.thumb_source_url
  end
end
