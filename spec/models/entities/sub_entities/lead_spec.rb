require 'spec_helper'

describe Entities::SubEntities::Lead do
  subject { Entities::SubEntities::Lead.new }

  it { expect(subject.external?).to be(true) }
  it { expect(subject.entity_name).to eql('lead') }
  it { expect(subject.external_attributes).to be_a(Array) }

  describe 'map_to' do
    describe 'for an invalid entity name' do
      it { expect{ subject.map_to('lala', {}, nil).to raise_error("Impossible mapping from lead to lala") } }
    end

    describe 'for a valid entity name' do
      it 'calls denormalize and adds is_lead' do
        expect(Entities::SubEntities::LeadMapper).to receive(:denormalize).with({'FirstName' => 'John'}).and_return({first_name: 'John'})
        expect(subject.map_to('person', {'FirstName' => 'John'}, nil)).to eql({first_name: 'John', is_lead: true})
      end
    end
  end
end