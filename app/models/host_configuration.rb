class HostConfiguration
  include Mongoid::Document
  field :value, type: String


  def self.singleton
    HostConfiguration.last || HostConfiguration.create!
  end
end
