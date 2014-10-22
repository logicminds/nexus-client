require "spec_helper"
require 'sqlite3'

describe "Real Integration Nexus::Analytics" do
  before(:all) do
    FileUtils.mkdir_p('/tmp/cache') if not File.exists?('/tmp/cache')
  end
  file = '/tmp/ant-4.0.pom'
  shafile = '/tmp/ant-4.0.pom.sha1'

  after(:all) do

  end

  before(:each) do
    @gav = Nexus::Gav.new("org.apache.maven:maven:3.2.1:central::pom")
    @gav.sha1 = 'e1451ce0ab53c5a7a319d55dd577b7ee97799956'

    @analytics = Nexus::Analytics.new('/tmp', 'cache-analytics.db')
  end

  # it 'should do something' do
  #   @analytics.gavs.should eq(Array)
  #   @analytics.gavs.length should gt(2)
  # end

  # it 'should return old items' do
  #   @analytics.old_items.should eq([])
  # end

  it 'should not return old items' do
    @analytics.old_items(2592000).length.should eq(0)
  end

  it 'should reuturn top_x' do
    @analytics.top_x(3).should eq([])
    @analytics.top_x(3).length.should eq(3)

  end

  it 'should update totals hash correctly' do
    @analytics.totals.should eq([])
    @analytics.update_item(@gav)
  end
end
