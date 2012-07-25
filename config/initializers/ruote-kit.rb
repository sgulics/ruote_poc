# make changes when needed
#
# you may use another persistent storage for example or include a worker so that
# you don't have to run it in a separate instance
#
# See http://ruote.rubyforge.org/configuration.html for configuration options of
# ruote.

require 'ruote/storage/fs_storage'

# RUOTE_STORAGE = Ruote::FsStorage.new("ruote_work_#{Rails.env}")
# RUOTE_STORAGE = Ruote::Redis::Storage.new(::Redis.new(:host => '127.0.0.1', :thread_safe => true), :engine_id=>"compass_engine")
# RUOTE_STORAGE = Ruote::Redis::Storage.new(:host => '127.0.0.1', :thread_safe => true, :engine_id=>"compass_engine")
if Rails.env.test? 
  RUOTE_STORAGE = Ruote::HashStorage.new
elsif Rails.env.development?
  RUOTE_STORAGE = Ruote::FsStorage.new('ruote_data')
else
  RUOTE_STORAGE = Ruote::Redis::Storage.new('host' => '127.0.0.1',
      'db' => 12,
      'thread_safe' => true,
      'engine_id' => 'wf_demo')
end
# RuoteKit.engine = Ruote::Engine.new(Ruote::Worker.new(RUOTE_STORAGE))
RuoteKit.engine = Ruote::Engine.new(RUOTE_STORAGE)
# By default, there is a running worker when you start the Rails server. That is
# convenient in development, but may be (or not) a problem in deployment.
#
# Please keep in mind that there should always be a running worker or schedules
# may get triggered to late. Some deployments (like Passenger) won't guarantee
# the Rails server process is running all the time, so that there's no always-on
# worker. Also beware that the Ruote::HashStorage only supports one worker.
#
# If you don't want to start a worker thread within your Rails server process,
# replace the line before this comment with the following:
#
# RuoteKit.engine = Ruote::Engine.new(RUOTE_STORAGE)
#
# To run a worker in its own process, there's a rake task available:
#
#     rake ruote:run_worker
#
# Stop the task by pressing Ctrl+C

unless $RAKE_TASK # don't register participants in rake tasks
  RuoteKit.engine.register do
    # register your own participants using the participant method
    # Example: participant 'alice', Ruote::StorageParticipant see
    # http://ruote.rubyforge.org/participants.html for more info

    participant :request_item_transition, RequestItemStateTransitionParticipant
    participant :service1, Service1Participant
    participant :service2, Service2Participant
    participant :request_item_monitor, RequestItemMonitorParticipant
    participant :post_processor, PostProcessorParticipant
    participant :request_item_admin, Ruote::StorageParticipant
    participant :request_item_error_logger, RequestItemErrorLoggerParticipant
    # register the catchall storage participant named '.+'
    catchall
  end
end

# RuoteKit.engine.on_error = Ruote.define do
#   participant :error_notifier, :msg => 'Oops!'
# end

# when true, the engine will be very noisy (stdout)
#
RuoteKit.engine.context.logger.noisy = false

