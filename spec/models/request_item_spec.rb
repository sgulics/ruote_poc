require 'spec_helper'

class ThrowErrorParticipant < BaseParticipant

  def on_workitem
    puts "I am raising an error"
    raise "ERROR_THROWN"
    
  end
end

describe RequestItem do

  # need to turn off transactional fixtures so that participants
  # can find the RequestItem
  self.use_transactional_fixtures = false

  context "workflow" do
    
    before(:each) do
      @engine = Ruote::Dashboard.new(Ruote::Worker.new(Ruote::HashStorage.new()))
      @engine.register do
        participant :request_item_transition, RequestItemStateTransitionParticipant
        participant :service1, Service1Participant
        participant :service2, Service2Participant
        participant :request_item_monitor, RequestItemMonitorParticipant
        participant :post_processor, PostProcessorParticipant
        participant :request_item_admin, Ruote::StorageParticipant
        participant :request_item_error_logger, RequestItemErrorLoggerParticipant
      end
      RuoteKit.engine = @engine
    end

    it "should create a wfid" do
      item = RequestItem.create
      item.wfid.should_not be_nil
      RuoteKit.engine.wait_for(item.wfid)
    end

    it "should end in completed state" do
      item = RequestItem.create
      RuoteKit.engine.wait_for(item.wfid)
      item.reload
      item.state.should eql("completed")
    end

    it "should move the state of the item to monitoring when starting the monitoring phase" do
      item = RequestItem.create
      RuoteKit.engine.wait_for :request_item_monitor
      item.reload
      item.state.should eql("monitoring")
      RuoteKit.engine.wait_for(item.wfid)
    end

    it "should move the state of the item to post_processing when starting the post processing phase" do
      item = RequestItem.create
      RuoteKit.engine.wait_for :post_processor
      item.reload
      item.state.should eql("post_processing")
      RuoteKit.engine.wait_for(item.wfid)
    end

    context "with errors" do
    
      before(:each) do
        RuoteKit.engine.unregister_participant :service2
        RuoteKit.engine.register_participant :service2, ThrowErrorParticipant
        #RuoteKit.engine = @engine
        @item = RequestItem.create
        RuoteKit.engine.wait_for(:request_item_admin)
        @item.reload
      end

      it "should be in error state" do
        @item.state.should eql("error")
      end

      it "should update item with error message" do
        @item.error_message.should eql("ERROR_THROWN") 
      end

      it "should successfully be able to reprocess" do
        # Need to unregister the participant that will throw the error
        RuoteKit.engine.unregister_participant :service2
        # Register the good participant
        RuoteKit.engine.register_participant :service2, Service2Participant
        @item.reprocess
        RuoteKit.engine.wait_for(@item.wfid)
        @item.reload
        @item.state.should eql("completed")
      end

      it "should cancel the workflow if user chooses to cancel" do
        # Need to unregister the participant that will throw the error
        RuoteKit.engine.unregister_participant :service2
        # Register the good participant
        RuoteKit.engine.register_participant :service2, Service2Participant
        @item.cancel_workflow
        RuoteKit.engine.wait_for(@item.wfid)
        @item.reload
        @item.state.should eql("cancelled")
        
      end

    end # with errors

  end # workflow


end
