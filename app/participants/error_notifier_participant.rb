class ErrorNotifierParticipant < BaseParticipant

  def on_workitem
    puts("SENDING EMAIL FROM ERROR NOTIFIER")
    reply
  end

end