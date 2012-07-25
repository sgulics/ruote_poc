class BaseParticipant

  include Ruote::LocalParticipant

  def on_cancel
    puts "#{self.class} on_cancel"
  end

  def logger
    Rails.logger
  end

  def request_id
    workitem.fields["request_item_id"]
  end

  def request_item
    RequestItem.find request_id
  end


end
