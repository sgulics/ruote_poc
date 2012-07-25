class Service1Participant < BaseParticipant

  def on_workitem
    puts "Service1Participant for request item #{request_item.id}"
    workitem.fields["service1_completed"] = true  
    reply
  end

end
