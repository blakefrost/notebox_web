class TimersController < ApplicationController

  def index
    date = Date.today - params[:days_ago].to_i.days

    @timers = notebox.fetch_entries(topic: 'timer', date: date)

    # Why does slice throw an exception if the key is missing?
    @options = {
      days_ago: params[:days_ago],
      topic: params[:topic]
    }.delete_if { |k, v| v.nil? }

    # Get dir listing of notes root ( This could work for following sub topics too)
    @topics = Dir.entries(NOTES_ROOT) # Get topic listing
    @topics.reject! { |t| t.match(/^\./) } # Remove hidden files

  end

  def show
  end

  def edit
  end

  def update
  end

private

  def notebox
    @notebox ||= Notebox::Box.new(NOTES_ROOT)
  end

end
