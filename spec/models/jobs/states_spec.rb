require File.dirname(__FILE__) + '/../../spec_helper'

describe Jobs::States do
  before(:each) do
    @job = Factory(:job)
  end

  it "should set the initial state to scheduled" do
    Job.new.state.should == Job::Scheduled
    Job.new.initial_state.should == Job::Scheduled
  end
  
  describe "entering a state" do
    it "should enter the specified state with parameters" do
      @job.should_receive(:enter_void).with(:foo => 'bar')
      result = @job.enter(:void, :foo => 'bar')
      result.should == @job
    end
  end
  
  describe "entering scheduled state" do
    before(:each) do
      @host = Factory(:host)
      Host.stub!(:with_available_slots).and_return [@host]
      
      Transcoder.stub!(:schedule).and_return 'attrs'
    end
    
    def do_enter
      @job.enter(Job::Scheduled)
    end
    
    it "should try to schedule the job at the host" do
      Transcoder.should_receive(:schedule).with(:host => @host, :job => @job)
      do_enter
    end
    
    it "should enter accepted" do
      do_enter
      @job.state.should == Job::Accepted
    end
    
    it "should generate a state change" do
      do_enter
      @job.state_changes.last.state.should == Job::Accepted
    end
    
    it "should stay scheduled if the job cannot be scheduled" do
      Transcoder.stub!(:schedule).and_return false
      do_enter
      @job.state.should == Job::Scheduled
    end
  end
  
  describe "entering accepted state" do
    before(:each) do
      @t = Time.new(2011, 1, 2, 3, 4, 5)
      Time.stub!(:current).and_return @t
    end
    
    def do_enter
      @job.enter(Job::Accepted, { 'job_id' => 2 })
    end
    
    it "should set the parameters" do
      do_enter
      @job.remote_job_id.should == 2
      @job.transcoding_started_at.should == @t
      @job.state.should == Job::Accepted
    end
    
    it "should generate a state change" do
      do_enter
      @job.state_changes.last.state.should == Job::Accepted
    end
  end
  
  describe "entering processing state" do
    def do_enter
      @job.enter(Job::Processing, {'progress' => 1, 'duration' => 2, 'filesize' => 3})
    end
    
    it "should set the parameters" do
      do_enter
      @job.progress.should == 1
      @job.duration.should == 2
      @job.filesize.should == 3
    end
    
    it "should generate a state change" do
      do_enter
      @job.state_changes.last.state.should == Job::Processing
    end
  end
  
  describe "entering failed state" do
    def do_enter
      @job.enter(Job::Failed, {'message' => 'msg'})
    end
    
    it "should set the parameters" do
      do_enter
      @job.message.should == 'msg'
    end
    
    it "should generate a state change" do
      do_enter
      change = @job.state_changes.last
      change.state.should == Job::Failed
      change.message.should == 'msg'
    end
  end
  
  describe "entering success state" do
    before(:each) do
      @t = Time.new(2011, 1, 2, 3, 4, 5)
      Time.stub!(:current).and_return @t
    end
    
    def do_enter
      @job.enter(Job::Success, {'message' => 'msg'})
    end
    
    it "should set the parameters" do
      do_enter
      @job.message.should == 'msg'
      @job.completed_at.should == @t
      @job.progress.should == 1.0
    end
    
    it "should generate a state change" do
      do_enter
      change = @job.state_changes.last
      change.state.should == Job::Success
      change.message.should == 'msg'
    end
  end
end