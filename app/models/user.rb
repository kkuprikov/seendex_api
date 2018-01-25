class User < ApplicationRecord
  validates :nickname, presence: true

  def last_online_at
    super.to_i
  end

  def created_at
    super.to_i
  end
end
