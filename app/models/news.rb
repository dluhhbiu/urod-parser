# model News
class News < ActiveRecord::Base
  validates :urod_id, uniqueness: true
  after_create :remove_old_news

  def remove_old_news
    News.all.order(:urod_id).first.destroy if News.count >= 100
  end
end
