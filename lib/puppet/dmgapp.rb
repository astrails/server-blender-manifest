require 'puppet/provider/package'

Puppet::Type.type(:package).provide :dmgapp, :parent => Puppet::Provider::Package do
    desc "Install Apps on Mac OSX distributed using simple .dmg files with name.app inside"
  
    confine :exists => "/Applications"
    confine :operatingsystem => "Darwin"
    commands :hdiutil => "/usr/bin/hdiutil"

    def self.instance_properties
      Dir["/Applications/*.app"].map do |app_path|
        name = File.basename(app_path)[/(.*)\.app/, 1]
        {
          :name => name,
          :provider => :dmgapp,
          :ensure => :installed
        }
      end
    end

    def self.instances
      instance_properties.map {|h| new(h)}
    end

    def query
      self.class.instance_properties.find { |h| h[:name] == name }
    end

    def install
        source = nil
        unless source = @resource[:source]
            self.fail ":source required"
        end
        unless name = @resource[:name]
            self.fail "missing resource name"
        end

        unless source =~ /\.dmg$/i
            self.fail ":source must be a .dmg"
        end
        
        plist = hdiutil "mount", "-plist", "-nobrowse", "-readonly", "-noidme", "-mountrandom", "/tmp", source
        mount_dir = plist[/<string>(.*\/tmp\/.*)<\/string>/, 1]

        app_file_name = "#{name}.app"

        begin
          if File.exists?(app_file_path = File.join(mount_dir, app_file_name))
            FileUtils.cp_r app_file_path, "/Applications/"
          else
            self.fail "#{app_file_name} not found: #{Dir["#{mount_dir}/*"] * " "}"
          end
        ensure
          hdiutil "eject", mount_dir
        end
    end
end



