RSpec.describe Dry::Data::Struct do
  before :all do
    module Structs
      class Address < Dry::Data::Struct
        attribute :city, "strict.string"
        attribute :zipcode, "coercible.string"
      end

      class User < Dry::Data::Struct
        attribute :name, "coercible.string"
        attribute :age, "coercible.int"
        attribute :address, "structs.address"
      end

      class SuperUser < User
        attributes(root: 'strict.bool')
      end
    end
  end

  describe '.attribute' do
    def assert_valid_struct(user)
      expect(user.name).to eql('Jane')
      expect(user.age).to be(21)
      expect(user.address.city).to eql('NYC')
      expect(user.address.zipcode).to eql('123')
    end

    let(:user_type) { Dry::Data["structs.user"] }
    let(:root_type) { Dry::Data["structs.super_user"] }

    it 'defines attributes for the constructor' do
      user = user_type[
        name: :Jane, age: '21', address: { city: 'NYC', zipcode: 123 }
      ]

      assert_valid_struct(user)
    end

    it 'ignores unknown keys' do
      user = user_type[
        name: :Jane, age: '21', address: { city: 'NYC', zipcode: 123 }, invalid: 'foo'
      ]

      assert_valid_struct(user)
    end

    it 'merges attributes from the parent struct' do
      user = root_type[
        name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
      ]

      assert_valid_struct(user)

      expect(user.root).to be(true)
    end
  end
end