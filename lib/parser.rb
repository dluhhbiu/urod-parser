# Parser
module Parser
  class << self
    require 'nokogiri'
    require 'open-uri'
    require 'net/http'
    require 'uri'
    URL = 'http://urod.ru'.freeze

    def parse
      doc = Nokogiri::HTML(open(URL))
      doc.css('.infoNews>a').each do |item|
        save(item)
      end
    end

    def send_new_news
      News.where(send_msg: false).order(:urod_id).each do |news|
        msg = ''
        msg << news.title
        msg << "\n"
        msg << news.link
        send_msg(msg)
        news.update(send_msg: true)
      end
    end

    private

    def save(item)
      News.find_or_create_by(
        urod_id: item['href'].gsub(/\D/, '').to_i,
        link: URL + item['href'],
        title: item.css('.s3').first.content.strip
      )
    end

    def send_msg(msg)
      bot = Rails.application.secrets.bot
      Net::HTTP.post_form(
        URI.parse("https://api.telegram.org/bot#{bot}/sendMessage"),
        text: msg,
        chat_id: '@urodru'
      )
    end
  end
end
