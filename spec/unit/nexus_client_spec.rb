require "spec_helper"

describe Nexus::Client do
  gav_str = 'org.glassfish.main.external:ant:4.0:central::pom'
  include FakeFS::SpecHelpers::All

  let(:gav) do
    Gav.new(gav_str)
  end
  before(:each) do
    pwuid = double('pwuid')
    allow(pwuid).to receive(:dir).and_return(Dir.new('/home/user1').path)
    allow(Etc).to receive(:getpwuid).and_return(pwuid)
  end
  before(:all) do
    FileUtils.mkdir_p('/home/user1')
    File.open('/home/user1/.nexus_host', 'w') { |file| file.write('http://mynexus.example.com:8080')   }
  end
  context 'with defaults' do
    subject(:client) { Nexus::Client.new('http://nexus.example.com:8080') }

    it 'uses default host' do
      expect(client.host).to eq('http://nexus.example.com:8080')
    end

    context 'reads the nexus host file' do
      subject(:client) { Nexus::Client.new }
      it {expect(client.read_host).to eq('http://mynexus.example.com:8080')}
    end
  end

  context 'user accidently supplies extra /nexus' do
    subject(:client) { Nexus::Client.new('http://mynexus.example.com:8080/nexus') }
    it { expect(client.host).to eq('http://mynexus.example.com:8080')}
  end

  context 'sha1 works' do
    subject(:client) { Nexus::Client.new }
    it {expect(client.sha('/home/user1/.nexus_host')).to eq('87a331f91896d3363e699b828d1cccd37dd07740') }
  end

  context 'sha_match? works' do
    subject(:client) { Nexus::Client.new }
    mygav = Nexus::Gav.new(gav_str)
    mygav.sha1 = '87a331f91896d3363e699b828d1cccd37dd07740'
    it {expect(client.sha_match?('/home/user1/.nexus_host', mygav)).to be_true }
  end

  context '#create_directory' do
    subject(:client) { Nexus::Client.new }
    it { expect(client.create_target('/home/user2/apps/app1/target/archives')).to be_true  }
  end

end
