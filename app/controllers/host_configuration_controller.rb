require_dependency 'notebox/box'

class HostConfigurationController < ApplicationController

  # PUT /blocked_domains/1
  def update
    @host_configuration = HostConfiguration.singleton
    @host_configuration.update_attributes!(host_configuration_params)
    redirect_to :back, notice: 'Host Configuration was successfully updated.'
  end

  def host_configuration_params
    params.require(:host_configuration).permit(:value)
  end

end
