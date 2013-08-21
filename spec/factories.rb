FactoryGirl.define do

  factory :organization do
    name 'Factor.io'

    factory :full_organization do |fo|
      name 'Full Organization'

      fo.users { |u| [
        u.association(:user, username: 'user1'),
        u.association(:user, username: 'user2')
      ] }

      fo.groups { |g| [
        g.association(:group, name: 'group1'),
        g.association(:group, name: 'group2')
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

      after(:build) do |org|
        org.consumers[0].update_attributes groups: [org.groups.first]
        org.consumers[1].update_attributes groups: [org.groups.last]
        org.consumers[2].update_attributes groups: org.groups
        org.consumers[3].update_attributes groups: []

        org.config_items[0].update_attributes groups: [org.groups.first]
        org.config_items[1].update_attributes groups: [org.groups.last]
        org.config_items[2].update_attributes groups: org.groups
        org.config_items[3].update_attributes groups: []
      end
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

  factory :group do
    organization
    name 'group'
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
