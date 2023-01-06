# frozen_string_literal: true

require 'spec_helper'

describe String do
  let(:custom_string) { String.new('custom string') }

  describe '#colorize'  do
    it 'returns a string with the color code' do
      expect(custom_string.colorize(31)).to eq "\e[31m#{custom_string}\e[0m"
    end
  end

  describe '#red' do
    it 'calls colorize with 31' do
      expect(custom_string).to receive(:colorize).with(31)

      custom_string.red
    end
  end

  describe '#green' do
    it 'calls colorize with 32' do
      expect(custom_string).to receive(:colorize).with(32)

      custom_string.green
    end
  end

  describe '#yellow' do
    it 'calls colorize with 33' do
      expect(custom_string).to receive(:colorize).with(33)

      custom_string.yellow
    end
  end

  describe '#blue' do
    it 'calls colorize with 34' do
      expect(custom_string).to receive(:colorize).with(34)

      custom_string.blue
    end
  end

  describe '#pink' do
    it 'calls colorize with 35' do
      expect(custom_string).to receive(:colorize).with(35)

      custom_string.pink
    end
  end

  describe '#light_blue' do
    it 'calls colorize with 36' do
      expect(custom_string).to receive(:colorize).with(36)

      custom_string.light_blue
    end
  end

  describe '#bold' do
    it 'returns a string with the bold code' do
      expect(custom_string.bold).to eq "\e[1m#{custom_string}\e[22m"
    end
  end

  describe '#italic' do
    it 'returns a string with the italic code' do
      expect(custom_string.italic).to eq "\e[3m#{custom_string}\e[23m"
    end
  end
end
