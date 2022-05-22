class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  scope :all_except, ->(user) { where.not(id: user)}
  after_create_commit { broadcast_append_to 'users' }

  has_many :messages, dependent: :destroy
  has_one_attached :avatar, dependent: :destroy
  validates :avatar,  presence: true
  validates :name,  presence: true

  enum status: %i[offline away online]

  after_update_commit { broadcast_update}
  after_commit :add_default_avatar, on: %i[create update]

  def avatar_thumbnail
     avatar.variant(resize_to_limit: [150, 150]).processed
  end

  def chat_pfp
     avatar.variant(resize_to_limit: [50, 50]).processed
  end

  def broadcast_update
    broadcast_replace_to 'user_status', partial: 'users/status', user:self
  end

  def status_to_css
    case status
    when 'online'
      'bg-success'
    when 'away'
      'bg-warning'
    when 'offline'
      'bg-dark'
    else
      'bg-danger'
    end
  end

  private

  def add_default_avatar
    return if avatar.attached?
    avatar.attached(
      io: File.open(Rails.root.join('app', 'assets', 'images', 'default_avatar.jpg' )),
      filename: 'default_avatar.jpg',
      content_type: 'image/jpg'
    )
  end
end


# def chat_pfp
#   #  avatar.variant(resize_to_limit: [50, 50]).processed
#   # else
#   #   avatar.attached(
#   #     io: File.open(Rails.root.join('app', 'assets', 'images', 'default_avatar.jpg' )),
#   #     filename: 'default_avatar.jpg',
#   #     content_type: 'image/jpg'
#   #   )
#   #   return self.avatar.variant(resize: '50x50')
#   # end
#    avatar.variant(resize_to_limit: [50, 50]).processed
# end

# def avatar_thumbnail
#   avatar.variant(resize_to_limit: [150, 150]).processed
#  # return self.avatar.variant(resize: '50x50')
# end