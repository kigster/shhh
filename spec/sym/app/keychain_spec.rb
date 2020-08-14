require 'spec_helper'
require 'singleton'
require 'sym/app/keychain'
module Sym
  module App
    RSpec.describe 'Sym::App::KeyChain' do
      let(:opts) { { verbose: false } }
      let(:key_name) { 'your-mama-is-so' }
      let(:keychain) { Sym::App::KeyChain.new(key_name, opts) }
      let(:commands) { %w(add find delete) }
      let(:password) { 'Sup4r!Secur3' }

      BASE_VARS = {
        user:        ENV['USER'],
        kind:        'sym',
        sub_section: 'generic-password'
      }

      context 'class variables' do
        BASE_VARS.each_pair do |variable, value|
          it "variable #{variable} should be set to value #{value}" do
            expect(KeyChain.send(variable)).to eql(value)
          end
          it "variable #{variable} should not be nil" do
            expect(KeyChain.send(variable)).to_not be_nil
          end
        end
      end

      context '#execute' do
        it 'should run a command successfully' do
          expect(keychain.execute('echo hello')).to eql('hello')
        end
      end

      if Sym::App.osx? && ENV['SKIP_KEYCHAIN'].nil?
        context 'integration tests' do
          before do
            keychain.stderr_off
            keychain.delete rescue nil
            sleep 0.1
            keychain.add(password)
          end

          after do
            keychain.stderr_on
          end

          it 'should add a new key' do
            sleep 0.1
            expect(keychain.find).to eql(password)
          end
        end
      end
    end
  end
end

