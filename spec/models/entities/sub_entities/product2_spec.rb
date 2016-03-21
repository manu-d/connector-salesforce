require 'spec_helper'

describe Entities::SubEntities::Product2 do
  describe 'class methods' do
    subject { Entities::SubEntities::Product2 }

    it { expect(subject.external?).to be(true) }
    it { expect(subject.entity_name).to eql('Product2') }
    it { expect(subject.external_attributes).to be_a(Array) }
    it { expect(subject.object_name_from_external_entity_hash({'Name' => 'Stuff', 'ProductCode' => '67AB'})).to eql('[67AB] Stuff') }
  end
end