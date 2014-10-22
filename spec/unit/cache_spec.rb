require "spec_helper"

describe Nexus::Cache do
  let(:cache) do
    Nexus::Cache.new
  end
  gav_str = 'org.glassfish.main.external:ant:4.0:central::pom'
  let(:gav) do
    Nexus::Gav.new(gav_str)
  end


  context '#cache_location' do
     it { expect(cache.location(gav)).to eq('/tmp/cache/org/glassfish/main/external/ant')}
     context 'custom cache base' do
       let(:cache) do
         Nexus::Cache.new('/tmp/cache')
       end
       it { expect(cache.location(gav)).to eq('/tmp/cache/org/glassfish/main/external/ant')}

     end
  end


  context '#file_path' do
     context 'should throw error when sha1 is missing' do
       let(:gav) do
         Nexus::Gav.new(gav_str)
       end
      it { expect{cache.file_path(gav)}.to raise_error(RuntimeError)}
     end
     context 'should return correctly' do
       gav2 = Nexus::Gav.new(gav_str)
       gav2.sha1 = '387951c0aa333024b25085d76a8ad77441b9e55f'

       it { expect(cache.file_path(gav2)).to eq("/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache")}
     end
  end

  context '#exists?' do
    gav2 = Nexus::Gav.new(gav_str)
    gav2.sha1 = '387951c0aa333024b25085d76a8ad77441b9e55f'
    FakeFS do
      FileUtils.mkdir_p('/tmp/cache/org/glassfish/main/external/ant/')
      File.open('/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache', 'w') do |file|
        file.write('blah')
      end
      it 'should exist' do expect(cache.exists?(gav2) == true) end
    end
  end

  context '#exists?' do
    gav2 = Nexus::Gav.new(gav_str)
    gav2.sha1 = '2aba52730281caf2ab4d44d85c9ebd20cd7bd99'
    FakeFS do
      FileUtils.mkdir_p('/tmp/cache/org/glassfish/main/external/ant/')
      File.open('/tmp/cache/org/glassfish/main/external/ant/387951c0aa333024b25085d76a8ad77441b9e55f.cache', 'w') do |file|
        file.write('blah')
      end
      it 'should not exist' do expect(cache.exists?(gav2) == false) end
    end
  end

  # context 'disable analytics' do
  #   let(:cache) do
  #     Nexus::Cache.new('/tmp/cache', false)
  #   end
  #   gav2 = Nexus::Gav.new(gav_str)
  #   gav2.sha1 = '387951c0aa333024b25085d76a8ad77441b9e55f'
  #
  #     it 'should not call analytics class' do
  #       FakeFS do
  #         FileUtils.mkdir_p('/tmp')
  #         File.open('/tmp/ant-4.0.pom', 'w') { |file| file.write('blah')}
  #         expect(cache).to receive(:analytics).exactly(0).times
  #         expect(Nexus::Analytics).to receive(:new).exactly(0).times
  #         expect(cache.analytics_enabled).to be_false
  #         expect(cache.add_file(gav2, '/tmp/ant-4.0.pom')).to be_true
  #       end
  #   end
  # end
  #
  # context 'enable analytics' do
  #   let(:cache) do
  #     Nexus::Cache.new('/tmp/cache', true)
  #   end
  #   gav2 = Nexus::Gav.new(gav_str)
  #   gav2.sha1 = '387951c0aa333024b25085d76a8ad77441b9e55f'
  #
  #
  #     it 'should call analytics class' do
  #       FakeFS do
  #         #expect(Nexus::Analytics).to receive(:new).exactly(1).times
  #         cache2 = Nexus::Cache.new('/tmp/cache', true)
  #         puts cache2.analytics.inspect
  #         FileUtils.mkdir_p('/tmp')
  #         File.open('/tmp/ant-4.0.pom', 'w') { |file| file.write('blah')}
  #         expect(cache2).to receive(:analytics).exactly(1).times
  #         expect(cache2.analytics).to be_a(Nexus::Analytics)
  #         expect(cache2.analytics_enabled).to be_true
  #         expect(cache2.add_file(gav2, '/tmp/ant-4.0.pom')).to be_true
  #       end
  #
  #   end
  # end



end

