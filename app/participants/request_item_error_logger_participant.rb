class RequestItemErrorLoggerParticipant <  BaseParticipant
  def on_workitem
    item = request_item
    puts "RequestItemErrorLoggerParticipant for request item #{item.id}"
    puts "SENDING EMAIL"
    # EXAMPLE ERROR HASH
    # "__error__": {
    # "fei": {
    #   "engine_id": "master",
    #   "wfid": "20120711-2107-bizayaya-dabuniju",
    #   "subid": "1a368b09566968d30d8c06b5ee23d781",
    #   "expid": "0_0_0"
    # },
    # "at": "2012-07-11 21:29:32.583590 UTC",
    # "class": "StateMachine::InvalidTransition",
    # "message": "Cannot transition state via :process from :processing (Reason(s): State cannot transition via \"process\")",
    # "trace": [
    #   "/Users/sgulics/.rvm/gems/ruby-1.9.2-p290@new_ruote_poc/gems/state_machine-1.1.2/lib/state_machine/event.rb:241:in `block in add_actions'",
    #   "/Users/sgulics/.rvm/gems/ruby-1.9.2-p290@new_ruote_poc/gems/state_machine-1.1.2/lib/state_machine/machine.rb:753:in `call'",
    #   "/Users/sgulics/.rvm/gems/ruby-1.9.2-p290@new_ruote_poc/gems/state_machine-1.1.2/lib/state_machine/machine.rb:753:in `block (2 levels) in define_helper'",
    #   "/Users/sgulics/source/new_ruote_poc/app/participants/request_item_state_transition_participant.rb:6:in `on_workitem'",
    #   "/Users/sgulics/.rvm/gems/ruby-1.9.2-p290@new_ruote_poc/bundler/gems/ruote-05dd683cd901/lib/ruote/svc/dispatch_pool.rb:198:in `block in participant_send'",
    #   "/Users/sgulics/.rvm/gems/ruby-1.9.2-p290@new_ruote_poc/bundler/gems/ruote-05dd683cd901/lib/ruote/svc/dispatch_pool.rb:194:in `each'",
    #   "/Users/sgulics/.rvm/gems/ruby-1.9.2-p290@new_ruote_poc/bundler/gems/ruote-05dd683cd901/lib/ruote/svc/dispatch_pool.rb:194:in `participant_send'",
    #   "/Users/sgulics/.rvm/gems/ruby-1.9.2-p290@new_ruote_poc/bundler/gems/ruote-05dd683cd901/lib/ruote/svc/dispatch_pool.rb:74:in `do_dispatch'",
    #   "/Users/sgulics/.rvm/gems/ruby-1.9.2-p290@new_ruote_poc/bundler/gems/ruote-05dd683cd901/lib/ruote/svc/dispatch_pool.rb:102:in `block in do_threaded_dispatch'"
    # ]
    unless item.error?
      item.error
      if workitem.fields["__error__"]
        item.error_message = workitem.fields["__error__"]["message"]
      end
      puts "error: #{item.error_message}"
      item.save!
    end
    # if rand(100) % 5 == 0
    #   puts("Failing BillingService")
    #   #raise "Failing BillingService"
    # else
    #   puts("BillingService Success")
    #   workitem.fields["billing_service_completed"] = true  
    # end
    # workitem.fields["service1_completed"] = true  
    reply
  end
end
