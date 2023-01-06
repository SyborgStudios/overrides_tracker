# frozen_string_literal: true

require 'spec_helper'
require 'overrides_tracker/hash_decorator'

describe Hash do
  describe '#deep_merge' do
    let(:hash) { { a: 1, b: { c: 2 } } }
    let(:other_hash) { { a: 3, b: { d: 4 } } }

    it 'returns a new hash with the contents of both hashes merged' do
      expect(hash.deep_merge(other_hash)).to eq(a: 3, b: { c: 2, d: 4 })
    end

    it 'does not modify the original hash' do
      expect { hash.deep_merge(other_hash) }.not_to change { hash }
    end
  end

  describe '#deep_merge!' do
    let(:hash) { { a: 1, b: { c: 2 } } }
    let(:other_hash) { { a: 3, b: { d: 4 } } }

    it 'modifies the original hash with the contents of the other hash merged' do
      expect { hash.deep_merge!(other_hash) }.to change { hash }.to(a: 3, b: { c: 2, d: 4 })
    end
  end

  describe '#deep_stringify_keys!' do
    it 'converts all keys in a hash to strings' do
      hash = { a: 1, b: { c: 2, d: 3 } }
      hash.deep_stringify_keys!
      expect(hash).to eq({ 'a' => 1, 'b' => { 'c' => 2, 'd' => 3 } })
    end

    it 'converts all keys in an array of hashes to strings' do
      array = { a: [{ a: 1, b: 2 }, { c: 3, d: 4 }] }
      array.deep_stringify_keys!
      expect(array).to eq({ 'a' => [{ 'a' => 1, 'b' => 2 }, { 'c' => 3, 'd' => 4 }] })
    end
  end
end
