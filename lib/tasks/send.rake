namespace :parser do
  task send: :environment do
    require 'net/http'
    require 'uri'
    bot = Rails.application.secrets.bot
    uri = URI.parse("https://api.telegram.org/bot#{bot}/sendMessage")
    msg = ''
    msg << 'Приветики!'
    msg << "\nСегодня #{DateTime.now.strftime('%d.%m.%y')}"
    msg << "\nМосковское время #{DateTime.now.strftime('%H:%M')}"
    parameters = {
      text: msg,
      chat_id: '@urodru'
    }
    Net::HTTP.post_form(uri, parameters)
  end
end
