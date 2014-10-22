require "spec_helper"
require 'sqlite3'

describe "Integration Nexus::Analytics" do
  before(:all) do
    FileUtils.mkdir_p('/tmp/cache') if not File.exists?('/tmp/cache')
  end
  file = '/tmp/ant-4.0.pom'
  shafile = '/tmp/ant-4.0.pom.sha1'

  after(:all) do
    FileUtils.rm(file) if File.exists?(file)
    FileUtils.rm_rf('/tmp/cache/analytics.db')

  end
  before(:each) do
    FileUtils.rm_rf('/tmp/cache/analytics.db') if File.exists?('/tmp/cache/analytics.db')
    @gav = Nexus::Gav.new('org.glassfish.main.external:ant:4.0:central::pom')
    @gav.sha1 = '387951c0aa333024b25085d76a8ad77441b9e55f'
    @gav.attributes[:total_time] = 0.332
    @gav.attributes[:size] = 123837
    @gav2 = Nexus::Gav.new('org.apache.maven:maven:3.2.1:central::pom')
    @gav2.sha1 = '54af5be0a5677e896e9eaa356bbb82abda06bd76'
    @gav2.attributes[:total_time] = 0.532
    @gav2.attributes[:size] = 12389
    @analytics = Nexus::Analytics.new('/tmp/cache', 'analytics.db')
  end

  it 'db exists' do
    expect(File.exists?('/tmp/cache/analytics.db')).to be_true
  end

  it 'table exists' do
   expect(@analytics.db.execute("select * from artifacts")).to eq([])
  end

  it 'gavs return' do
    @analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')
    expect(@analytics.gavs.length).to eq(1)
  end

  it 'total view exists' do
    @analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    expected = [["896f6a67964939a62f6b29e3d6fa13139ee92f9a",
                 "org.glassfish.main.external:ant:4.0:central::pom",
                 123837, 0.332, "2014-06-11 00:44:07 -0700",
                 "/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache",
                 4, 495348, 1.328]]
    expect(@analytics.db.execute("select * from totals").length).to eq(1)
  end

  it '#old_items' do
    @analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')
    expect(@analytics.old_items((Time.now + 10000).to_i).length).to eq(1)
    expect(@analytics.old_items((Time.now - 10000).to_i).length).to eq(0)

  end

  it '#remove_old_items' do
    @analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')
    expect(@analytics.old_items((Time.now + 10000).to_i).length).to eq(1)
    @analytics.remove_old_items((Time.now + 10000).to_i)
    expect(@analytics.old_items((Time.now + 10000).to_i).length).to eq(0)
  end

  it 'top works' do
    @analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    expected = [["896f6a67964939a62f6b29e3d6fa13139ee92f9a",
                 "org.glassfish.main.external:ant:4.0:central::pom",
                 123837, 0.332, "2014-06-11 00:44:07 -0700",
                 "/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache",
                 4, 495348, 1.328]]
    expect(@analytics.top_x(3).length).to eq(1)
  end

  it 'can add item' do
    @analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')
    @analytics.add_item(@gav2, '/tmp/cache/org/apache/maven/54af5be0a5677e896e9eaa356bbb82abda06bd76.cache')
    expect(@analytics.db.execute("select * from artifacts")).to be_a Array
  end

  it 'should not error out when duplicate item is added' do
    expect{@analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')}.to_not raise_error
    expect{@analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')}.to_not raise_error

  end

  it 'can update item' do
    expect{@analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')}.to_not raise_error
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    expect(@analytics.hit_count(@gav)).to eq(2)

  end

  it '#totals_bytes with pretty' do
    expect{@analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')}.to_not raise_error
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    expect(@analytics.total_bytes(@gav, true)).to eq('241.87 kiB')
  end

  it '#totals_bytes without pretty' do
    expect{@analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')}.to_not raise_error
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    expect(@analytics.total_bytes(@gav)).to eq(247674)
  end

  it '#totals_time' do
    expect{@analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')}.to_not raise_error
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    expect(@analytics.total_time(@gav)).to eq(0.664)
  end

  it '#to_json' do
    @analytics.add_item(@gav, '/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache')
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    @analytics.update_item(@gav)
    data = JSON.parse(@analytics.to_json)

    expect(data).to be_a(Array)
  end

end