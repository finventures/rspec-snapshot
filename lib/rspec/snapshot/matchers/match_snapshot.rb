require 'fileutils'
require 'liquid'

module RSpec
  module Snapshot
    module Matchers
      # Implements the custom rspec matcher. Usage:
      # ```
      # expect(value).to match_snapshot('name_of_snapshot')
      # ```
      #
      # Rules for updating snapshots (mostly borrowed from Jest)
      #
      # These are the conditions on when to *write* snapshots:
      #   * The save_snapshots option is set to 'all'
      #   * No snapshot and the save_snapshots option is 'new' (the default)
      #
      # These are the conditions on when *not to write* snapshots:
      #   * The save_snapshots option is set to 'none'.
      #   * There is a snapshot and the save_snapshots options is 'new'
      class MatchSnapShot
        include Snapshot::LoadSnapshot
        def initialize(metadata, snapshot_name, matcher_flavor = nil, additional_variables = nil)
          @metadata = metadata
          @snapshot_name = snapshot_name
          @matcher_flavor = matcher_flavor || :standard
          @additional_variables = additional_variables || {}
        end

        def matches?(actual)
          @actual = actual
          if File.exist?(snap_path)
            @found = true
            # load_snapshot attempts to deserialize the way that write_snapshot serializes
            @expect = load_snapshot(snap_path, @matcher_flavor, @additional_variables)
            pass = compare
            if save_config == :all && !pass
              write_snapshot(snap_path, @actual)
            else
              pass
            end
          else
            @found = false
            if %i[all new].include?(save_config)
              write_snapshot(snap_path, @actual)
            else
              false
            end
          end
        end

        # TODO: more helpful snapshot diff in the failure message
        def failure_message
          if @found
            "\nexpected: #{@expect}\n     got: #{@actual}\n"
          else
            "\nCould not find a snapshot at #{snap_path}.\n Failing " \
              "instead of creating; save_snapshots is set to #{save_config}."
          end
        end

        private def write_snapshot(snap_path, serialized_value)
          Snapshot::Utils.write_snapshot(snap_path, serialized_value)
          # Write a .liquid_snapshot file as well that contains the template if we are using match_liquid_snapshot
          if @matcher_flavor == :liquid
            Snapshot::Utils.write_snapshot(snap_path.gsub('.snapshot', '.liquid_snapshot'), serialized_value)
          end
          true
        end

        private def save_config
          RSpec.configuration.save_snapshots
        end

        private def snap_path
          Snapshot::Utils.snapshot_path(@snapshot_name)
        end

        # Todo: pass serializer
        private def compare
          Snapshot::Utils.compare(@expect, @actual)
        end
      end
    end
  end
end
