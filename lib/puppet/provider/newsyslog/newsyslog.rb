Puppet::Type.type(:newsyslog).provide(:newsyslog) do

  desc "Provider for newsyslog"

  commands

  confine :osfamily => "FreeBSD",
          :operatingsystemmajrelease => =~ /1[0-9]/
  defaultfor :osfamily => "FreeBSD"

  nsdir = "/usr/local/etc/newsyslog.conf.d"
  nsfile = "{nsdir}/#{resource[:name]}"
  header1 = "\#\#\# Managed by Puppet\n\#\#\#DO NOT EDIT\n"
  header2 = "\# logfilename          [owner:group]    mode count " + \
            "size when  flags [/pid_file] [sig_num]"
  line = "#{resource[:name]}\t#{resource[:owner]}:#{resource[:group]}\t" + \
         "#{resource[:mode]}\t#{resource[:count]}\t#{resource[:size]}\t" + \
         "#{resource[:when]}\t#{resource[:flags]}\t#{resource[:pidfile]}\t" + \
         "#{resource[:signal]}"

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
        l = l[1..-1]
        :owner, :group, :mode, :count, :size, :when, :flags, :pidfile,
        :signal = l
      end
    end
  end

  def exists?
    File.exist?(nsfile)
  end

  def create
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
    File.delete(nsfile)
    self.debug("Deleted #{nsfile}")

    restart_newsyslog
  end

  def owner
    owner = line.split("\t")[1]
  end

  def group
    group = line.split("\t")[2]

  def mode
    mode = line.split("\t")[3]
  end

  def count
    count = line.split("\t")[4]
  end

  def size
    size = line.split("\t")[5]
  end

  def when
    when = line.split("\t")[6]
  end

  def flags
    flags = line.split("\t")[7]
  end

  def pidfile
    pidfile = line.split("\t")[8]
  end

  def signal
    signal = line.split("\t")[9]
  end
end # Puppet::Type
