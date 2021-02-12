require 'spec_helper'
require 'sym/errors'
module Sym
  module Extensions
    RSpec.describe Sym::Extensions::InstanceMethods do
      subject { instance }

      include_context 'encryption'

      let(:extra_debug) { false }

      describe '#encr and #decr methods' do
        it { is_expected.to respond_to(:encr) }
        it { is_expected.to respond_to(:decr) }
      end

      context 'encrypting and decrypting a short strings' do
        let(:key) { instance.class.create_private_key }
        let(:data) { 'My girlfriend brings all the boys to the yard' }

        it 'is able to decrypt encrypted message' do
          data_encrypted = instance.encr(data, key)
          expect(instance.decr(data_encrypted, key)).to eql(data)
          expect(data_encrypted.length).to be > data.length
          puts ">> [short strings] Encrypted: #{data_encrypted.length}, Original: #{data.length}" if extra_debug
        end
      end

      context 'encrypting and decrypting a large file' do
        let(:key) { instance.class.create_private_key }
        let(:file) { 'spec/fixtures/hamlet.txt' }
        let(:password) { 'Very secure password here' }
        let(:data) { File.read(file) }

        it 'is able to encrypt and decrypt with the password' do
          data_encrypted = instance.encr(data, key)
          expect(instance.decr(data_encrypted, key)).to eql(data)
          expect(data_encrypted.length).to be < data.length
          puts ">> [large file ] Encrypted: #{data_encrypted.length}, Original: #{data.length}"  if extra_debug
        end
      end

      context 'password encryption' do
        let(:file) { 'spec/fixtures/hamlet.txt' }
        let(:password) { 'Very secure password here' }
        let(:data) { File.read(file) }

        it 'is able to encrypt and decrypt with the password' do
          data_encrypted = instance.encr_password(data, password)
          expect(data_encrypted).not_to be_nil
          puts ">> [password file ] Encrypted: #{data_encrypted.length}, Original: #{data.length}" if extra_debug
          data_decrypted = instance.decr_password(data_encrypted, password)
          expect(data_decrypted).to eql(data)
        end
      end

      context 'with nil or blank values' do
        subject(:i) { instance }

        let(:key) { i.class.create_private_key }

        it('#encr no data') { expect { i.encr(nil, key) }.to raise_error(::Sym::Errors::NoDataProvided) }
        it('#decr no data') { expect { i.decr(nil, key) }.to raise_error(::Sym::Errors::NoDataProvided) }

        it('#encr no key') { expect { i.encr('data',  nil) }.to raise_error(::Sym::Errors::NoPrivateKeyFound) }
        it('#decr no key') { expect { i.decr('data',  nil) }.to raise_error(::Sym::Errors::NoPrivateKeyFound) }

        it('#encr_pasword no password') { expect { i.encr_password('data',  nil) }.to raise_error(::Sym::Errors::NoPasswordProvided) }
        it('#encr_password no data') { expect { i.encr_password(nil, 'password') }.to raise_error(::Sym::Errors::NoDataProvided) }

        it('#decr_pasword no password') { expect { i.decr_password('data',  nil) }.to raise_error(::Sym::Errors::NoPasswordProvided) }
        it('#decr_password no data') { expect { i.decr_password(nil, 'password') }.to raise_error(::Sym::Errors::NoDataProvided) }
      end
    end
  end
end
