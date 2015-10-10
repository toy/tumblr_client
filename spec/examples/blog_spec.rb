require 'spec_helper'

describe Tumblr::Blog do

  let(:blog_name) { 'seejohnrun.tumblr.com' }
  let(:consumer_key) { 'ckey' }
  let(:client) do
    Tumblr::Client.new :consumer_key => consumer_key
  end

  describe :blog_info do

    it 'should make the proper request' do
      expect(client).to receive(:get).once.with("v2/blog/#{blog_name}/info", {
        :api_key => consumer_key
      }).and_return 'response'
      r = client.blog_info blog_name
      expect(r).to eq('response')
    end

    it 'should make the proper request with a short blog name' do
      expect(client).to receive(:get).once.with("v2/blog/b.tumblr.com/info", {
        :api_key => consumer_key
      }).and_return 'response'
      r = client.blog_info 'b'
      expect(r).to eq('response')
    end

  end

  describe :avatar do

    context 'when supplying a size' do

      before do
        expect(client).to receive(:get_redirect_url).once.with("v2/blog/#{blog_name}/avatar/128").
        and_return('url')
      end

      it 'should construct the request properly' do
        r = client.avatar blog_name, 128
        expect(r).to eq('url')
      end

    end

    context 'when no size is specified' do

      before do
        expect(client).to receive(:get_redirect_url).once.with("v2/blog/#{blog_name}/avatar").
        and_return('url')
      end

      it 'should construct the request properly' do
        r = client.avatar blog_name
        expect(r).to eq('url')
      end

    end

  end

  describe :followers do

    context 'with invalid parameters' do

      it 'should raise an error' do
        expect(lambda {
          client.followers blog_name, :not => 'an option'
        }).to raise_error ArgumentError
      end

    end

    context 'with valid parameters' do

      before do
        expect(client).to receive(:get).once.with("v2/blog/#{blog_name}/followers", {
          :limit => 1
        }).and_return('response')
      end

      it 'should construct the request properly' do
        r = client.followers blog_name, :limit => 1
        expect(r).to eq'response'
      end

    end

  end

  describe :blog_likes do

    context 'with invalid parameters' do

      it 'should raise an error' do
        expect(lambda {
          client.blog_likes blog_name, :not => 'an option'
        }).to raise_error ArgumentError
      end

    end

    context 'with valid parameters' do

      before do
        expect(client).to receive(:get).once.with("v2/blog/#{blog_name}/likes", {
          :limit => 1,
          :api_key => consumer_key
        }).and_return('response')
      end

      it 'should construct the request properly' do
        r = client.blog_likes blog_name, :limit => 1
        expect(r).to eq('response')
      end

    end

  end

  describe :posts do

    context 'without a type supplied' do

      before do
        expect(client).to receive(:get).once.with("v2/blog/#{blog_name}/posts", {
          :limit => 1,
          :api_key => consumer_key
        }).and_return('response')
      end

      it 'should construct the request properly' do
        r = client.posts blog_name, :limit => 1
        expect(r).to eq('response')
      end

    end

    context 'when supplying a type' do

      before do
        expect(client).to receive(:get).once.with("v2/blog/#{blog_name}/posts/audio", {
          :limit => 1,
          :api_key => consumer_key,
          :type => 'audio'
        }).and_return('response')
      end

      it 'should construct the request properly' do
        r = client.posts blog_name, :limit => 1, :type => 'audio'
        expect(r).to eq('response')
      end

    end

  end

  # These are all just lists of posts with pagination
  [:queue, :draft, :submissions].each do |type|

    ext = type == :submissions ? 'submission' : type.to_s # annoying

    describe type do

      context 'when using wrong parameter' do

        it 'should raise an error' do
          expect(lambda {
            client.send type, blog_name, :not => 'an option'
          }).to raise_error ArgumentError
        end

      end

      context 'with valid options' do

        it 'should construct the call properly' do
          filter = 'text'
          expect(client).to receive(:get).once.with("v2/blog/#{blog_name}/posts/#{ext}", {
            :filter => filter
          }).and_return('response')
          r = client.send type, blog_name, :filter => filter
          expect(r).to eq('response')
        end

      end

    end

  end

end
