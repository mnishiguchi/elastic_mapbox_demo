Article.delete_all
Property.delete_all


# ---
# Create Articles
# ---


pages = Dir[ Rails.root + 'db/seeds/*.txt' ]
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


# ---
# Create Properties
# ---

# 
# # Import feeds.
# feeds = Dir.glob("#{Rails.root}/db/data_files/feed_*.xml")
#
# progress_bar = ProgressBar.create(
#   title: "Importing Feeds",
#   total: feeds.count, format: '%t %e %p%% ||%b>>%i||'
# )
#
# feeds.each do |feed|
#   xml = open(feed, 'rb') { |io| io.read }
#   property_hash = Hash.from_xml(xml)["PhysicalProperty"]
#   properties = MitsParser::Properties.parse(property_hash)
#
#   properties.each do |property|
#     Property.create!(
#       :raw_hash   => property[:raw_hash],
#       :address    => property[:address],
#       :city       => property[:city],
#       :county     => property[:county],
#       :state      => property[:state],
#       :zip        => property[:zip],
#       :country    => property[:country],
#       :latitude   => property[:latitude],
#       :longigute  => property[:longitude],
#     )
#   end
#
#   progress_bar.increment
# end
