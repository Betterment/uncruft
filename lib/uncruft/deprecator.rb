module Uncruft
  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new(Uncruft::VERSION, "Uncruft")
  end
end
