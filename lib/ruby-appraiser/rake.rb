require 'ruby-appraiser'

namespace :appraise do
  def appraise_task(mode = 'all')
    task mode do
      @appraisal = RubyAppraiser::Appraisal.new(mode: mode.to_s)
      RubyAppraiser::Adapter::all.each do |adapter|
        @appraisal.add_adapter adapter.adapter_type
      end
      @appraisal.run!
      puts @appraisal
    end
  end

  {
    all: 'show all defects',
    staged: 'show staged defects',
    authored: 'show uncommitted defects',
    touched: 'show defects in all files that have been touched',
  }.each do |mode, description|
    desc description
    appraise_task mode
  end
end

task appraise: 'appraise:all'
