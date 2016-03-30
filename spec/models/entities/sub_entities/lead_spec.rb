require 'spec_helper'

describe Entities::SubEntities::Lead do
  describe 'class methods' do
    subject { Entities::SubEntities::Lead }

    it { expect(subject.external?).to be(true) }
    it { expect(subject.entity_name).to eql('lead') }
    it { expect(subject.external_attributes).to be_a(Array) }
    it { expect(subject.object_name_from_external_entity_hash({'FirstName' => 'John', 'LastName' => 'A'})).to eql('John A') }
  end
end