class RequestItem < ActiveRecord::Base
  # attr_accessible :error, :service1_id, :service2_id, :state

  has_paper_trail

  PDEF_PROCESS = Ruote.process_definition :name => 'process_request_item' do

    subprocess :ref => 'processing'

    process_definition :name => 'processing' do
      sequence :on_error=>"review_error" do
        
        request_item_transition :event=>"process!"
        
        repeat :break_if=>"${f:service1_completed}" do
          service1
          wait "5s"
        end
        
        repeat :break_if=>"${f:service2_completed}" do
          service2
          wait "5s"
        end
      
        request_item_transition :event=>"monitor!"

        repeat :break_if=>"${f:monitoring_completed}" do
          request_item_monitor
          wait "20s"
        end

        request_item_transition :event=>"post_process!"

        repeat :break_if=>"${f:post_processor_completed}" do
          post_processor
          wait "5s"
        end        

        request_item_transition :event=>"complete!"

      end # end sequence

    end # end processing process_definition
    
    process_definition :name=>"review_error" do

      request_item_error_logger
      
      #participant :request_item_transition, :event=>"error!"  
      
      request_item_admin :task=>'review error'

      given do
        that "${f:review_action} == 'reprocess'" do
          subprocess :ref => 'processing'
        end
        subprocess :ref=>"cancel_item"

      end

    end # end error process_definition

    process_definition :name=>"cancel_item" do
      request_item_transition :event=>"cancel!"
    end # end cancel process_definition


    # define 'handle_issue' do
    #   participant :error_notifier, :msg => 'process ${wfid} has gone ballistic'
    # end
  

  end

  state_machine :state, :initial=>:pending do

    event :process do 
      transition [:pending, :error]=>:processing
    end

    event :complete do
      transition :post_processing=>:completed
    end

    event :error do
      transition any=>:error
    end

    event :reprocess do
      transition :error=>:processing 
    end

    event :cancel do
      transition any=>:cancelled
    end

    event :monitor do
      transition :processing=>:monitoring
    end

    event :post_process do
      transition :monitoring=>:post_processing
    end

  end # end state machine definitions

  after_create do
    self.wfid = RuoteKit.engine.launch(PDEF_PROCESS, :request_item_id=>self.id)
    self.save
  end

  def workflow_process
    RuoteKit.engine.process(self.wfid)
  end

  def retry_failed_process
    p = workflow_process
    if p.respond_to?(:errors) && !p.errors.empty?
      RuoteKit.engine.replay_at_error(workflow_process.errors.first)
    end
  end

  def workitems_by_participant(part)
    items = RuoteKit.storage_participant.query(:wfid=>wfid, :participant=>part)
  end

  def reprocess
    items = workitems_by_participant "request_item_admin"
    return false if items.empty?
    items[0].fields["review_action"] = "reprocess"
    error_message = nil
    save
    RuoteKit.storage_participant.proceed(items[0])

  end

  def cancel_workflow
    items = workitems_by_participant "request_item_admin"
    return false if items.empty?
    RuoteKit.storage_participant.proceed(items[0])    
  end


end
