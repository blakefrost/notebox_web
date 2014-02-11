require_dependency 'notebox/box'

class DnsController < ApplicationController

  def index
    @running = `ps aux | grep dnsproxy | grep -v grep`.present?
  end

end
