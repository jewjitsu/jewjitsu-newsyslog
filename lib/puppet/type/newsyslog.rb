Puppet::Type.newtype(:newsyslog) do

  desc "Manage newsyslog entries in /etc/newsyslog.conf.d/"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of the system log file to be archived."
  end

  newproperty(:"owner:group") do
    desc "This optional field specifies the owner and group for the archive
          file .  The \":\" is essential regardless if the owner or group field
          is left blank or contains a value.  The field may be numeric, or a
          name which is present in /etc/passwd or /etc/group."

    validate do |value|
      value = value.downcase!
      if ! value =~ /^[a-z]+:[0-9]+$/ or ! value =~ /^[0-9]+:[0-9]+$/
        fail("invalid owner:group (#{value})"
      end
    end
  end

  newproperty(:mode) do
    desc "The file mode of the log file and archives."

    validate do |value|
    if ! value.is_a?(integer) and value.length != 3
      fail("invalid file mode (#{value})")
    end
  end

  newproperty(:count) do
    desc "The maximum number of archive files which may exist.  This does not
          consider the current log file."

    fail("invalid count (#{value})") unless value.is_a?(Integer)
  end

  newproperty(:size) do
    desc "When the size of the log file reaches size in kilobytes, the log
          file will be trimmed as described above.  If this field contains
          an asterisk (\"*\"), the log file will not be trimmed based on
          size."

    fail("invalid size (#{value})") unless value.is_a?(Integer)
  end

  newproperty(:when) do
    desc "The when field may consist of an interval, a specific time, or
          both.  If the when field contains an asterisk (\"*\"), logrotation
          will solely depend on the contents of the size field.  Otherwise,
          the when field consists of an optional interval in hours, usually
          followed by an \"*\"-sign and a time in restricted ISO 8601 format.
          Additionally, the format may also be constructed with a \"$\" sign
          along with a rotation time specification of once a day, once a
          week, or once a month."
  end

  newproperty(:flags) do
    desc "This optional field is made up of one or more characters that
          specify any special processing to be done for the log files
          matched by this line.  See man page for additional information."

    fail("invalid flags (#{value})") unless value =~ /BCDGJNUXZ-/
  end

  newproperty(:pidfile) do
    desc "This optional field specifies the file name containing a daemon's
          process ID or to find a group process ID if the U flag was specified
          If this field is present, a signal is sent to the process ID
          contained in this file.  If this field is not present and the N flag
          has not been specified, then a SIGHUP signal will be sent to
          syslogd(8) or to the process id found in the file specified by
          newsyslog(8)'s -S switch.  This field must start with \"/\" in
          order to be recognized properly.  When used with the R flag, the
          file is treated as a path to a binary to be executed by the
          newsyslog(8) after rotation instead of sending the signal out."
  end

  newproperty(:signal) do
    desc "This optional field specifies the signal that will be sent to the
          daemon process (or to all processes in a process group, if the U
          flag was specified).  If this field is not present, then a SIGHUP
          signal will be sent.  Signal names must start with \"SIG\" and be
          the signal name, e.g., SIGUSR1.  Alternatively, signal can be the
          signal number, e.g., 30 for SIGUSR1."
  end
end
