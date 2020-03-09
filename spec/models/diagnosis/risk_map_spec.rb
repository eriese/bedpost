RSpec.describe Diagnosis::RiskMap, type: :model do
	it 'initializes with a default value of 0' do
		map = described_class.new
		expect(map[:b]).to be 0
	end

	it 'can initialize with other values' do
		map = described_class.new(:default)
		expect(map[:b]).to be :default
	end

	describe '[]=' do
		it 'sets over a nil value' do
			map = described_class.new
			map[:b] = 1
			expect(map[:b]).to be 1
		end

		describe 'sets over a lower value' do
			it 'lower primitive and higher primitive' do
				map = described_class[:b, 1]
				map[:b] = 2
				expect(map[:b]).to be 2
			end

			it 'lower array and higher primitive' do
				map = described_class[:b, [1, [:caveat]]]
				map[:b] = 2
				expect(map[:b]).to be 2
			end

			it 'lower primitive and higher array' do
				map = described_class[:b, 1]
				map[:b] = [2, [:caveat]]
				expect(map[:b]).to eq [2, [:caveat]]
			end

			it 'lower array and higher array' do
				map = described_class[:b, [1, [:caveat1]]]
				map[:b] = [2, [:caveat2]]
				expect(map[:b]).to eq [2, [:caveat2]]
			end
		end

		describe 'does not set over a higher value' do
			it 'higher primitive and lower primitive' do
				map = described_class[:b, 2]
				map[:b] = 1
				expect(map[:b]).to be 2
			end

			it 'higher array and lower primitive' do
				map = described_class[:b, [2, [:caveat]]]
				map[:b] = 1
				expect(map[:b]).to eq [2, [:caveat]]
			end

			it 'higher primitive and lower array' do
				map = described_class[:b, 2]
				map[:b] = [1, [:caveat]]
				expect(map[:b]).to eq 2
			end

			it 'higher array and lower array' do
				map = described_class[:b, [2, [:caveat2]]]
				map[:b] = [1, [:caveat1]]
				expect(map[:b]).to eq [2, [:caveat2]]
			end
		end

		it 'also overrides store' do
			map = described_class[:b, 2]
			map.store(:b, 1)
			expect(map[:b]).to be 2
		end
	end

	describe '#risk_level' do
		it 'returns 0 if the map has no value for the key' do
			map = described_class.new
			expect(map.risk_level(:b)).to be 0
		end

		it 'returns the value if the value is a number' do
			map = described_class[:b, 2]
			expect(map.risk_level(:b)).to be 2
		end

		it 'returns the first index is the value is an array' do
			map = described_class[:b, [1, [:caveat]]]
			expect(map.risk_level(:b)).to be 1
		end
	end

	describe '#risk_caveats' do
		it 'returns nil if the map has no value for the key' do
			map = described_class.new
			expect(map.risk_caveats(:b)).to be_nil
		end

		it 'returns nil if the value is a number' do
			map = described_class[:b, 2]
			expect(map.risk_caveats(:b)).to be_nil
		end

		it 'returns the second index is the value is an array' do
			map = described_class[:b, [1, [:caveat]]]
			expect(map.risk_caveats(:b)).to eq [:caveat]
		end
	end

	describe '#merge' do
		it 'chooses the higher values' do
			map1 = described_class[:a, 1, :b, [2, [:caveat]], :c, [1, [:caveat1]]]
			map2 = described_class[:a, 2, :b, [1, [:caveat1]], :c, [1, [:caveat2]]]

			result = map1.merge(map2)
			expect(result).to eq(a: 2, b: [2, [:caveat]], c: [1, [:caveat1, :caveat2]])
		end

		it 'has the same result no matter the direction of the merge' do
			map1 = described_class[:a, 1, :b, [2, [:caveat]], :c, [1, [:caveat1]]]
			map2 = described_class[:a, 2, :b, [1, [:caveat1]], :c, [1, [:caveat2]]]

			expect(map1.merge(map2)).to eq map2.merge(map1)
		end
	end
end
