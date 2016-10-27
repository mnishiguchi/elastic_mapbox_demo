# Create a management
management = Management.create!(name: "Example Management")

# Create properties to management
properties = management.properties.create!(
   YAML.load_file("#{Rails.root}/db/seeds/properties.yml")
)

# Create floorplans to properties
rents           = (500..3000).step(100).to_a
bedroom_counts  = (1..4).to_a
bathroom_counts = (1..3).to_a

properties.each do |property|
  10.times do
    property.floorplans.create!(
      :name           => Faker::Name.first_name,
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
