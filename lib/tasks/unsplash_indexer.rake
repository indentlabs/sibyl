namespace :unsplash do
  desc "Index more images from Unsplash"
  task index: :environment do
    search_query = ENV['search_query'] || 'person'
    search_results = Unsplash::Photo.search(search_query)

    puts "Searching for images with query #{search_query}"
    search_results.each do |image_result|
      created_image = Image.find_or_initialize_by(raw_source_url: image_result.urls.raw)
      created_image.raw_source_width  = image_result.width
      created_image.raw_source_height = image_result.height
      created_image.thumb_source_url  = image_result.urls.thumb
      created_image.medium_source_url = image_result.urls.regular
      created_image.page_source_url   = image_result.links.html
      created_image.title             = image_result.title
      created_image.description       = image_result.description
      created_image.license           = 'Unsplash'
      created_image.author_name       = image_result.user.name
      created_image.author_url        = image_result.user.links.html

      # todo look at .tags and .photo_tags on image_result
      # :tags:
      # - title: window sill
      # - title: feline
      # - title: stretch
      # - title: pet
      # - title: yawn
      # - title: fur
      # - title: sleep
      # - title: animal
      # - title: interior
      # :photo_tags:
      # - title: window sill
      # - title: feline
      # - title: stretch
      # - title: pet
      # - title: yawn

      puts "Creating image #{created_image.title} - #{created_image.description} from #{created_image.page_source_url}"
      created_image.save!
    end

    puts "There are now #{Image.count} images in the database."
  end
end
