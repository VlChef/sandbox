require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe "ntp Daemon" do

  it "has a running service of ntp" do
    expect(service("ntp")).to be_running
  end

end

describe file('/etc/ntp.conf') do
  it { should contain 'driftfile' }
end
