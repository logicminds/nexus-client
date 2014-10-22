require "spec_helper"

describe "Integration Nexus::Cache" do
  gav_str = 'org.glassfish.main.external:ant:4.0:central::pom'
  gav_str2 = 'org.apache.maven:maven:3.2.1:central::pom'
  after(:all) do

  end

  before(:each) do
     let(:gav) do
       Nexus::Gav.new(gav_str)
     end
     let(:gav2) do
       Nexus::Gav.new(gav_str2)
     end
     gav2.sha1 = '387951c0aa333024b25085d76a8ad77441b9e55f'
     gav1.sha1 = ''
  end

  context 'turn analytics on' do
    let(:cache) do
      Nexus::Cache.new('/tmp/cache', true)
    end
  end

  context 'turn analytics off' do
    let(:cache) do
      Nexus::Cache.new('/tmp/cache', false)
    end

    gav2 = Nexus::Gav.new(gav_str)
    gav2.sha1 = '387951c0aa333024b25085d76a8ad77441b9e55f'

  end

end
