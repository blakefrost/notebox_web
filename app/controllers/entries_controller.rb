require_dependency 'notebox/box'

class EntriesController < ApplicationController

  # Parameters
  #
  #   days_ago - Interger value of number of days to go back.
  def index
    topic = params[:topic]
    date = Date.today - params[:days_ago].to_i.days

    @entries = notebox.fetch_entries(topic: topic, date: date)

    # Why does slice throw an exception if the key is missing?
    @options = {
      days_ago: params[:days_ago],
      topic: params[:topic]
    }.delete_if { |k, v| v.nil? }

    # Get dir listing of notes root ( This could work for following sub topics too)
    @topics = Dir.entries(NOTES_ROOT) # Get topic listing
    @topics.reject! { |t| t.match(/^\./) } # Remove hidden files
  end

  def search
    @results = notebox.search(params[:q].to_s)
  end

  def show
    path = params[:path]
    topic = params[:topic]

    root_path = topic ? "#{NOTES_ROOT}/#{topic}/entries/" : "#{NOTES_ROOT}/entries/"
    highlight = params[:highlight]
    full_path = root_path + path

    created_at = parse_created_at(path)

    markdown = File.read(full_path + '.txt')
    render_checkboxes!(markdown)
    front_matter, _markdown = markdown.match(/---((.|\n)*)---((.|\n)*)/).try(:captures)
    tags = []
    if front_matter
      front_matter = YAML.load(front_matter).symbolize_keys
      markdown = markdown.gsub(/---(.|\n)*---/, '') # Strip front matter
      tags = front_matter[:tags]
      @title = front_matter[:title]
    end

    html = $markdown.render(markdown)

    # Highlight search keywords.
    html = html.gsub(/(#{highlight})/i, '<span class="highlight">\1</span>') if highlight

    # Add lightbox data
    doc = Nokogiri::HTML(html)
    doc.css('img').each do |image|
      image.swap "<a href=\"#{image.attribute("src")}\" data-lightbox=\"example\">#{image}</a>"
    end
    html = doc.to_html

    attributes = {
      path: path,
      markdown: markdown,
      html: html,
      created_at: created_at,
      formatted_date: created_at.strftime('%A, %B %e %Y'),
      formatted_time: created_at.strftime('%I:%M %p'),
      formatted_date_time: created_at.strftime('%A, %B %e, %Y, %l:%M %p'),
      tags: tags
    }
    @entry = OpenStruct.new(attributes)
    respond_to do |format|
      format.html
      format.text { render text: markdown }
    end
  end

  def new
    @entry = OpenStruct.new({})
  end

  # Log
  def log
    # - Find the note by the path
    # - Get the log od diffs to render. (Could be a cell or facet of diffs
    # controller.

    root_path = "/Users/blake/.notes/entries/"
    path = params[:path]
    full_path = root_path + path

    created_at = parse_created_at(path)

    markdown = File.read(full_path + '.txt')
    render_checkboxes!(markdown)
    front_matter, _markdown = markdown.match(/---((.|\n)*)---((.|\n)*)/).try(:captures)
    tags = []
    if front_matter
      front_matter = YAML.load(front_matter).symbolize_keys
      markdown = markdown.gsub(/---(.|\n)*---/, '') # Strip front matter
      tags = front_matter[:tags]
      @title = front_matter[:title]
    end

    @cmd_results = `cd #{NOTES_ROOT} && git log -u --no-decorate --no-color --pretty \"entries/#{path}.txt\"`

    @log_entries = []
    current = nil
    header_flag=false # Dictates if within header
    comment_flag=false # Dictates if within commit comment

    @cmd_results.lines.each do |line|
      if comment_flag
        case line
        when /^diff (.*)$/
          comment_flag=false
        else
          current[:message] << line
        end
      elsif header_flag
        case line
        when /^Author: (.*)$/
          current[:author] = $1
        when /^Date: (.*)$/
          current[:date] = DateTime.parse($1)
          comment_flag=true
        when /^@@ (.*) @@/
          current[:range] = $1
          header_flag=false
        end
      else
        case line
        when /^commit (\w{40})$/
          current = {
            commit: $1,
            message: "",
            diff: ""
          }
          @log_entries << current
          header_flag=true
        when /^\+/
          current[:diff] << "<span class=\"line-added\">#{CGI::escapeHTML(line)}</span>"
        when /^\-/
          current[:diff] << "<span class=\"line-removed\">#{CGI::escapeHTML(line)}</span>"
        else
          current[:diff] << line
        end
      end
    end

    html = $markdown.render(markdown)

    attributes = {
      path: path,
      markdown: markdown,
      html: html,
      created_at: created_at,
      formatted_date: created_at.strftime('%A, %B %e %Y'),
      formatted_time: created_at.strftime('%I:%M %p'),
      formatted_date_time: created_at.strftime('%A, %B %e, %Y, %l:%M %p'),
      tags: tags
    }
    @entry = OpenStruct.new(attributes)
    respond_to do |format|
      format.html
      format.text { render text: markdown }
    end

  end

  def edit
    path = params[:path]
    topic = params[:topic]
    root_path = topic ? "#{NOTES_ROOT}/#{topic}/entries/" : "#{NOTES_ROOT}/entries/"

    full_path = root_path + path


    created_at = parse_created_at(path)
    markdown = File.read(full_path + '.txt')
    attributes = {
      path: path,
      markdown: markdown,
      html: $markdown.render(markdown),
      created_at: created_at,
      formatted_date: created_at.strftime('%A, %B %e %Y'),
      formatted_time: created_at.strftime('%I:%M %p'),
      formatted_date_time: created_at.strftime('%A, %B %e, %Y, %l:%M %p')
    }
    @entry = OpenStruct.new(attributes)
  end

  def update
    root_path = "/Users/blake/.notes/entries/"
    path = params[:path]
    full_path = root_path + path
    created_at = parse_created_at(path)

    markdown = params[:markdown]

    File.write(full_path + '.txt', markdown)

    redirect_to "/entries/" + path

    #root_path = "/Users/blake/.notes/entries/"
    #path = params[:path]
    #full_path = root_path + path

    #created_at = parse_created_at(path)

    #markdown = File.read(full_path + '.txt')

    #tags = front_matter[:tags]


    ## Open the file for writing, and save.

    #render text: 'hold tight'
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

  def render_checkboxes!(markdown)
    markdown.gsub!(/^(  )?\[ \](.*)/, "<input type=\"checkbox\"></input> \\2<br>")
    markdown.gsub!(/^(  )?\[(x|X)\](.*)/, "<input type=\"checkbox\" checked></input> \\3<br>")
  end

end
