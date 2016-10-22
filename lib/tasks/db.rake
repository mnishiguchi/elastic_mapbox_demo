namespace :db do
  task :seed => :environment do
    [
      "db:seed:properties",
      "db:seed:articles"
    ].each do |rake_task|
      Rake::Task[ rake_task ].invoke
    end
  end

  namespace :seed do

    task :properties => :environment do

      managements = Management.create!([
        { name: "Ninja" },
        { name: "Samurai" },
        { name: "Shogun" },
      ])

      rents           = (800..2000).step(100).to_a
      bedroom_counts  = (1..4).to_a
      bathroom_counts = (1..3).to_a

      managements.each do |management|

        10.times do
          property = management.properties.create!(
            :name        => Faker::Team.name,
            :description => Faker::Hacker.say_something_smart,
            :address     => Faker::Address.street_address,
            :city        => Faker::Address.city,
            :state       => Faker::Address.state,
            :zip         => Faker::Address.zip[0..4],
            :country     => Faker::Address.country,
            :latitude    => Faker::Address.latitude,
            :longitude   => Faker::Address.longitude,
          )

          20.times do
            property.floorplans.create!(
              :name           => Faker::Color.color_name,
              :description    => Faker::Hacker.say_something_smart,
              :rent           => rents.sample,
              :bedroom_count  => bedroom_counts.sample,
              :bathroom_count => bathroom_counts.sample,
            )
          end
        end
      end

      # Add data to the search index
      # https://github.com/ankane/searchkick
      Property.reindex
    end


    # ---
    # ---


    task :articles => :environment do
      Article.destroy_all

      pages = Dir[ Rails.root + 'db/seeds/articles/*.txt' ]
      pages.each do |page|
        text = File.open(page).read
        text.gsub!(/\r\n?/, "\n")

        line_num = 0

        title = ''
        body = ''

        text.each_line do |line|
          if line_num == 0
            title = line
          else
            body += line
          end
          line_num += 1
        end

        Article.create( title: title.strip, body: body.strip )
      end
    end

  end
end
