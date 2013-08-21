FactoryGirl.define do

  factory :organization do
    name 'Factor.io'

    factory :full_organization do |fo|
      name 'Full Organization'

      fo.users { |u| [
        u.association(:user, username: 'user1'),
        u.association(:user, username: 'user2'),
        u.association(:admin)
      ] }

      fo.consumers { |c| [
        c.association(:consumer, name: 'Consumer 1'),
        c.association(:consumer, name: 'Consumer 2'),
        c.association(:consumer, name: 'Consumer Both'),
        c.association(:consumer, name: 'Consumer None')
      ] }

      fo.config_items { |ci| [
        ci.association(:config_item, name: 'Item 1'),
        ci.association(:config_item, name: 'Item 2'),
        ci.association(:config_item, name: 'Item Both'),
        ci.association(:config_item, name: 'Item None'),
      ] }
    end
  end

  factory :user do
    organization
    username 'user'
    password 'pass'

    factory :super_admin do
      role 'super_admin'
    end

    factory :admin do
      role 'admin'
    end
  end

  factory :consumer do
    organization
    name 'consumer'
  end

  factory :config_item do
    organization
    name 'config'
    value 'some value'
  end

end
