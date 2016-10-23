namespace :db do
  task :seed => :environment do
    [
      "db:seed:properties",
      "db:seed:articles"
    ].each do |rake_task|
      Rake::Task[ rake_task ].invoke
    end
  end
end


namespace :db do
  namespace :seed do
    task :properties => :environment do

      state_zip_mapping = {
        "DC" => %w(20001 20005 20009),
        "VA" => %w(20101 20108 20120),
        "MD" => %w(20601 20857 20901),
      }
      rents           = (800..2000).step(100).to_a
      bedroom_counts  = (1..4).to_a
      bathroom_counts = (1..3).to_a


      # ---
      # Creating a management that we know well.
      # ---


      management = Management.create!(name: "Example Management")
      properties = management.properties.create!([
        {
          :name        => "White House",
          :description => "The White House is the official residence and principal workplace of the President of the United State.",
          :address     => "1600 Pennsylvania Ave NW",
          :city        => "Washington",
          :state       => "DC",
          :zip         => "20500",
          :country     => "United States",
          :latitude    => 38.897676,
          :longitude   => -77.036529,
        },
        {
          :name        => "Dulles Town Center",
          :description => "The Dulles Town Center is a two-level enclosed shopping mall in Sterling, Loudoun County, Virginia, United States, located five miles north of the Washington Dulles International Airport. ",
          :address     => "21100 Dulles Town Cir",
          :city        => "Sterling",
          :state       => "VA",
          :zip         => "20166",
          :country     => "United States",
          :latitude    => 39.024243,
          :longitude   => -77.415367,
        }
      ])

      properties.each do |property|
        10.times do
          property.floorplans.create!(
            :name           => Faker::Color.color_name,
            :description    => Faker::Hacker.say_something_smart,
            :rent           => rents.sample,
            :bedroom_count  => bedroom_counts.sample,
            :bathroom_count => bathroom_counts.sample,
          )
        end
      end


      # ---
      # Creating another management with random info.
      # ---


      management = Management.create!( name: "Ninja Company" )

      10.times do
        state = state_zip_mapping.keys.sample
        zip   = state_zip_mapping[state].sample
        property = management.properties.create!(
          :name        => Faker::Team.name,
          :description => Faker::Hacker.say_something_smart,
          :address     => Faker::Address.street_address,
          :city        => Faker::Address.city,
          :state       => state,
          :zip         => zip,
          :country     => Faker::Address.country,
          :latitude    => Faker::Address.latitude,
          :longitude   => Faker::Address.longitude,
        )

        10.times do
          property.floorplans.create!(
            :name           => Faker::Color.color_name,
            :description    => Faker::Hacker.say_something_smart,
            :rent           => rents.sample,
            :bedroom_count  => bedroom_counts.sample,
            :bathroom_count => bathroom_counts.sample,
          )
        end
      end


      # Add data to the search index
      # https://github.com/ankane/searchkick
      Property.reindex
    end
  end
end


namespace :db do
  namespace :seed do
    task :articles => :environment do
      Article.destroy_all

      pages = Dir[ Rails.root.join('db/seeds/articles/*.txt') ]
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
