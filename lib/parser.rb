# Parser
module Parser
  class << self
    require 'nokogiri'
    require 'open-uri'
    require 'open_uri_redirections'
    require 'net/http'
    require 'uri'
    URL = 'http://urod.ru'.freeze
    CHAT_ID = '@urodru'.freeze

    def parse
      doc = Nokogiri::HTML(open(URL, allow_redirections: :all))
      doc.css('.BodyNewsStyle:has(.infoNews>a)').each do |item|
        save(item)
      end
    end

    def send_new_news
      News.where(send_msg: false).order(:urod_id).each do |news|
        build_msg = method("build_msg_#{news.format}")
        data = build_msg.call(news)
        send_msg(data[:action], data[:data])
        news.update(send_msg: true)
      end
    end

    private

    def save(item)
      head = build_head(item)
      return if News.find_by(urod_id: head[:urod_id])
      body = build_body(item)
      News.create(
        urod_id: head[:urod_id],
        link: head[:link],
        title: head[:title],
        format: body[:format],
        text: body[:text]
      )
    end

    def build_head(item)
      head = item.css('.infoNews>a').first
      {
        urod_id: head['href'].gsub(/\D/, '').to_i,
        link: URL + head['href'],
        title: head.css('.s3').first.content.strip
      }
    end

    def build_body(item)
      body = item.css('.NewsContent').first
      body.search('div').remove
      if body.css('img').present?
        { format: 'img', text: body.css('img').first['src'] }
      elsif body.css('iframe').present?
        { format: 'video', text: body.css('iframe').first['src'] }
      elsif body.content.strip.blank?
        { format: 'none', text: nil }
      else
        { format: 'text', text: body.content.strip }
      end
    end

    def build_msg_none(news)
      {
        action: 'sendMessage',
        data: {
          text: "*#{news.title}*\n#{news.link}",
          parse_mode: 'markdown'
        }
      }
    end

    def build_msg_text(news)
      {
        action: 'sendMessage',
        data: {
          text: "*#{news.title}*\n#{news.text}\n#{news.link}",
          parse_mode: 'markdown'
        }
      }
    end

    def build_msg_video(news)
      {
        action: 'sendMessage',
        data: {
          text: "<b>#{news.title}</b>\n#{news.text}\n#{news.link}",
          parse_mode: 'html'
        }
      }
    end

    def build_msg_img(news)
      {
        action: 'sendPhoto',
        data: {
          photo: news.text,
          caption: "#{news.title}\n#{news.link}"
        }
      }
    end

    def send_msg(action, data)
      bot = Rails.application.secrets.bot
      data[:chat_id] = CHAT_ID
      Net::HTTP.post_form(
        URI.parse("https://api.telegram.org/bot#{bot}/#{action}"),
        data
      )
    end
  end
end
