class RequestItemMonitorParticipant < BaseParticipant
  def on_workitem
    puts "RequestItemMonitorParticipant for request item #{request_item.id}"
    workitem.fields["monitoring_completed"] = true  
    reply
  end
end
