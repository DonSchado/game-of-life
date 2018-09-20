require 'active_model'
require_relative '../../app/models/game_of_life'

RSpec.describe GameOfLife do
  subject(:game) { described_class.new(state: state, rows: 3, columns: 4) }
  let(:state) { '' }

  describe '#cells' do
    it { expect(game.cells).to eq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) }
  end

  describe 'the rules' do
    let(:rules) { game.method(:rules) }

    specify '#1: Any live cell with fewer than two live neighbors dies by under popolation' do
      expect(rules[cell_state: 1, neighbors_count: 0]).to eq(0)
      expect(rules[cell_state: 1, neighbors_count: 1]).to eq(0)
    end

    specify '#2: Any live cell with two or three live neighbors lives on to the next generation' do
      expect(rules[cell_state: 1, neighbors_count: 2]).to eq(1)
      expect(rules[cell_state: 1, neighbors_count: 3]).to eq(1)
    end

    specify '#3: Any live cell with more than three live neighbors dies by overpopulation.' do
      expect(rules[cell_state: 1, neighbors_count: 4]).to eq(0)
    end

    specify '#4: Any dead cell with exactly three live neighbors becomes a live cell by reproduction.' do
      expect(rules[cell_state: 0, neighbors_count: 2]).to eq(0)
      expect(rules[cell_state: 0, neighbors_count: 3]).to eq(1)
      expect(rules[cell_state: 0, neighbors_count: 4]).to eq(0)
    end
  end

  describe 'neighbors counter' do
    let(:neighbors_count) { game.method(:neighbors_count) }
    let(:state) {
      '1100'\
      '1010'\
      '0100'
    }

    it { expect(neighbors_count[0]).to  eq(2) }
    it { expect(neighbors_count[1]).to  eq(3) }
    it { expect(neighbors_count[2]).to  eq(2) }
    it { expect(neighbors_count[3]).to  eq(1) }
    it { expect(neighbors_count[4]).to  eq(3) }
    it { expect(neighbors_count[5]).to  eq(5) }
    it { expect(neighbors_count[6]).to  eq(2) }
    it { expect(neighbors_count[7]).to  eq(1) }
    it { expect(neighbors_count[8]).to  eq(2) }
    it { expect(neighbors_count[9]).to  eq(2) }
    it { expect(neighbors_count[10]).to eq(2) }
    it { expect(neighbors_count[11]).to eq(1) }
  end

  describe '#generation' do
    context 'empty state' do
      it 'empty generation' do
        expect { game.generation }.not_to change { game.cells }
      end
    end

    context 'glider' do
      let(:state) {
        '0010'\
        '1010'\
        '0110'
      }

      it 'transitions' do
        expect {
          game.generation
        }.to change {
          game.cells
        }.from([
          0,0,1,0,
          1,0,1,0,
          0,1,1,0
        ]).to([
          0,1,0,0,
          0,0,1,1,
          0,1,1,0
        ])
      end
    end

    context 'blinker' do
      let(:state) {
        '0010'\
        '0010'\
        '0010'
      }

      it 'transitions' do
        expect {
          game.generation
        }.to change {
          game.cells
        }.from([
          0,0,1,0,
          0,0,1,0,
          0,0,1,0
        ]).to([
          0,0,0,0,
          0,1,1,1,
          0,0,0,0
        ])
      end
    end
  end

  context 'utils, edgecases, defaults and fallbacks' do
    specify('default board_size') { expect(described_class.new.board_size).to eq(192) }

    it 'custom board_size' do
      expect(described_class.new(columns: '3', rows: '3').board_size).to eq(9)
    end

    it 'handles corrupt state' do
      expect(described_class.new(state: '123?-#foobar1', columns: '7', rows: '1').cells).to eq([1, 1, 1, 0, 0, 0, 0])
    end

    it 'knows at which index to "break lines"' do
      expect(described_class.new.linebreak?(0)).to be_falsey
      expect(described_class.new.linebreak?(1)).to be_falsey
      expect(described_class.new.linebreak?(12)).to be_truthy
      expect(described_class.new.linebreak?(24)).to be_truthy
      expect(described_class.new.linebreak?(191)).to be_falsey
      expect(described_class.new.linebreak?(192)).to be_truthy
    end
  end
end
