require_dependency 'notebox/box'

class DnsController < ApplicationController

  def index
    @running = `ps aux | grep dnsproxy | grep -v grep`.present?
    @host_configuration = HostConfiguration.singleton
    @blocked_list = BlockedDomain.all.order_by(:value.asc)
  end

  def control
    case params[:state]
    when 'start'
      start_dnsproxy(params[:password])
    when 'restart'
      restart_dnsproxy(params[:password])
    when 'stop'
      stop_dnsproxy(params[:password])
    end
    redirect_to action: :index
  end

  def hosts
    @host_configuration = HostConfiguration.singleton
    @blocked_list = BlockedDomain.all.order_by(:value.asc)
    @text = @host_configuration.value
    @text << "\n\n# Blocked Domains\n" << @blocked_list.select(&:blocked).map { |bd| "127.0.0.1 *.#{bd.value}" }.join("\n")

    render text: @text, content_type: :text
  end

private

  def start_dnsproxy(password)
    `  bash -c "echo -n \"#{password}\" | sudo -S dnsproxy.py -s 8.8.8.8 </dev/null &>/dev/null &"`
  end

  def stop_dnsproxy(password)

    `  bash -c "echo -n \"#{password}\" | sudo -S pkill -f dnsproxy"` # Needs to be able to run as sudo, how to?
  end

  def restart_dnsproxy(password)
    stop_dnsproxy(password)
    start_dnsproxy(password)
  end

end
