# Clean up
Article.destroy_all

articles = Dir[ Rails.root + 'db/seeds/*.txt' ]
articles.each do |article|
  text = File.open(article).read
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
