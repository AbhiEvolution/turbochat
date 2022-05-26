class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room
  before_create :confirm_participant
  has_many_attached :attachments, dependent: :destroy

  validate :validate_attachment_filetypes

  after_create_commit do
    update_parent_room
    broadcast_append_to room
  end


  def chat_attachment(index)
    target = attachments[index]
    return unless attachments.attached?

    if target.image?
      target.variant(resize_to_limit: [150, 150]).processed

    elsif target.video?
      target.variant(resize_to_limit: [150, 150]).processed
    end
  end

  def confirm_participant
    if room.is_private
      is_participant = Participant.where(user_id: user.id, room_id: room.id).first
      throw :abort unless is_participant
    end
  end

  private

  def validate_attachment_filetypes
    return unless attachments.attached?

    attachments.each do |attachment|
      unless attachment.content_type.in?(%w[image/jpeg image/png image/gif video/mp4 video/mpeg audio/vnd.wave
                                            audio/mp3])
        errors.add(:attachments, 'must be a JPEG, PNG, GIF, MP4, MP3, or WAV file')
      end
    end
  end

  def update_parent_room
    room.update(last_message_at: Time.now)
  end

end
