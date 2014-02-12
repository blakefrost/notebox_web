class BlockedDomain
  include Mongoid::Document

  field :value, type: String
  field :blocked, type: Boolean, default: true
end
