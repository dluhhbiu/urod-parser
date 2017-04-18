namespace :parser do
  task parse_and_send: :environment do
    Parser.parse
    Parser.send_new_news
  end
end
