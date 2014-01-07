
class TimersController < ApplicationController

  skip_before_filter :verify_authenticity_token

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
    start_time      = params[:start_time]
    running         = params[:running]
    elasped_seconds = params[:elasped_seconds]
    path            = params[:path]

    root_path = "#{NOTES_ROOT}/timer/"
    full_path = root_path + path
    created_at = parse_created_at(path)

    content = File.read(full_path + '.txt')
    attributes, markdown = extract_attributes(content)
    attributes ||= {}

    # Update relevent attributes
    attributes[:start_time]      = params[:start_time]      if params[:start_time]
    attributes[:running]         = params[:running]         unless params[:running].nil?
    attributes[:elasped_seconds] = params[:elasped_seconds] if params[:elasped_seconds]

    content = embed_attributes(attributes, markdown)
    File.write(full_path + '.txt', content) # Save

    head 200
  end

private

  def notebox
    @notebox ||= Notebox::Box.new(NOTES_ROOT)
  end

  def parse_created_at(path)
    # Parse created at
    #2013/23/23/23:23:23.txt'
    date, time = path.match(/(\d{2,4}\/\d{1,2}\/\d{1,2})\/(\d{1,2}\:\d{1,2}\:\d{1,2})/).try(:captures)
    Time.parse("#{date} #{time}") # Might need some conrrection for timezone.
  end

  def extract_attributes(content)
    lines = content.lines

    # Only read from matter if --- is first line in the file.
    return [nil, content] unless lines.shift.try(:chomp) == '---'

    attribute_lines = []

    while (line = lines.shift) && line.try(:chomp) != '---'
      attribute_lines << line
    end
    attributes = YAML.load(attribute_lines.join("\n"))
    attributes.symbolize_keys!
    body = lines.join
    [attributes, body]
  end

  def embed_attributes(attributes, body)
    if attributes && attributes.keys.any?
      attributes.stringify_keys!
      serialized_attributes = attributes.to_yaml
      [serialized_attributes, "---\n", body].join
    else
      body
    end
  end

end
