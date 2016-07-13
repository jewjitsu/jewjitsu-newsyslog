Puppet::Type.type(:newsyslog).provide(:newsyslog) do

  desc "Provider for newsyslog"

  mk_resource_methods

  confine :osfamily => "FreeBSD",
          :operatingsystemmajrelease => /1[0-9]/
  defaultfor :osfamily => "FreeBSD"
  nsdir = "/usr/local/etc/newsyslog.conf.d"
  header1 = "\#\#\# Managed by Puppet\n\#\#\#DO NOT EDIT\n"
  header2 = "\# logfilename          [owner:group]    mode count " + \
            "size time  flags [/pid_file] [sig_num]"

  def restart_newsyslog
    execute("service newsyslog restart")
    if $?.exitstatus != 0
      raise Puppet::Error("could not restart newsyslog")
    end
  end

  def self.instances
    ns = Dir.entries(nsdir)
    ns.each do |n|
      val = File.read(n)
      val.each_line do |l|
        next if l =~ /^#/
        name, owner, group, mode, count, size, time, flags, pidfile, signal = l
        new(:name => name,
            :owner => owner,
            :group => group,
            :mode => mode,
            :count => count,
            :size => size,
            :time => time,
            :flags => flags,
            :pidfile => pidfile,
            :signal => signal,
        )
      end
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource == resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    nsfile = "{nsdir}/#{@resource[:name]}"
    line = "#{@resource[:name]}\t" + \
           "#{@resource[:owner]}:#{@resource[:group]}\t" + \
           "#{@resource[:mode]}\t#{@resource[:count]}\t" + \
           "#{@resource[:size]}\t#{@resource[:time]}\t#" + \
           "{@resource[:flags]}\t#{@resource[:pidfile]}\t#{@resource[:signal]}"
    # make sure /etc/newsyslog.conf.d exists before creating any files there
    if ! Dir.exist?(nsdir)
      Dir.mkdir(nsdir)
    end

    # create the newsyslog file
    File.open(nsfile, File::WRONLY | File::CREAT, 0644) do |f|
      f << header1
      f << header2
      f << line
    end
    self.debug("Added #{nsfile}")

    restart_newsyslog
  end

  def destroy
    nsfile = "{nsdir}/#{@resource[:name]}"
    File.delete(nsfile)
    self.debug("Deleted #{nsfile}")

    restart_newsyslog
  end
end # Puppet::Type
