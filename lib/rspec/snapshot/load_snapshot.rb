module RSpec
  module Snapshot
    # Use these helpers to load a snapshot
    # Can use the snapshot value as a mock or as part of a an expectation
    module LoadSnapshot
      def load_snapshot_named(name)
        load_snapshot(Snapshot::Utils.snapshot_path(name))
      end

      def load_snapshot(snap_path, matcher_flavor = nil, additional_variables = {})
        snap_path = snap_path.gsub('.snapshot', '.liquid_snapshot')
        content = Snapshot::Utils.deserialize(File.open(snap_path, 'r', &:read))
        if matcher_flavor == :liquid
          template = Liquid::Template.parse(content)
          content = template.render(additional_variables.stringify_keys, :strict_variables => true)
        end
        content
      end
    end
  end
end
