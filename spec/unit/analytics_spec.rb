require "spec_helper"
require 'etc'
describe Nexus::Analytics do
  include FakeFS::SpecHelpers::All

  # puts Etc.getpwuid.dir
  # @cache_data = File.open('fixtures/cache_analytics.json') { |file| file.read }
  #
  # before(:each) do
  #   pwuid = double('pwuid')
  #   allow(pwuid).to receive(:dir).and_return(Dir.new('/home/user1').path)
  #   allow(Etc).to receive(:getpwuid).and_return(pwuid)
  #
  #
  # end
  #
  # before(:all) do
  #
  # end
  #
  # context '#self_hit_count' do
  #   FakeFS.activate!
  #
  #   FileUtils.mkdir_p('/home/user1')
  #   File.open('/home/user1/.cache_analytics.json') { |file| file.write(@cache_data)}
  #   it 'returns 1' do
  #     expect(Nexus::Analytics.hit_count('365576f4c2876138765f40bf159304478d22d363') ).to == 1
  #   end
  #   FakeFS.deactivate!
  #
  # end
  # it '#to_json' do
  #   FakeFS.activate!
  #   totals = [["896f6a67964939a62f6b29e3d6fa13139ee92f9a",
  #              "org.glassfish.main.external:ant:4.0:central::pom",
  #              123837, 0.332, "2014-06-11 00:44:07 -0700",
  #              "/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache",
  #              4, 495348, 1.328]]
  #
  #   FileUtils.mkdir_p('/tmp/cache') if not File.exists?('/tmp/cache')
  #   db = double(SQLite3::Database)
  #   analytics = Nexus::Analytics.new('/tmp/cache', 'analytics.db')
  #   allow(SQLite3::Database).to receive(:new).and_return(db)
  #   allow(db).to receive(:execute).and_return(totals)
  #   allow(analytics).to receive(:db).and_return(db)
  #   expect(analytics.to_json).to eq('')
  #   FakeFS.deactivate!
  #
  # end

end