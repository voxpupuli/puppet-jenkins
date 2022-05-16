# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker

def apply(pp, options = {})
  options[:debug] = true if ENV.key?('PUPPET_DEBUG')

  apply_manifest(pp, options)
end
