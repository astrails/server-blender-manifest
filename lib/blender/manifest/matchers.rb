module Blender
  module Manifest
    module Matchers
      extend Spec::Matchers::DSL

      RESOURCE_PARAMS = { :exec =>
        [
          :command, :creates, :cwd, :env, :environment, :group, :logoutput,
          :onlyif, :path, :refresh, :refreshonly, :returns, :timeout, :unless,
          :user, :logfile
        ], :file =>
        [
          :backup, :checksum, :content, :ensure, :force, :group, :ignore, :links,
          :mode, :owner, :path, :purge, :recurse, :recurselimit, :replace,
          :selrange, :selrole, :seltype, :seluser, :source, :sourceselect,
          :target, :type
        ], :package =>
        [
          :adminfile, :allowcdrom, :category, :configfiles, :description,
          :ensure, :instance, :platform, :responsefile, :root, :source, :status,
          :type, :vendor
        ], :service =>
        [
          :binary, :control, :enable, :ensure, :hasrestart, :hasstatus,
          :manifest, :path, :pattern, :restart, :start, :status, :stop,
        ]
      }

      RESOURCE_PARAMS.each do |resource, matcher_args|
        define "have_#{resource}".to_sym do |name|
          matcher_args.each do |arg|
            chain(arg) {|val| instance_variable_set("@#{arg}", val)}
          end

          match do |manifest|
            res = true

            @should = "manifest shold have #{resource} #{name}"
            @should_not = "manifest shold have #{resource} #{name}"

            res &&= !!(instance = manifest.send(resource.to_s.pluralize)[name])

            matcher_args.each do |attr|
              if res && (expected = instance_variable_get("@#{attr}"))
                actual = instance.send(attr)
                m = " #{attr} #{expected.inspect}"
                e = " (found #{attr} #{actual.inspect})"
                @should_not << m
                unless res &&= expected == actual
                  @should << m << e
                  @should_not << e
                end
              end

            end

            res
          end

          failure_message_for_should { |manifest| @should }
          failure_message_for_should_not { |manifest| @should_not }
        end
      end
    end
  end
end
