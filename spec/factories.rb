FactoryGirl.define do

  factory :organization do
    name 'Factor.io'
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
  end

  factory :consumer do
    organization
    group
    name 'consumer'
  end

  factory :config_item do
    organization
    group
    name 'config'
    value 'some value'
  end

end
