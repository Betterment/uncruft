# frozen_string_literal: true

module ::Rails
  class << self
    def root
      @root ||= Pathname.new(Dir.pwd).realpath.join('spec', 'dummy')
    end
  end
end
