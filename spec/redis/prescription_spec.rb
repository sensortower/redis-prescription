# frozen_string_literal: true

require "redis/prescription"

RSpec.describe Redis::Prescription do
  let(:lua_script) { "return redis.call('GET', KEYS[1]) + ARGV[1]" }

  subject(:prescription) { described_class.new(lua_script) }

  describe ".read" do
    it "creates Prescription with given file's content" do
      expect(File).to receive(:read).
        with("calculator.lua").
        and_return(lua_script)

      described_class.read("calculator.lua")
    end
  end

  describe "#bootstrap!" do
    it "loads LUA script to redis" do
      expect(REDIS_CONNECTION).to receive(:script).
        with("LOAD", lua_script).once.
        and_call_original

      prescription.bootstrap!(REDIS)
    end

    context "when server returns unexpected script digest" do
      before { prescription.instance_variable_set(:@digest, "xxx") }

      it "warns if server returns unexpected script digest" do
        expect { prescription.bootstrap!(REDIS) }.
          to output(%r{\A\[Redis::Prescription\] Unexpected digest}).
          to_stderr
      end

      it "updates script digest" do
        allow(prescription).to receive(:warn)
        prescription.bootstrap!(REDIS)
        expect(prescription.digest).not_to eq("xxx")
      end
    end
  end

  describe "#eval" do
    it "bootstraps only when needed" do
      expect(prescription).
        to receive(:bootstrap!).once.
        and_call_original

      REDIS.set(:abc, 123)

      3.times do
        result = prescription.eval(REDIS, :keys => %i[abc], :argv => [321])
        expect(result).to eq(444)
      end
    end

    it "works when scripts were flushed" do
      REDIS.set(:abc, 42)

      expect(prescription.eval(REDIS, :keys => %i[abc], :argv => [27])).
        to eq(69)

      REDIS_CONNECTION.script("flush")

      expect(prescription.eval(REDIS, :keys => %i[abc], :argv => [57])).
        to eq(99)
    end
  end
end
