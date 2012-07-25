class Service2Participant < BaseParticipant

  def on_workitem
    puts "Service2Participant for request item #{request_item.id}"
    workitem.fields["service2_completed"] = true  
    reply
  end

end
