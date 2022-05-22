class AppearanceChannel < ApplicationCable::Channel
  def subscribed
     stream_from "appearance_channel"
  end

  def unsubscribed
    stop_stream_from "appearance_channel"
    offline
  end

  def online
    status = User.status[:online]
    broadcast_new_status(status)
  end

  def away
    status = User.status[:away]
    broadcast_new_status(status)
    
  end

  def offline
    status = User.status[:offline]
    broadcast_new_status(status)
  end

  def receive(data)
    ActionCable.server.broadcast('appearence_channel', data)
  end

  private

  def broadcast_new_status(status)
    current_user.update!(status: status)
  end  
end
