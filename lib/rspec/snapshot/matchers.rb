require 'rspec/snapshot/matchers/match_snapshot'
require 'pry'

module RSpec
  module Snapshot
    module Matchers
      def match_snapshot(snapshot_name)
        MatchSnapShot.new(self.class.metadata, snapshot_name)
      end

      def match_liquid_snapshot(snapshot_name, liquid_variables)
        MatchSnapShot.new(self.class.metadata, snapshot_name, :liquid, liquid_variables.stringify_keys)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Snapshot::Matchers
  config.include RSpec::Snapshot::LoadSnapshot
end
