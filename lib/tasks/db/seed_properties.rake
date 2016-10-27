# namespace :db do
#   namespace :seed do
#     task :properties => :environment do
#
#       state_zip_mapping = {
#         "DC" => %w(20001 20005 20009),
#         "VA" => %w(20101 20108 20120),
#         "MD" => %w(20601 20857 20901),
#       }
#       rents           = (800..2000).step(100).to_a
#       bedroom_counts  = (1..4).to_a
#       bathroom_counts = (1..3).to_a
#
#
#       # ---
#       # Creating a management that we know well.
#       # ---
#
#
#       management = Management.create!(name: "Example Management")
#       properties = management.properties.create!(
#          YAML.load_file("#{Rails.root}/db/seeds/properties.yml")
#       )
#
#       properties.each do |property|
#         10.times do
#           property.floorplans.create!(
#             :name           => Faker::Name.first_name,
#             :description    => Faker::Hacker.say_something_smart,
#             :rent           => rents.sample,
#             :bedroom_count  => bedroom_counts.sample,
#             :bathroom_count => bathroom_counts.sample,
#           )
#         end
#       end
#
#
#       # ---
#       # Creating another management with random info.
#       # ---
#
#
#       management = Management.create!( name: "Ninja Company" )
#
#       10.times do
#         state = state_zip_mapping.keys.sample
#         zip   = state_zip_mapping[state].sample
#         property = management.properties.create!(
#           :name        => Faker::Team.name,
#           :description => Faker::Hacker.say_something_smart,
#           :address     => Faker::Address.street_address,
#           :city        => Faker::Address.city,
#           :state       => state,
#           :zip         => zip,
#           :country     => Faker::Address.country,
#           :latitude    => Faker::Address.latitude,
#           :longitude   => Faker::Address.longitude,
#         )
#
#         10.times do
#           property.floorplans.create!(
#             :name           => Faker::Color.color_name,
#             :description    => Faker::Hacker.say_something_smart,
#             :rent           => rents.sample,
#             :bedroom_count  => bedroom_counts.sample,
#             :bathroom_count => bathroom_counts.sample,
#           )
#         end
#       end
#
#
#       # Add data to the search index
#       # https://github.com/ankane/searchkick
#       Property.reindex
#     end
#   end
# end
