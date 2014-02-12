require_dependency 'notebox/box'

class BlockedDomainsController < ApplicationController

  # POST /blocked_domains
  def create
    @blocked_domain = BlockedDomain.create!(blocked_domain_params)
    redirect_to :back, notice: 'Blocked Domain was successfully created.'
  end

  # PUT /blocked_domains/1
  def update
    @blocked_domain = BlockedDomain.find(params[:id])
    @blocked_domain.update_attributes!(blocked_domain_params)
    redirect_to :back, notice: 'Blocked Domain was successfully updated.'
  end

  # DELETE /blocked_domains/1
  def destroy
    @blocked_domain = BlockedDomain.find(params[:id])
    @blocked_domain.destroy
    redirect_to :back, notice: "Blocked Domain Deleted"
  end

  def blocked_domain_params
    params.require(:blocked_domain).permit(:value, :blocked)
  end

end
