require 'spec_helper'

require 'puppet/x/jenkins/util'

describe Puppet::X::Jenkins::Util do
  let(:data) do
    {
      a: :undef,
      b: [
        nil,
        1,
        {
          c: nil,
          d: [
            :undef,
            1
          ],
          e: 1
        }
      ],
      f: 1
    }
  end

  describe '::unundef' do
    it 'converts :undef values to nil' do
      expect(described_class.unundef(data)).to eq(a: nil,
                                                  b: [
                                                    nil,
                                                    1,
                                                    {
                                                      c: nil,
                                                      d: [
                                                        nil,
                                                        1
                                                      ],
                                                      e: 1
                                                    }
                                                  ],
                                                  f: 1)
    end
  end # unundef

  describe '::undefize' do
    it 'converts nil values to :undef' do
      expect(described_class.undefize(data)).to eq(a: :undef,
                                                   b: [
                                                     :undef,
                                                     1,
                                                     {
                                                       c: :undef,
                                                       d: [
                                                         :undef,
                                                         1
                                                       ],
                                                       e: 1
                                                     }
                                                   ],
                                                   f: 1)
    end
  end # undefize

  describe '::iterate' do
    it 'does not transform without block' do
      expect(described_class.iterate(data)).to eq(data)
    end

    it 'does not affect hash keys' do
      expect(described_class.iterate(data) { 5 }).to eq(a: 5,
                                                        b: [
                                                          5,
                                                          5,
                                                          {
                                                            c: 5,
                                                            d: [
                                                              5,
                                                              5
                                                            ],
                                                            e: 5
                                                          }
                                                        ],
                                                        f: 5)
    end
  end # iterate
end
