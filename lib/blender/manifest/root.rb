require 'ruby-debug'
require 'shadow_puppet'
require 'puppet/darwinport_fix'

module Blender
  module Manifest; end
  module Recipes
    module Os; end
  end
end

require 'blender/manifest/nodes'
require 'blender/manifest/roles'
require 'blender/manifest/mixer'

class Root < ::ShadowPuppet::Manifest
  include Blender::Manifest::Nodes
  include Blender::Manifest::Roles

  @@mixed_recipes = []
  def self.mixed_recipes
    @@mixed_recipes
  end

  # Currently running operating system
  #
  # @return [String] name of the OS that is running
  def os
    Facter.value(:operatingsystem)
  end

  def execute_user_recipe
    mix "os/#{os.downcase}"

    if :setup == @stage
      # run OS specific setup recipe.
      m = "#{os.downcase}_setup"
      return send(m) if respond_to?(m)
    end

    raise "no RECIPE to execute" unless recipe = ENV['RECIPE']

    # run OS specific recipe.
    m = os.downcase
    send m if respond_to?(m)

    # load user's recipe
    code = open(recipe).read
    instance_eval(code, recipe)
  end

  recipe :execute_user_recipe

  def initialize(stage = :execute)
    super()
    @stage = stage
  end

  # Create a catalog of all contained Puppet Resources and apply that
  # catalog to the currently running system
  def apply(bucket = nil)
    bucket ||= export()
    catalog = bucket.to_catalog
    res = catalog.apply
    catalog.clear
    res
  end

  # Execute this manifest, applying all resources defined. Execute returns
  # true if successfull, and false if unsucessfull. By default, this
  # will only execute a manifest that has not already been executed?.
  # The +force+ argument, if true, removes this check.
  def execute(force=false)
    return false if executed? && !force
    evaluate_recipes
    ! apply.any_failed?
  rescue Exception => e
    STDERR.puts "\n\nException: #{e}\n#{e.backtrace * "\n"}"
    false
  ensure
    @executed = true
  end


end

include Blender::Manifest::Mixer

# "project" recipe directory
$: << "recipes"

# add all recipes in the cookbooks directory to the path
$:.concat Dir["cookbooks/*/recipes"]