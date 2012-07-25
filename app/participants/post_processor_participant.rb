class PostProcessorParticipant < BaseParticipant

  def on_workitem
    puts "PostProcessorParticipant for request item #{request_item.id}"
    workitem.fields["post_processor_completed"] = true  
    reply
  end
end
