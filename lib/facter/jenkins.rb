# jenkins.rb
#
# Creates a fact 'jenkins_plugins' containing a comma-delimited string of all
# jenkins plugins + versions.
#
#
Facter.add('jenkins_plugins') do
  confine :kernel => "Linux"

  setcode do
    jenkins_home = Facter::Util::Resolution.exec("echo ~jenkins")
    plugins = "#{jenkins_home}/plugins"
    jenkins_plugins = ''

    if File.directory?(plugins)
      # Get a list of all plugins + versions
      Dir.entries(plugins).select do |plugin|
        if (File.directory?("#{plugins}/#{plugin}") == true) && !(plugin == '..' || plugin == '.')
          begin
            contents = File.read("#{plugins}/#{plugin}/META-INF/MANIFEST.MF")
            contents =~ (/Plugin\-Version:\s+([\d\.\-]+)/)
            version = $1
            jenkins_plugins = "#{plugin} #{version}, " + jenkins_plugins
          rescue
            # Nothing really to do about it, failing means no version which will
            # result in a new plugin if needed
          end
        end
      end
    end

    jenkins_plugins
  end
end
