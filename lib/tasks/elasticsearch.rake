namespace :es do

  task reload: :environment do
    Article.__elasticsearch__.create_index! force: true
    Article.__elasticsearch__.refresh_index!
    Article.import
  end

end
