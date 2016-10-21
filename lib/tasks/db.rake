namespace :db do
  task :properties => :environment do
    %w(db:seed:properties db:seed:articles).each do |rake_task|
      Rake::Task[rake_task].invoke
    end
  end

  namespace :seed do

    task :properties => :environment do

      Management.create!([
        { name: "Ninja" },
        { name: "Samurai" },
        { name: "Shogun" },
      ])

      Management.all.each do |management|
        10.times do
          property = management.properties.create!(
            :name       => Faker::Team.name,
            :address    => Faker::Address.street_address,
            :city       => Faker::Address.city,
            :state      => Faker::Address.state,
            :zip        => Faker::Address.zip,
            :country    => Faker::Address.country,
            :latitude   => Faker::Address.latitude,
            :longitude  => Faker::Address.longitude,
          )

          20.times do
            property.floorplans.create!(
              :name        => Faker::Color.color_name,
              :rent        => Faker::Commerce.price,
              :description => Faker::Hacker.say_something_smart,
            )
          end
        end
      end
    end

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
