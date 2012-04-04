at_exit do
  unless $vagrant.nil?
    # We need to turn off sandboxing or destroying the box is fuxord somehow
    invoke_sandbox_command($vagrant.cwd, 'off')
    $vagrant.cli('destroy', '-f')
  end
end

def run_command(command, options={})
  run_vagrant_command(:execute, command, options)
end

def run_sudo_command(command, options={})
  run_vagrant_command(:sudo, command, options)
end

def run_vagrant_command(method, command, options)
  if $vagrant.nil?
    raise StandardError, 'Vagrant does not appear to be running'
  end

  $vagrant.primary_vm.state.should be :running

  code = $vagrant.primary_vm.channel.send(method, command) do |type, data|
   if !(options[:silent]) && ([:stdout, :stdout].include? type)
     puts data
   end
  end

  if options[:no_verify]
    code.should == 0
  end
  code
end

def invoke_sandbox_command(path, command)
  pwd = Dir.pwd
  begin
    Dir.chdir(path)
    $vagrant.cli('sandbox', command)
  ensure
    Dir.chdir(pwd)
  end
end
