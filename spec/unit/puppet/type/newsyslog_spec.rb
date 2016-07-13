require "spec_helper"

describe Puppet::Type.type(:newsyslog) do
  describe "when validating attributes" do
    it "should have a :name param" do
      expect(described_class.attrtype(:name)).to eq(:param)
    end
    [:owner, :group, :mode, :count, :size, :time, :flags, :pidfile,
    :signal].each do |prop|
      it "should have a #{prop} property" do
        expect(described_class.attrtype(prop)).to eq(:property)
      end
    end
  end

  describe "namevar validation" do
    it "should have :name as its namevar" do
      expect(described_class.key_attributes).to eq([:name])
    end
  end

  describe "when validating attribute values" do
    describe "ensure" do
      [:present, :absent].each do |value|
        it "should support #{value} as a value to ensure" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :ensure => value,
          })}.to_not raise_error
        end
      end

      it "should not support other values" do
        expect { described_class.new({
          :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
          :ensure => "foo",
        })}.to raise_error(Puppet::Error, /Invalid value/)
      end
    end

    describe "owner" do
      describe "only alphanumeric characters should be allowed for owners" do
        it "should allow the username \"root\"" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :owner  => "root",
          })}.to_not raise_error
        end

        it "should allow the username \"foo2\"" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :owner  => "foo2",
          })}.to_not raise_error
        end

        it "should allow the username \"foo_bar\"" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :owner  => "foo_bar",
          })}.to_not raise_error
        end

        it "should not allow the username \"foo!\"" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :owner  => "foo!",
          })}.to raise_error(Puppet::Error, /invalid owner/)
        end
      end
    end

    describe "group" do
      describe "only alphanumeric characters should be allowed for groups" do
        it "should allow the group \"wheel\"" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :group  => "wheel",
          })}.to_not raise_error
        end

        it "should allow the group \"baz2\"" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :group  => "baz2",
          })}.to_not raise_error
        end

        it "should allow the group \"foo_bar\"" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :group  => "foo_bar",
          })}.to_not raise_error
        end

        it "should not allow the group \"bar!\"" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :group  => "bar!",
          })}.to raise_error(Puppet::Error, /invalid group/)
        end
      end
    end

    describe "mode" do
      describe "must be a string" do
        it "should allow \"644\"" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :mode   => "644",
          })}.to_not raise_error
        end

        it "should not allow an integer (644)" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :mode   => 644,
          })}.to raise_error(Puppet::Error, /invalid file mode/)
        end
      end

      describe "must have three characters (digits)" do
        it "should allow \"644\"" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :mode   => "644",
          })}.to_not raise_error
        end

        it "should not allow \"0644\"" do
          expect { described_class.new({
            :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
            :mode   => "0644",
          })}.to raise_error(Puppet::Error, /invalid file mode/)
        end
      end
    end

    describe "count" do
      describe "must be an integer" do
        it "show allow 5" do
          expect { described_class.new({
            :name  => "/usr/local/etc/newsyslog.conf.d/logfile",
            :count => 5,
          })}.to_not raise_error
        end

        it "show not allow \"5\"" do
          expect { described_class.new({
            :name  => "/usr/local/etc/newsyslog.conf.d/logfile",
            :count => "5",
          })}.to raise_error(Puppet::Error, /invalid count/)
        end
      end
    end

    describe "size" do
      describe "must be an integer" do
        it "show allow 1024" do
          expect { described_class.new({
            :name => "/usr/local/etc/newsyslog.conf.d/logfile",
            :size => 1024,
          })}.to_not raise_error
        end

        it "show not allow \"1024\"" do
          expect { described_class.new({
            :name => "/usr/local/etc/newsyslog.conf.d/logfile",
            :size => "1024",
          })}.to raise_error(Puppet::Error, /invalid size/)
        end
      end
    end

    describe "time" do
      it "show allow a *" do
        expect { described_class.new({
          :name => "/usr/local/etc/newsyslog.conf.d/logfile",
          :time => "*",
        })}.to_not raise_error
      end

      it "show allow a a specific time" do
        expect { described_class.new({
          :name => "/usr/local/etc/newsyslog.conf.d/logfile",
          :time => "@T00",
        })}.to_not raise_error
      end
    end

    describe "flags" do
      describe "should validate valid flags" do
        it "show allow BNJC" do
          expect { described_class.new({
            :name  => "/usr/local/etc/newsyslog.conf.d/logfile",
            :flags => "BNJC",
          })}.to_not raise_error
        end

        it "show not allow AFK" do
          expect { described_class.new({
            :name  => "/usr/local/etc/newsyslog.conf.d/logfile",
            :flags => "AFK",
          })}.to raise_error(Puppet::Error, /invalid flags/)
        end

        it "show not allow duplicate flags" do
          expect { described_class.new({
            :name  => "/usr/local/etc/newsyslog.conf.d/logfile",
            :flags => "BBNJC",
          })}.to raise_error(Puppet::Error, /duplicate flags/)
        end
      end
    end

    describe "pidfile" do
      it "should accept a value for pidfile" do
        expect { described_class.new({
          :name    => "/usr/local/etc/newsyslog.conf.d/logfile",
          :pidfile => "/var/run/proc.pid",
        })}.to_not raise_error
      end
    end

    describe "signal" do
      it "should accept a value for signal" do
        expect { described_class.new({
          :name   => "/usr/local/etc/newsyslog.conf.d/logfile",
          :signal => "SIGUSR1",
        })}.to_not raise_error
      end
    end
  end
end # describe Puppet::Type.type(:newsyslog)
