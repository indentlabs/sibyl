namespace :daily do
  desc "Ensure all analysis is up to date each day"
  task analyze: :environment do
    Image.all.shuffle.each do |image|
      image.queue_image_analysis_jobs
      sleep(15)
    end
  end
end
