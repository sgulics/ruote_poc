class RequestItemStateTransitionParticipant < BaseParticipant
  

  def on_workitem
    puts(workitem.fields["params"]["event"])
    request_item.send(workitem.fields["params"]["event"])
    reply
  end

  
  

end