module Blender::Manifest::Mixer
  # installs cookbook gems if needed and loads them into the environment
  def cookbook(cb, version)
    # skip cookbooks that are unapcked into the /cookbooks/ directory
    return if File.directory?("cookbooks/#{cb}/files") || File.directory?("cookbooks/#{cb}/lib")

    gem cb, version
  rescue Gem::LoadError
    system "gem install --no-ri --no-rdoc #{cb} -v#{version}"
    gem cb, version
  end

  # mixes recipe module
  #
  # The purpose is to make the mixing of recipes cleaner and easier on the eyes :)
  # i.e. instead of
  #     require 'foo'
  #     include Blender::Recipes::Foo
  #     require 'bar'
  #     include Blender::Recipes::Bar
  # you can just
  #     mix :foo, :bar
  # @param [[String, Symbol, Module]] recipes to mix
  def mix(*recipes)

    recipes.each do |recipe|

      next if Root.mixed_recipes.include?(recipe)
      Root.mixed_recipes << recipe

      case recipe
      when String, Symbol
        require recipe.to_s
        mixin = "Blender::Recipes::#{recipe.to_s.camelize}".constantize
      when Module
        mixin = recipe
      else
        raise "Expecting String, Symbol or Module. don't know what do do with #{recipe.inspect}"
      end

      puts "MIX: #{mixin}"
      ::Root.send :include, mixin
    end
  end

end
