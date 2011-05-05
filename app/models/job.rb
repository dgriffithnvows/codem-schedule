class Job < ActiveRecord::Base
  include States::Base
  
  Scheduled   = 'scheduled'
  Accepted    = 'accepted'
  Processing  = 'processing'
  Success     = 'success'
  Failed      = 'failed'
  
  belongs_to :preset
  belongs_to :host
  
  has_many :state_changes, :dependent => :destroy

  default_scope :order => ["created_at DESC"]
  scope :scheduled,   :conditions => { :state => Scheduled }
  scope :accepted,    :conditions => { :state => Accepted }
  scope :success,     :conditions => { :state => Success }
  scope :failed,      :conditions => { :state => Failed }

  scope :unfinished, lambda { where("state in (?)", [Scheduled, Accepted, Processing]).order("id ASC") }
  
  validates :source_file, :destination_file, :preset_id, :presence => true
  
  def self.from_api(options)
    new(:source_file => options['input'],
        :destination_file => options['output'],
        :preset => Preset.find_by_name(options['preset']))
  end
  
  def update_status
    if state == Scheduled
      enter(Job::Scheduled)
    else
      if attrs = Transcoder.job_status(self)
        enter(attrs['status'], attrs)
      end
    end
    self
  end
  
  def unfinished?
    state == Scheduled || state == Accepted || state == Processing
  end
end
