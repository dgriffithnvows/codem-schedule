module Codem
  module Jobs
    class OnHoldJob < Codem::Jobs::Base
      def perform
        job.host.update_status
        
        if job.host.available
          job.enter(:queued)
        else
          reschedule :run_at => 5.seconds.from_now
        end
      end
    end
  end
end