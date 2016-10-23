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
